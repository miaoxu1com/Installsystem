# 工作流: 开发环境镜像源一键配置
# 功能: 统一入口，按需为各开发工具配置国内镜像源(只编排，具体实现在各子目录脚本)
# 用法:
#   .\工作流-开发环境镜像源一键配置.ps1 -All             # 全部配置
#   .\工作流-开发环境镜像源一键配置.ps1 -Npm -Pip -Rust  # 只配置部分
# 注意: Git 的 insteadOf 会影响所有 git 拉取操作，谨慎使用(见 git/README.md)
[CmdletBinding()]
param(
    [switch]$Git,     # git insteadOf 全局替换(ghproxy)
    [switch]$Go,      # GOPROXY(仅当前会话)
    [switch]$Npm,     # npm → npmmirror(chsrc)
    [switch]$Pnpm,    # pnpm store/cache/global 目录配置
    [switch]$Pip,     # pip → 清华源(chsrc)
    [switch]$Uv,      # uv Python 下载镜像 + USTC index(系统级环境变量)
    [switch]$Rust,    # RUSTUP/CARGO 清华/USTC 镜像 + config.toml(系统级)
    [switch]$Winget,  # winget 源 → USTC
    [switch]$All
)

$root = $PSScriptRoot

if ($All) { $Git = $Go = $Npm = $Pnpm = $Pip = $Uv = $Rust = $Winget = $true }
if (-not ($Git -or $Go -or $Npm -or $Pnpm -or $Pip -or $Uv -or $Rust -or $Winget)) {
    Write-Host "请至少指定一个开关: -Git -Go -Npm -Pnpm -Pip -Uv -Rust -Winget -All" -ForegroundColor Yellow
    return
}

function Invoke-Step([string]$Title, [string]$Script) {
    Write-Host "`n========== $Title ==========" -ForegroundColor Cyan
    if (-not (Test-Path $Script)) {
        Write-Host "✗ 脚本不存在: $Script" -ForegroundColor Red
        return
    }
    & $Script
}

if ($Git)   { Invoke-Step 'Git insteadOf 全局替换(谨慎)'  "$root\git\git_config.bat" }
if ($Go)    { Invoke-Step 'Go GOPROXY 代理(当前会话)'     "$root\go\设置GOPROXY代理.ps1" }
if ($Npm)   { Invoke-Step 'npm → npmmirror'               "$root\npm\node_js_mirror.bat" }
if ($Pnpm)  { Invoke-Step 'pnpm 目录配置'                 "$root\npm\pnpm目录配置.bat" }
if ($Pip)   { Invoke-Step 'pip → 清华源'                  "$root\pip\python_pypi_mirror.bat" }
if ($Uv)    { Invoke-Step 'uv Python 下载镜像(系统级)'    "$root\uv\python_uv_mirror.bat" }
if ($Rust)  { Invoke-Step 'Rust 清华/USTC 镜像(系统级)'   "$root\rust\rust.bat" }
if ($Winget){ Invoke-Step 'winget 源 → USTC'              "$root\winget\winget源换为USTC镜像.ps1" }

Write-Host "`n工作流结束。" -ForegroundColor Green
