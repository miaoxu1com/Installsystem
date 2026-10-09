#Requires -Version 5.1
<#
.SYNOPSIS
  winget GitHub 加速安装：拉取官方清单 -> 将 github.com 下载地址拼接 gh-proxy -> 本地清单安装。
  gh-proxy 是字节级透传反代，安装包与原地址完全一致，因此 winget 的 SHA256 校验不受影响。
.EXAMPLE
  Install-WingetFast GitHub.cli
  Install-WingetFast Neovim.Neovim -Version 0.11.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Id,

    [string]$Version,

    [string]$ProxyPrefix = 'https://gh-proxy.com/',

    [string]$WorkDir = "$env:TEMP\winget-fast"
)

$ErrorActionPreference = 'Stop'

# --- 0. 解析可用的 winget（应用执行别名可能损坏，回退到真实路径） -----------------
$script:Winget = $null
$candidate = Get-Command winget.exe -ErrorAction SilentlyContinue
if ($candidate) {
    & $candidate.Source --version *> $null
    if ($LASTEXITCODE -eq 0) { $script:Winget = $candidate.Source }
}
if (-not $script:Winget) {
    $pkg = Get-AppxPackage -Name Microsoft.DesktopAppInstaller
    if ($pkg) {
        $real = Join-Path $pkg.InstallLocation 'winget.exe'
        if (Test-Path $real) { & $real --version *> $null; if ($LASTEXITCODE -eq 0) { $script:Winget = $real } }
    }
}
if (-not $script:Winget) { throw 'winget 不可用：执行别名损坏且未找到 Microsoft.DesktopAppInstaller' }
Write-Host "  winget: $script:Winget" -ForegroundColor DarkGray

# --- 1. 解析版本 -------------------------------------------------------------
if (-not $Version) {
    Write-Host "[1/4] 查询 $Id 最新版本..." -ForegroundColor Cyan
    $show = & $script:Winget show --id $Id --exact --accept-source-agreements 2>$null | Out-String
    if ($show -match '(?m)^\s*版本:\s*(\S+)\s*$') { $Version = $Matches[1] }
    elseif ($show -match '(?m)^\s*Version:\s*(\S+)\s*$') { $Version = $Matches[1] }
    if (-not $Version) { throw "无法从 winget show 解析 $Id 的版本，请用 -Version 显式指定" }
}
Write-Host "  目标: $Id $Version" -ForegroundColor Green

# --- 2. 下载清单（microsoft/winget-pkgs） -------------------------------------
$letter = $Id.Substring(0, 1).ToLower()
$pkgPath = ($Id -split '\.') -join '/'
$rawBase = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/$letter/$pkgPath/$Version"
$files = @("$Id.yaml", "$Id.installer.yaml", "$Id.locale.en-US.yaml")

$mDir = Join-Path $WorkDir "$Id\$Version"
Remove-Item $mDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $mDir -Force | Out-Null

Write-Host "[2/4] 拉取清单 $rawBase" -ForegroundColor Cyan
foreach ($f in $files) {
    $dst = Join-Path $mDir $f
    try {
        Invoke-WebRequest -Uri "$ProxyPrefix$rawBase/$f" -OutFile $dst -UseBasicParsing -TimeoutSec 60
    } catch {
        if ($f -eq "$Id.locale.en-US.yaml") {
            Write-Warning "  缺少 $f（部分包无独立 locale 文件），继续"
            continue
        }
        throw "清单下载失败: $f -> $($_.Exception.Message)"
    }
}

# --- 3. 重写 github.com 下载地址 ----------------------------------------------
$rewriteCount = 0
Get-ChildItem $mDir -Filter *.yaml | ForEach-Object {
    $text = Get-Content $_.FullName -Raw
    $new = $text -replace [regex]::Escape('https://github.com'), ($ProxyPrefix + 'https://github.com')
    $new = $new -replace [regex]::Escape('https://objects.githubusercontent.com'), ($ProxyPrefix + 'https://objects.githubusercontent.com')
    if ($new -ne $text) {
        $rewriteCount += ([regex]::Matches($text, 'github\.com')).Count
        Set-Content $_.FullName $new -NoNewline -Encoding utf8
    }
}
Write-Host "[3/4] 已重写 $rewriteCount 处 github 地址 -> $ProxyPrefix" -ForegroundColor Cyan
Get-ChildItem $mDir | ForEach-Object { Write-Host "  $($_.Name)" }

# --- 4. 本地清单安装 -----------------------------------------------------------
Write-Host "[4/4] winget install --manifest $mDir" -ForegroundColor Cyan
& $script:Winget install --manifest $mDir --accept-package-agreements --accept-source-agreements --disable-interactivity
if ($LASTEXITCODE -ne 0) {
    Write-Warning @"
安装失败（exit $LASTEXITCODE）。若提示本地清单被禁用，需要管理员执行一次：
  winget settings --enable LocalManifestFiles
"@
    exit $LASTEXITCODE
}
Write-Host "完成：$Id $Version 已通过 $ProxyPrefix 加速安装" -ForegroundColor Green
