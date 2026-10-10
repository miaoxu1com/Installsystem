# 整合自: Bandizip_Menu.bat / IObitUnlocker_Menu.bat / 注册软件右键菜单DLL-Bandizip与IObitUnlocker.ps1
# 功能: 用 regsvr32 注册/反注册软件外壳扩展 DLL，把软件功能加进右键菜单
# 注意: 需要以管理员身份运行; DLL 路径按实际安装位置修改
# 用法:
#   .\注册软件右键菜单DLL-Bandizip与IObitUnlocker.ps1              # 注册
#   .\注册软件右键菜单DLL-Bandizip与IObitUnlocker.ps1 -Unregister  # 反注册
[CmdletBinding()]
param(
    [switch]$Unregister
)

$dlls = @(
    'E:\pack\Bandizip\bdzshl.x64.dll'                  # Bandizip 右键菜单(64位外壳扩展)
    # 'E:\pack\Bandizip\bdzshl.x86.dll'                # 32位按需启用
    'E:\IObit Unlocker\IObitUnlockerExtension.dll'     # IObit Unlocker 右键菜单(文件解锁/强制删除)
)

foreach ($dll in $dlls) {
    if (-not (Test-Path $dll)) {
        Write-Host "✗ 未找到: $dll" -ForegroundColor Red
        continue
    }
    if ($Unregister) {
        regsvr32 /u /s $dll
        Write-Host "✓ 已反注册: $dll" -ForegroundColor Green
    }
    else {
        regsvr32 /s $dll
        Write-Host "✓ 已注册: $dll" -ForegroundColor Green
    }
}
