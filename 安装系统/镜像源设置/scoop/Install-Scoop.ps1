<#
.SYNOPSIS
    通过 Gitee 镜像安装 Scoop（国内源，无需访问 GitHub）

.DESCRIPTION
    1. 设置 PowerShell 执行策略（CurrentUser RemoteSigned）
    2. 从 Gitee 镜像下载 Scoop 安装脚本并安装
    3. 配置 scoop_repo 为 Gitee 镜像
    4. 开启 use_sqlite_cache 优化 scoop search 性能

.PARAMETER ScoopDir
    可选。Scoop 安装目录，默认 D:\scoop

.EXAMPLE
    .\Install-Scoop.ps1
    安装到默认目录 D:\scoop

.EXAMPLE
    .\Install-Scoop.ps1 -ScoopDir "E:\scoop"
    安装到指定目录

.NOTES
    安装源: https://gitee.com/scoop-installer-mirrors/Install
    安装完成后还需要 7zip 和 git，如网络问题无法通过 scoop 安装请手动安装，
    然后运行: scoop config use_external_7zip true
#>

[CmdletBinding()]
param(
    [string]$ScoopDir = "D:\scoop"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

# ---------- 1. 检查是否已安装 ----------
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop 已安装：$((Get-Command scoop).Source)" -ForegroundColor Yellow
    Write-Host "如需重装请先卸载。跳过安装步骤，仅更新配置。" -ForegroundColor Yellow
}
else {
    # ---------- 2. 设置执行策略 ----------
    Write-Step "设置执行策略（CurrentUser RemoteSigned）..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # ---------- 3. 下载安装脚本（Gitee 镜像） ----------
    Write-Step "从 Gitee 镜像下载安装脚本..."
    $installScript = Join-Path $env:TEMP "scoop-install.ps1"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://gitee.com/scoop-installer-mirrors/Install/releases/download/archive/install.ps1" `
        -OutFile $installScript -UseBasicParsing -TimeoutSec 120

    # ---------- 4. 执行安装 ----------
    Write-Step "安装 Scoop 到 $ScoopDir ..."
    & $installScript -ScoopDir $ScoopDir
    Remove-Item $installScript -Force -ErrorAction SilentlyContinue
}

# ---------- 5. 配置 Gitee 镜像仓库 ----------
Write-Step "配置 scoop_repo 为 Gitee 镜像..."
scoop config scoop_repo https://gitee.com/scoop-installer-mirrors/Scoop

# ---------- 6. 优化 scoop search 性能 ----------
Write-Step "开启 use_sqlite_cache 优化搜索性能..."
scoop config use_sqlite_cache true

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Scoop 安装配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "后续步骤：" -ForegroundColor White
Write-Host "  1. 运行 Add-ScoopBuckets.ps1 添加 Gitee 镜像 buckets"
Write-Host "  2. 安装 7zip 和 git（网络问题可手动安装后运行: scoop config use_external_7zip true）"
Write-Host "  3. 可选：运行 Install-ScoopTools.ps1 配置 GitHub 下载加速"
