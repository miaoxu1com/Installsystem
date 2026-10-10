# 整合自: c.bat / git.bat / go.bat / 添加系统环境变量-BetterCap.ps1
# 功能: 统一配置开发环境变量(setx 持久写入，重启终端后生效)
# 用法:
#   .\配置开发环境变量.ps1 -All            # 全部配置
#   .\配置开发环境变量.ps1 -C -Git         # 只配置 C/C++ 和 Git
#   .\配置开发环境变量.ps1 -BetterCap      # BetterCap(系统级，需管理员)
[CmdletBinding()]
param(
    [switch]$C,
    [switch]$Git,
    [switch]$Go,
    [switch]$BetterCap,
    [switch]$All
)

if ($All) { $C = $Git = $Go = $BetterCap = $true }
if (-not ($C -or $Git -or $Go -or $BetterCap)) {
    Write-Host "请至少指定一个开关: -C -Git -Go -BetterCap -All" -ForegroundColor Yellow
    return
}

# 用户级环境变量
function Set-UserEnv([string]$Name, [string]$Value) {
    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
    Write-Host "✓ [User] $Name = $Value" -ForegroundColor Green
}

# 向用户 PATH 追加(带去重)
function Add-UserPath([string]$Dir) {
    $cur = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($cur -split ';') -notcontains $Dir) {
        [Environment]::SetEnvironmentVariable('Path', "$cur;$Dir", 'User')
        Write-Host "✓ [User] PATH 追加 $Dir" -ForegroundColor Green
    }
    else {
        Write-Host "- PATH 已包含 $Dir，跳过" -ForegroundColor DarkGray
    }
}

if ($C) {
    # C/C++ 头文件搜索路径，指向 scoop 安装的 gcc
    Set-UserEnv 'C_INCLUDE_PATH' 'D:\scoop\apps\gcc\current\include'
    Set-UserEnv 'CPLUS_INCLUDE_PATH' 'D:\scoop\apps\gcc\current\include'
}

if ($Git) {
    # 指向 scoop 安装的 git
    Set-UserEnv 'GIT_INSTALL_ROOT' 'D:\scoop\apps\git\current'
}

if ($Go) {
    Set-UserEnv 'GOPATH' 'D:\DemoWorkSpace\go'
    Set-UserEnv 'GOROOT' 'E:\Develop\go'
    Add-UserPath 'D:\DemoWorkSpace\go\bin'
    Add-UserPath 'E:\Develop\go\bin'
}

if ($BetterCap) {
    # 系统级(Machine)，需管理员
    [Environment]::SetEnvironmentVariable('BetterCap', 'E:\网络\', 'Machine')
    Write-Host "✓ [Machine] BetterCap = E:\网络\" -ForegroundColor Green
}

Write-Host "`n完成，请重启终端使环境变量生效。" -ForegroundColor Green
