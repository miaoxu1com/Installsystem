# 确保以管理员权限运行脚本
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "请以管理员权限重新运行此脚本" -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 设置要安装的模块列表
$modules = @(
    'GuiCompletion',
    'PowerShellGet',
    'PSWindowsUpdate',
    'PackageManagement',
    'PSReadLine',
    'scoop-completion',
    'PSFzf',
    'PSCompletions'
)

# 安装每个模块
foreach ($module in $modules) {
    Write-Host "正在安装模块: $module"
    try {
        # 尝试从PowerShell Gallery安装模块
        Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
        Write-Host "$module 模块已成功安装." -ForegroundColor Green
    } catch {
        Write-Host "安装模块 $module 时发生错误: $_" -ForegroundColor Red
    }
}

Write-Host "所有模块安装完毕。" -ForegroundColor Green