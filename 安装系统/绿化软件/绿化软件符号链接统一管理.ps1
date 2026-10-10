# 整合自: Code绿化.bat / Code绿化卸载.bat / npm绿化.bat / pnpm绿化.bat /
#         配置nuget文件软链接.bat / 查看nuget缓存路径.bat / vivaldi/vivaldi绿化.bat / vivaldi/卸载.bat
# 功能: 统一管理"绿化软件"符号链接 —— 把软件配置/数据目录链接到自定义位置，实现绿化迁移
# 注意: 需要管理员权限运行(创建符号链接); 链接前会删除目标处的已有目录/文件，请确认数据已迁移
# 用法:
#   .\绿化软件符号链接统一管理.ps1 -Software Code            # 绿化 VSCode
#   .\绿化软件符号链接统一管理.ps1 -Software All             # 全部绿化
#   .\绿化软件符号链接统一管理.ps1 -Software Code -Uninstall # 卸载 Code 绿化(只删链接)
#   .\绿化软件符号链接统一管理.ps1 -ShowNugetCache           # 查看 nuget 缓存路径
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Link')]
    [ValidateSet('Code', 'Npm', 'Pnpm', 'Nuget', 'Vivaldi', 'All')]
    [string]$Software,

    [Parameter(ParameterSetName = 'Link')]
    [switch]$Uninstall,

    [Parameter(Mandatory = $true, ParameterSetName = 'NugetCache')]
    [switch]$ShowNugetCache
)

# ============ 链接定义: 目标路径 = 链接源(真实数据位置) ============
# 父目录和子目录都有软链接时，直接设置父目录即可，子目录使用链接后的路径
$linkMap = @{
    Code = @(
        @{ Target = "$env:USERPROFILE\.vscode"; Source = 'E:\Develop\VSCode\.vscode'; Type = 'Dir' }
        @{ Target = "$env:APPDATA\Code";        Source = 'E:\Develop\VSCode\.vscode\user-data'; Type = 'Dir' }
    )
    Npm = @(
        @{ Target = "$env:USERPROFILE\.npmrc";  Source = 'D:\浏览器扩展_书签_脚本备份\配置文件\nodejs\.npmrc'; Type = 'File' }
    )
    Pnpm = @(
        @{ Target = "$env:LOCALAPPDATA\pnpm\config\rc"; Source = 'E:\Develop\configs\pnpm\rc'; Type = 'File'; EnsureParent = $true }
    )
    Nuget = @(
        @{ Target = "${env:ProgramFiles(x86)}\NuGet\Config";                  Source = 'E:\Develop\VisualStudio\NuGet';         Type = 'Dir' }
        @{ Target = "$env:APPDATA\NuGet";                                     Source = 'E:\Develop\VisualStudio\NuGet\config';  Type = 'Dir' }
        @{ Target = "${env:ProgramFiles(x86)}\Microsoft SDKs\NuGetPackages";  Source = 'E:\Develop\VisualStudio\NuGetPackages'; Type = 'Dir' }
    )
    Vivaldi = @(
        @{ Target = "$env:LOCALAPPDATA\Vivaldi"; Source = 'E:\浏览器\Application\Vivaldi'; Type = 'Dir' }
    )
}

function Remove-LinkTarget([string]$Path, [string]$Type) {
    if (Test-Path $Path) {
        if ($Type -eq 'Dir') {
            # 注意: 对符号链接目录要用安全删除，避免删到真实数据
            $item = Get-Item $Path -Force
            if ($item.LinkType) {
                $item.Delete()   # 只删除链接本身
                Write-Host "  已删除链接: $Path"
            }
            else {
                Remove-Item $Path -Recurse -Force
                Write-Host "  已删除目录: $Path"
            }
        }
        else {
            Remove-Item $Path -Force
            Write-Host "  已删除文件: $Path"
        }
    }
}

function Add-LinkTarget([hashtable]$Link) {
    if ($Link.EnsureParent) {
        $parent = Split-Path $Link.Target -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    }
    if (-not (Test-Path $Link.Source)) {
        Write-Host "  ✗ 链接源不存在: $($Link.Source)" -ForegroundColor Red
        return
    }
    cmd /c mklink $(if ($Link.Type -eq 'Dir') { '/D' }) "$($Link.Target)" "$($Link.Source)" | Out-Null
    Write-Host "  ✓ 已链接: $($Link.Target) -> $($Link.Source)" -ForegroundColor Green
}

if ($ShowNugetCache) {
    dotnet nuget locals all --list
    return
}

$targets = if ($Software -eq 'All') { $linkMap.Keys } else { @($Software) }

foreach ($name in $targets) {
    Write-Host "`n=== $name ===" -ForegroundColor Cyan
    foreach ($link in $linkMap[$name]) {
        Remove-LinkTarget -Path $link.Target -Type $link.Type
        if (-not $Uninstall) {
            Add-LinkTarget -Link $link
        }
    }
}

Write-Host "`n完成。" -ForegroundColor Green
