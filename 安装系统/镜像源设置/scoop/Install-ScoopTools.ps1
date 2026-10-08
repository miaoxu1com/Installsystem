<#
.SYNOPSIS
    安装 abgox scoop-tools 加速方案（解决 GitHub 下载慢/失败）

.DESCRIPTION
    通过 abyss bucket 安装 abgox/scoop-tools 提供的 scoop-install 和 scoop-update，
    并配置 URL 替换规则：下载时自动把 github.com / raw.githubusercontent.com
    替换为 gh-proxy.com 加速镜像。
    同时安装 PSCompletions 命令补全和 scoop-i18n 中文支持。

.PARAMETER ProxyPrefix
    可选。加速代理前缀，默认 https://gh-proxy.com/ ，可换成自建或其他反代。

.PARAMETER SkipCompletions
    可选。跳过 PSCompletions 命令补全安装。

.EXAMPLE
    .\Install-ScoopTools.ps1

.EXAMPLE
    .\Install-ScoopTools.ps1 -ProxyPrefix "https://your-proxy.com/"

.NOTES
    abyss bucket: https://gitee.com/abgox/abyss
    项目地址: https://scoop-tools.abgox.com/zh-CN/
    之后用 scoop-install / scoop-update 替代 scoop install / scoop update
#>

[CmdletBinding()]
param(
    [string]$ProxyPrefix = "https://gh-proxy.com/",
    [switch]$SkipCompletions
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

# ---------- 1. 添加 abyss bucket ----------
Write-Step "添加 abyss bucket（Gitee 镜像）..."

$existing = (scoop bucket list 6>$null | Out-String) -split "`n"
if ($existing -notmatch '\babyss\b') {
    scoop bucket add abyss https://gitee.com/abgox/abyss
}
else {
    Write-Host "  abyss bucket 已存在，跳过" -ForegroundColor Yellow
}

# ---------- 2. 安装 scoop-install 和 scoop-update ----------
Write-Step "安装 scoop-install 和 scoop-update..."
scoop install abyss/abgox.scoop-install
scoop install abyss/abgox.scoop-update

# ---------- 3. 配置 URL 替换规则 ----------
Write-Step "配置 GitHub URL 替换为加速镜像..."
$proxy = $ProxyPrefix.TrimEnd('/')
scoop config abgox-scoop-install-url-replace-from "^https://github.com|||^https://raw.githubusercontent.com"
scoop config abgox-scoop-install-url-replace-to "$proxy/github.com|||$proxy/raw.githubusercontent.com"
Write-Host "  github.com -> $proxy/github.com" -ForegroundColor Green
Write-Host "  raw.githubusercontent.com -> $proxy/raw.githubusercontent.com" -ForegroundColor Green

# ---------- 4. 安装 i18n 中文支持 ----------
Write-Step "安装 scoop-i18n 中文支持..."
scoop install abyss/abgox.scoop-i18n

# ---------- 5. 安装命令补全 ----------
if (-not $SkipCompletions) {
    Write-Step "安装 PSCompletions 命令补全..."
    scoop install abyss/abgox.PSCompletions
    Write-Host ""
    Write-Host "  请在 PowerShell 配置文件 `$PROFILE 中添加以下两行以启用补全：" -ForegroundColor Yellow
    Write-Host "    Import-Module PSCompletions" -ForegroundColor White
    Write-Host "    psc add scoop scoop-install scoop-update" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  scoop-tools 加速方案配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法：" -ForegroundColor White
Write-Host "  scoop-install <软件名>   # 替代 scoop install，自动走加速镜像"
Write-Host "  scoop-update <软件名>    # 替代 scoop update，自动走加速镜像"
Write-Host "  scoop-update *           # 更新全部"
