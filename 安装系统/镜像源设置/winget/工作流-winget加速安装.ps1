# 工作流: winget 镜像加速安装
# 依赖顺序: (可选)换 USTC 源 → 开启本地清单安装(一次性前置) → winget-fast 加速安装
# 用法:
#   .\工作流-winget加速安装.ps1 -Id GitHub.cli                    # 加速安装指定包
#   .\工作流-winget加速安装.ps1 -Id GitHub.cli -SwitchSource      # 顺便把 winget 源换为 USTC
#   .\工作流-winget加速安装.ps1 -Id Neovim.Neovim -Version 0.11.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Id,           # winget 包 ID

    [string]$Version,      # 指定版本，缺省最新

    [switch]$SwitchSource, # 先把 winget 源换为 USTC 镜像

    [string]$ProxyPrefix   # 自定义 gh-proxy 前缀
)

$here = $PSScriptRoot

# 前置条件: 开启本地清单安装(需管理员，仅需一次)
Write-Host "========== 前置: 开启本地清单安装 ==========" -ForegroundColor Cyan
& "$here\启用winget本地清单安装.ps1"

# 可选: 换 USTC 源
if ($SwitchSource) {
    Write-Host "`n========== 换源: winget → USTC ==========" -ForegroundColor Cyan
    & "$here\winget源换为USTC镜像.ps1"
}

# 加速安装
Write-Host "`n========== 加速安装: $Id ==========" -ForegroundColor Cyan
$fastArgs = @{ Id = $Id }
if ($Version)     { $fastArgs.Version = $Version }
if ($ProxyPrefix) { $fastArgs.ProxyPrefix = $ProxyPrefix }
& "$here\winget-fast.ps1" @fastArgs

Write-Host "`n工作流结束。" -ForegroundColor Green
