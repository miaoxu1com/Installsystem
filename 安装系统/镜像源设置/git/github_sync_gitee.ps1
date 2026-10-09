#Requires -Version 7.0
<#
.SYNOPSIS
  GitHub 仓库一键搬运到 Gitee：代码(全 ref) + Wiki + Release(含二进制附件)。
.DESCRIPTION
  流程：gh 校验 → gh-proxy 镜像克隆 → Gitee 建仓(如不存在) → push --mirror
       → 可选搬 Wiki → 逐 release 下载附件(gh-proxy 加速) → Gitee 建 release → 传附件。
  前置：gh 已登录；Gitee 私人令牌（gitee.com → 设置 → 私人令牌，勾 projects）。
  -DryRun 只列出将执行的动作，不做任何写操作。
.EXAMPLE
  .\github_sync_gitee.ps1 -GitHubRepo vercel-labs/agent-browser -GiteeOwner miaoxu -GiteeToken xxx
  .\github_sync_gitee.ps1 -GitHubRepo miaoxu1com/Installsystem -GiteeOwner miaoxu -GiteeToken xxx -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GitHubRepo,                 # owner/name

    [Parameter(Mandatory = $true)]
    [string]$GiteeOwner,                 # Gitee 用户名或企业名

    [string]$GiteeRepo,                  # 缺省 = GitHub 仓库同名
    [string]$GiteeToken = $env:GITEE_TOKEN,

    [string]$ProxyPrefix = 'https://gh-proxy.com/',
    [string]$WorkDir = "$env:TEMP\gh2gitee",
    [switch]$IncludeWiki = $true,
    [switch]$IncludeReleases = $true,
    [int]$MaxAssetMB = 90,               # Gitee 免费版单附件约 100MB，留余量
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if ($GitHubRepo -notmatch '^[^/]+/[^/]+$') { throw "GitHubRepo 格式应为 owner/name" }
if (-not $GiteeRepo) { $GiteeRepo = ($GitHubRepo -split '/')[1] }
if (-not $GiteeToken -and -not $DryRun) { throw '需要 -GiteeToken 或 $env:GITEE_TOKEN（-DryRun 模式可免）' }

$gh = 'D:\tools\gh\bin\gh.exe'
if (-not (Test-Path $gh)) { $gh = (Get-Command gh.exe -ErrorAction Stop).Source }
& $gh auth status *> $null
if ($LASTEXITCODE -ne 0) { throw 'gh 未登录，先 gh auth login' }

$gapi = 'https://gitee.com/api/v5'
function Gitee-Get($path) { Invoke-RestMethod -Uri "$gapi$path`?access_token=$GiteeToken" -Method Get }
function Gitee-Post($path, $body) {
    $b = @{ access_token = $GiteeToken } + $body
    Invoke-RestMethod -Uri "$gapi$path" -Method Post -Body $b
}

# ---------- 0. 探测 ----------
Write-Host "`n[0] 探测 GitHub 仓库..." -ForegroundColor Cyan
$info = & $gh api "repos/$GitHubRepo" | ConvertFrom-Json
$releases = @()
if ($IncludeReleases) { $releases = @(& $gh api "repos/$GitHubRepo/releases?per_page=100" | ConvertFrom-Json) }
$assetCount = ($releases | ForEach-Object { $_.assets.Count } | Measure-Object -Sum).Sum
$plan = @(
    "  代码+tag: $($info.full_name) ($([math]::Round($info.size/1024,1)) MB, 默认分支 $($info.default_branch))"
    "  Wiki:      $(if($info.has_wiki){'有，将搬运'}else{'无'})"
    "  Release:   $($releases.Count) 个，附件 $assetCount 个"
    "  目标:      https://gitee.com/$GiteeOwner/$GiteeRepo"
)
$plan | ForEach-Object { Write-Host $_ }
if ($DryRun) { Write-Host "`n-DryRun 结束，未执行任何写操作。" -ForegroundColor Green; exit 0 }

# ---------- 1. Gitee 建仓（不存在则建） ----------
Write-Host "`n[1] 确认 Gitee 目标仓库..." -ForegroundColor Cyan
$exists = $true
try { Gitee-Get "/repos/$GiteeOwner/$GiteeRepo" | Out-Null } catch { $exists = $false }
if (-not $exists) {
    Write-Host "  创建 Gitee 仓库 $GiteeOwner/$GiteeRepo ..."
    Gitee-Post '/user/repos' @{ name = $GiteeRepo; private = $false } | Out-Null
}
Write-Host "  OK: https://gitee.com/$GiteeOwner/$GiteeRepo"

