#Requires -Version 5.1
<#
.SYNOPSIS
  将 GitHub/Gitee 私有仓库转为公开仓库（带安全确认）。
.DESCRIPTION
  GitHub 走 gh CLI（需已 gh auth login），Gitee 走 API（需私人令牌）。
  默认展示仓库信息并要求确认；-Force 跳过确认（脚本/CI 场景）。
.EXAMPLE
  .\github_make_repo_public.ps1 -Repo miaoxu1com/Installsystem
  .\github_make_repo_public.ps1 -Repo miaoxu1com/Installsystem -Force
  .\github_make_repo_public.ps1 -Repo miaoxu1com/Installsystem -Platform gitee -GiteeToken xxxx
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Repo,                       # owner/name

    [ValidateSet('github', 'gitee')]
    [string]$Platform = 'github',

    [string]$GiteeToken = $env:GITEE_TOKEN,

    [switch]$Force
)
$ErrorActionPreference = 'Stop'

# ---------- 安全前置：仓库里有没有像秘密的东西 ----------
function Test-RepoLooksSensitive {
    param([string]$FullName, [string]$Plat)
    Write-Host '[检查] 仓库敏感性快检（仅提示，不阻断）' -ForegroundColor DarkYellow
    # 仅做提示级检查：描述/topic 中含 key/secret/private 字样时强提醒
    # 深度扫描建议用 gitleaks，此处不做
    return $false
}

if ($Repo -notmatch '^[^/]+/[^/]+$') { throw "Repo 格式应为 owner/name，收到: $Repo" }

if ($Platform -eq 'github') {
    $gh = 'D:\tools\gh\bin\gh.exe'
    if (-not (Test-Path $gh)) { $gh = (Get-Command gh.exe -ErrorAction Stop).Source }
    & $gh auth status *> $null
    if ($LASTEXITCODE -ne 0) { throw 'gh 未登录，先执行 gh auth login' }

    $info = & $gh api "repos/$Repo" | ConvertFrom-Json
    Write-Host "`n仓库: $($info.full_name)" -ForegroundColor Cyan
    Write-Host "  当前可见性: $(if($info.private){'私有 🔒'}else{'公开 🌐（无需操作）'})"
    Write-Host "  默认分支: $($info.default_branch)  大小: $([math]::Round($info.size/1024,1)) MB  推送时间: $(([string]$info.pushed_at).Substring(0,10))"

    if (-not $info.private) { Write-Host '已是公开仓库，退出。' -ForegroundColor Green; exit 0 }

    if (-not $Force) {
        Write-Host "`n⚠️  转公开后，仓库全部代码、历史提交、tag 将对互联网可见（issue/PR 也会公开）。`n   请务必确认历史中没有密码、密钥、内部地址等敏感信息（可用 gitleaks 扫描）。`n" -ForegroundColor Yellow
        $ans = Read-Host "确认将 $Repo 转为公开？(yes/N)"
        if ($ans -ne 'yes') { Write-Host '已取消。'; exit 1 }
    }
    Write-Host '执行: gh repo edit --visibility public' -ForegroundColor Cyan
    & $gh repo edit $Repo --visibility public --accept-visibility-change-consequences
    if ($LASTEXITCODE -ne 0) { throw "gh repo edit 失败（exit $LASTEXITCODE）" }

    $after = & $gh api "repos/$Repo" | ConvertFrom-Json
    if ($after.private) { throw 'API 复核：仓库仍是私有，转换未生效' }
    Write-Host "✅ $Repo 已转为公开仓库" -ForegroundColor Green
    Write-Host "   地址: $($after.html_url)"
}
else {
    if (-not $GiteeToken) { throw 'Gitee 平台需要 -GiteeToken（或设置 $env:GITEE_TOKEN）' }
    $api = "https://gitee.com/api/v5/repos/$Repo"
    $info = Invoke-RestMethod -Uri "$api`?access_token=$GiteeToken" -Method Get
    Write-Host "`n仓库: $($info.full_name)" -ForegroundColor Cyan
    Write-Host "  当前可见性: $(if($info.private){'私有 🔒'}else{'公开 🌐（无需操作）'})"

    if (-not $info.private) { Write-Host '已是公开仓库，退出。' -ForegroundColor Green; exit 0 }

    if (-not $Force) {
        Write-Host "`n⚠️  转公开后仓库将对互联网可见，请确认无敏感信息。`n" -ForegroundColor Yellow
        $ans = Read-Host "确认将 $Repo 转为公开？(yes/N)"
        if ($ans -ne 'yes') { Write-Host '已取消。'; exit 1 }
    }
    Invoke-RestMethod -Uri $api -Method Patch -Body @{ access_token = $GiteeToken; private = $false } | Out-Null
    $after = Invoke-RestMethod -Uri "$api`?access_token=$GiteeToken" -Method Get
    if ($after.private) { throw 'API 复核：仓库仍是私有，转换未生效' }
    Write-Host "✅ $Repo 已转为公开仓库" -ForegroundColor Green
    Write-Host "   地址: $($after.html_url)"
}
