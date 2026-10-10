# 工作流: Scoop 国内环境一键配置
# 依赖顺序: Install-Scoop → Add-ScoopBuckets → Install-ScoopTools → 可选增强 → 批量装软件
# 用法:
#   .\工作流-Scoop国内环境一键配置.ps1 -All                      # 完整流程
#   .\工作流-Scoop国内环境一键配置.ps1 -InstallScoop -AddBuckets # 只装本体+bucket
#   .\工作流-Scoop国内环境一键配置.ps1 -All -ScoopDir "E:\scoop" # 自定义安装目录
# 说明: 本脚本只做编排，具体实现仍在同目录各脚本中，可单独使用
[CmdletBinding()]
param(
    [switch]$InstallScoop,      # 1. 通过 Gitee 镜像安装 Scoop 本体
    [switch]$AddBuckets,        # 2. 添加 Gitee 镜像 buckets(main/extras/versions/scoopcn)
    [switch]$InstallTools,      # 3. abgox scoop-tools(scoop-install/scoop-update 走代理)
    [switch]$AddSpc,            # 4a. 可选: spc bucket(约 1 万软件清单)
    [switch]$AddApps,           # 4b. 可选: apps bucket
    [switch]$EnableCompletion,  # 4c. 可选: 启用 PSCompletions 补全(需写入 $PROFILE)
    [switch]$InstallSoft,       # 5. 批量安装常用软件(scoop_install_soft.bat)
    [switch]$All,
    [string]$ScoopDir,
    [string]$ProxyPrefix
)

$here = $PSScriptRoot

if ($All) {
    $InstallScoop = $AddBuckets = $InstallTools = $true
}

function Invoke-Step([string]$Title, [scriptblock]$Action) {
    Write-Host "`n========== $Title ==========" -ForegroundColor Cyan
    & $Action
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        Write-Host "✗ 步骤失败: $Title (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

if ($InstallScoop) {
    Invoke-Step '1. 安装 Scoop 本体(Gitee 镜像)' {
        if ($ScoopDir) { & "$here\Install-Scoop.ps1" -ScoopDir $ScoopDir }
        else           { & "$here\Install-Scoop.ps1" }
    }
}

if ($AddBuckets) {
    Invoke-Step '2. 添加 Gitee 镜像 buckets' {
        & "$here\Add-ScoopBuckets.ps1"
    }
}

if ($InstallTools) {
    Invoke-Step '3. 安装 scoop-tools(GitHub 下载加速)' {
        if ($ProxyPrefix) { & "$here\Install-ScoopTools.ps1" -ProxyPrefix $ProxyPrefix }
        else              { & "$here\Install-ScoopTools.ps1" }
    }
}

if ($AddSpc) {
    Invoke-Step '4a. 添加 spc bucket' {
        & "$here\添加spc-bucket并切换main分支.ps1"
    }
}

if ($AddApps) {
    Invoke-Step '4b. 添加 apps bucket' {
        & "$here\添加apps-bucket更多软件清单.ps1"
    }
}

if ($EnableCompletion) {
    Invoke-Step '4c. 启用 PSCompletions 补全' {
        & "$here\启用scoop命令补全-PSCompletions.ps1"
    }
}

if ($InstallSoft) {
    Invoke-Step '5. 批量安装常用软件' {
        & "$here\scoop_install_soft.bat"
    }
}

Write-Host "`n工作流结束。" -ForegroundColor Green