# ---------- 2. 代码镜像 ----------
Write-Host "`n[2] 镜像克隆并推送代码..." -ForegroundColor Cyan
$bare = Join-Path $WorkDir "$GiteeRepo.git"
Remove-Item $bare -Recurse -Force -ErrorAction SilentlyContinue
git clone --mirror "${ProxyPrefix}https://github.com/$GitHubRepo.git" $bare
if ($LASTEXITCODE -ne 0) { throw 'git clone --mirror 失败' }
Push-Location $bare
try {
    git remote set-url origin "https://oauth2:$GiteeToken@gitee.com/$GiteeOwner/$GiteeRepo.git"
    git push --mirror
    if ($LASTEXITCODE -ne 0) { throw 'git push --mirror 失败（Gitee 权限/网络）' }
} finally { Pop-Location }
Write-Host '  代码+tag 推送完成'

# ---------- 3. Wiki ----------
if ($IncludeWiki -and $info.has_wiki) {
    Write-Host "`n[3] 搬运 Wiki..." -ForegroundColor Cyan
    $wdir = Join-Path $WorkDir "$GiteeRepo.wiki.git"
    Remove-Item $wdir -Recurse -Force -ErrorAction SilentlyContinue
    git clone --mirror "${ProxyPrefix}https://github.com/$GitHubRepo.wiki.git" $wdir
    if ($LASTEXITCODE -eq 0) {
        Push-Location $wdir
        try {
            git remote set-url origin "https://oauth2:$GiteeToken@gitee.com/$GiteeOwner/$GiteeRepo.wiki.git"
            git push --mirror 2>&1 | Out-Host
        } finally { Pop-Location }
    } else { Write-Warning '  Wiki 克隆失败（可能为空 wiki），跳过' }
}

# ---------- 4. Releases ----------
if ($IncludeReleases -and $releases.Count -gt 0) {
    Write-Host "`n[4] 搬运 $($releases.Count) 个 Release..." -ForegroundColor Cyan
    foreach ($rel in ($releases | Sort-Object { $_.created_at })) {
        $tag = $rel.tag_name
        Write-Host "  ▸ $tag ($($rel.assets.Count) 个附件)"
        # 4.1 Gitee 建 release（已存在则复用）
        $gRel = $null
        try { $gRel = Gitee-Get "/repos/$GiteeOwner/$GiteeRepo/releases/tags/$tag" } catch {}
        if (-not $gRel) {
            try {
                $gRel = Gitee-Post "/repos/$GiteeOwner/$GiteeRepo/releases" @{
                    tag_name = $tag; name = $rel.name; body = $rel.body; target_commitish = $rel.target_commitish
                }
            } catch { Write-Warning "    创建 release 失败（tag 可能未推送）: $($_.Exception.Message)"; continue }
        }
        # 4.2 下载并上传附件
        if ($rel.assets.Count -gt 0) {
            $dlDir = Join-Path $WorkDir "assets\$tag"
            Remove-Item $dlDir -Recurse -Force -ErrorAction SilentlyContinue
            New-Item -ItemType Directory -Path $dlDir -Force | Out-Null
            & $gh release download $tag --repo $GitHubRepo --dir $dlDir --clobber *> $null
            if ($LASTEXITCODE -ne 0) { Write-Warning "    附件下载失败，仅保留 release 元数据"; continue }
            foreach ($f in (Get-ChildItem $dlDir -File)) {
                $mb = [math]::Round($f.Length / 1MB, 1)
                if ($mb -gt $MaxAssetMB) { Write-Warning "    跳过 $($f.Name)：$mb MB 超过 Gitee 单附件限制"; continue }
                Write-Host "    上传 $($f.Name) ($mb MB)..."
                try {
                    Invoke-RestMethod -Method Post `
                        -Uri "$gapi/repos/$GiteeOwner/$GiteeRepo/releases/$($gRel.id)/attach_files?access_token=$GiteeToken" `
                        -Form @{ file = Get-Item $f.FullName } | Out-Null
                } catch { Write-Warning "    上传失败 $($f.Name): $($_.Exception.Message)" }
            }
        }
    }
}

Write-Host "`n✅ 搬运完成: https://gitee.com/$GiteeOwner/$GiteeRepo" -ForegroundColor Green
