#requires -Version 5.1
<#
.SYNOPSIS
    修复 Vivaldi 文件关联 / 清理残留注册表项（可复用版）

.DESCRIPTION
    功能：
      1. 动态定位当前 Vivaldi 安装（exe 路径 + User Data 目录），不依赖硬编码
      2. 动态识别当前安装的哈希后缀（如 VivaldiHTM.XXXXXXXX），重装后编号变了也能用
      3. 修复所有相关 ProgID 的 open 命令（指向真实 exe，并带上 --user-data-dir）
      4. 清理指向已不存在 exe 的残留 ProgID / StartMenuInternet 客户端 / RegisteredApplications
      5. 清理 FileExts\OpenWithList 中的残留菜单项并重建 MRUList

    用法：
      powershell -ExecutionPolicy Bypass -File Fix-VivaldiAssociation.ps1            # 预演（只显示会做什么）
      powershell -ExecutionPolicy Bypass -File Fix-VivaldiAssociation.ps1 -Apply     # 实际执行
      可用 -VivaldiExe / -UserDataDir 手动覆盖自动检测结果；普通安装用 -NoUserDataDir
#>
[CmdletBinding()]
param(
    [string]$VivaldiExe,
    [string]$UserDataDir,
    [switch]$NoUserDataDir,
    [switch]$Apply          # 不加此参数时为预演模式，不改动任何内容
)

$ErrorActionPreference = 'Continue'
$script:Changed = 0

function Write-Step([string]$msg) { Write-Host "`n== $msg ==" -ForegroundColor Cyan }
function Do-OrPreview([scriptblock]$action, [string]$desc) {
    if ($Apply) { & $action; Write-Host "  [已执行] $desc" -ForegroundColor Green; $script:Changed++ }
    else        { Write-Host "  [预演]   $desc" -ForegroundColor Yellow }
}

# ---------- 工具函数 ----------
function Get-ExeFromCommand([string]$cmd) {
    if (-not $cmd) { return $null }
    if ($cmd -match '^\s*"([^"]+\.exe)"') { return $Matches[1] }
    if ($cmd -match '^\s*(\S+?\.exe)')    { return $Matches[1] }
    return $null
}
function Get-UserDataDirFromCommand([string]$cmd) {
    if ($cmd -match '--user-data-dir="([^"]+)"') { return $Matches[1] }
    if ($cmd -match '--user-data-dir=(\S+)')     { return $Matches[1] }
    return $null
}
function Get-RegDefault([string]$path) {
    try { (Get-ItemProperty -LiteralPath $path -ErrorAction Stop).'(default)' } catch { $null }
}
function Get-OpenCommand([string]$regKeyPath) {
    Get-RegDefault (Join-Path $regKeyPath 'shell\open\command')
}
function Set-OpenCommand([string]$regKeyPath, [string]$exe, [string]$udd, [switch]$QuoteArg) {
    $arg = if ($QuoteArg) { '"%1"' } else { '%1' }
    $cmd = "`"$exe`""
    if ($udd) { $cmd += " --user-data-dir=`"$udd`"" }
    $cmd += " --single-argument $arg"
    Do-OrPreview { New-Item -Path (Join-Path $regKeyPath 'shell\open\command') -Force | Out-Null
                   Set-ItemProperty -LiteralPath (Join-Path $regKeyPath 'shell\open\command') -Name '(default)' -Value $cmd } `
                 "设置命令: $regKeyPath  =>  $cmd"
}

# ---------- 1. 收集候选 exe 路径 ----------
Write-Step "检测 Vivaldi 安装位置"
$candidates = New-Object System.Collections.Generic.List[string]

# 1a. 注册表里的各类命令
$regCommandKeys = @(
    'HKCU:\Software\Classes\Applications\vivaldi.exe',
    'HKCU:\Software\Classes\html_auto_file',
    'HKCU:\Software\Classes\htmlfile',
    'HKCU:\Software\Classes\vivaldi-browser'
)
$regCommandKeys += Get-ChildItem 'HKCU:\Software\Clients\StartMenuInternet' -ErrorAction SilentlyContinue |
    Where-Object PSChildName -like 'Vivaldi*' | ForEach-Object { $_.PSPath }
$regCommandKeys += Get-ChildItem 'HKCU:\Software\Classes' -ErrorAction SilentlyContinue |
    Where-Object PSChildName -match '^Vivaldi(HTM|PDF|PPDF)\.' | ForEach-Object { $_.PSPath }

foreach ($k in $regCommandKeys) {
    $exe = Get-ExeFromCommand (Get-OpenCommand $k)
    if ($exe) { $candidates.Add($exe) }
}

# 1b. 快捷方式（桌面 / 开始菜单 / 任务栏固定），顺便收集 user-data-dir
$shell = New-Object -ComObject WScript.Shell
$shortcutDirs = @(
    [Environment]::GetFolderPath('Desktop'),
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",
    "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"
)
$uddFromShortcut = $null
foreach ($dir in $shortcutDirs) {
    Get-ChildItem $dir -Filter *.lnk -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $s = $shell.CreateShortcut($_.FullName)
            if ($s.TargetPath -match 'vivaldi\.exe$') {
                $candidates.Add($s.TargetPath)
                if (-not $uddFromShortcut -and $s.Arguments) {
                    $uddFromShortcut = Get-UserDataDirFromCommand $s.Arguments
                }
            }
        } catch {}
    }
}

$existing = $candidates | Where-Object { $_ -and (Test-Path $_) }
if (-not $VivaldiExe) {
    $VivaldiExe = $existing | Group-Object | Sort-Object Count -Descending | Select-Object -First 1 -ExpandProperty Name
}
if (-not $VivaldiExe -or -not (Test-Path $VivaldiExe)) {
    Write-Host "未找到有效的 vivaldi.exe，请用 -VivaldiExe 指定" -ForegroundColor Red; exit 1
}
Write-Host "  exe: $VivaldiExe"

# ---------- 2. 确定 User Data 目录 ----------
if ($NoUserDataDir) {
    $UserDataDir = $null
} elseif (-not $UserDataDir) {
    # 优先快捷方式参数，其次 exe 旁边的 "User Data"（独立安装布局）
    $sibling = Join-Path (Split-Path (Split-Path $VivaldiExe -Parent) -Parent) 'User Data'
    if     ($uddFromShortcut -and (Test-Path $uddFromShortcut)) { $UserDataDir = $uddFromShortcut }
    elseif (Test-Path $sibling)                                 { $UserDataDir = $sibling }
}
if ($UserDataDir) { Write-Host "  User Data: $UserDataDir" } else { Write-Host "  User Data: (不使用 --user-data-dir)" }

# ---------- 3. 识别当前哈希后缀 ----------
Write-Step "识别当前安装的哈希后缀"
$currentHash = $null
Get-ChildItem 'HKCU:\Software\Clients\StartMenuInternet' -ErrorAction SilentlyContinue |
    Where-Object PSChildName -match '^Vivaldi\.(.+)$' | ForEach-Object {
        $exe = Get-ExeFromCommand (Get-OpenCommand $_.PSPath)
        if ($exe -and (Test-Path $exe)) {
            $currentHash = $Matches[1]
            Write-Host "  当前客户端: $($_.PSChildName)  (hash: $currentHash)"
        }
    }
if (-not $currentHash) {
    # 客户端注册缺失时，从 ProgID 里找指向有效 exe 的那个
    Get-ChildItem 'HKCU:\Software\Classes' -ErrorAction SilentlyContinue |
        Where-Object PSChildName -match '^VivaldiHTM\.(.+)$' | ForEach-Object {
            $exe = Get-ExeFromCommand (Get-OpenCommand $_.PSPath)
            if ($exe -and (Test-Path $exe) -and -not $currentHash) { $currentHash = $Matches[1] }
        }
}
if ($currentHash) { Write-Host "  当前 hash: $currentHash" } else { Write-Host "  未找到当前 hash（可能从未设为默认浏览器），只做通用清理" -ForegroundColor Yellow }

# ---------- 4. 修复当前注册的 open 命令 ----------
Write-Step "修复当前注册的启动命令"
$fixKeys = @('HKCU:\Software\Classes\Applications\vivaldi.exe')
if ($currentHash) {
    $fixKeys += "HKCU:\Software\Classes\VivaldiHTM.$currentHash",
                "HKCU:\Software\Classes\VivaldiPDF.$currentHash",
                "HKCU:\Software\Classes\VivaldiPPDF.$currentHash"
}
foreach ($k in $fixKeys) {
    if (Test-Path $k) { Set-OpenCommand $k $VivaldiExe $UserDataDir }
}
# html_auto_file / htmlfile / vivaldi-browser 若指向 vivaldi 也一并修
foreach ($k in 'HKCU:\Software\Classes\html_auto_file','HKCU:\Software\Classes\htmlfile','HKCU:\Software\Classes\vivaldi-browser') {
    $exe = Get-ExeFromCommand (Get-OpenCommand $k)
    if ($exe -match 'vivaldi\.exe$') { Set-OpenCommand $k $VivaldiExe $UserDataDir }
}

# ---------- 5. 清理残留 ProgID ----------
Write-Step "清理残留 ProgID（exe 已不存在的旧注册）"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
foreach ($hive in 'HKCU:\Software\Classes','HKLM:\Software\Classes') {
    if ($hive -like 'HKLM:*' -and -not $isAdmin) {
        Write-Host "  跳过 HKLM（需要管理员权限）" -ForegroundColor DarkYellow; continue
    }
    Get-ChildItem $hive -ErrorAction SilentlyContinue |
        Where-Object PSChildName -match '^Vivaldi(HTM|PDF|PPDF)\.(.+)$' | ForEach-Object {
            $hash = $Matches[2]
            $exe  = Get-ExeFromCommand (Get-OpenCommand $_.PSPath)
            $stale = ($currentHash -and $hash -ne $currentHash) -or ($exe -and -not (Test-Path $exe)) -or (-not $exe)
            if ($stale) {
                Do-OrPreview { Remove-Item -LiteralPath $_.PSPath -Recurse -Force } "删除残留 ProgID: $($_.PSChildName)"
            } else {
                Write-Host "  保留: $($_.PSChildName)"
            }
        }
}

# ---------- 6. 清理残留 StartMenuInternet 客户端 + RegisteredApplications ----------
Write-Step "清理残留浏览器客户端注册"
Get-ChildItem 'HKCU:\Software\Clients\StartMenuInternet' -ErrorAction SilentlyContinue |
    Where-Object PSChildName -match '^Vivaldi\.(.+)$' | ForEach-Object {
        $name = $_.PSChildName
        $exe  = Get-ExeFromCommand (Get-OpenCommand $_.PSPath)
        if (($currentHash -and $name -ne "Vivaldi.$currentHash") -or ($exe -and -not (Test-Path $exe))) {
            Do-OrPreview { Remove-Item -LiteralPath $_.PSPath -Recurse -Force } "删除残留客户端: $name"
            $ra = 'HKCU:\SOFTWARE\RegisteredApplications'
            if ((Get-ItemProperty -LiteralPath $ra -Name $name -ErrorAction SilentlyContinue)) {
                Do-OrPreview { Remove-ItemProperty -LiteralPath $ra -Name $name -Force } "删除 RegisteredApplications 值: $name"
            }
        } else {
            Write-Host "  保留: $name"
        }
    }

# ---------- 7. 清理 FileExts 的 OpenWithList 残留菜单项 ----------
Write-Step "清理各扩展名“打开方式”菜单的残留项"
Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts' -ErrorAction SilentlyContinue | ForEach-Object {
    $owl = Join-Path $_.PSPath 'OpenWithList'
    if (-not (Test-Path $owl)) { return }
    $props = Get-ItemProperty -LiteralPath $owl
    $mru = $props.MRUList
    foreach ($p in $props.PSObject.Properties) {
        if ($p.Name -in 'MRUList','PSPath','PSParentPath','PSChildName','PSDrive','PSProvider') { continue }
        $v = [string]$p.Value
        $stale = $false
        if ($v -match '^Vivaldi\.(.+)$' -and $v -notmatch '\.exe$') {  # 旧 hash 的应用名（排除 vivaldi.exe）
            if ($currentHash -and $Matches[1] -ne $currentHash) { $stale = $true }
        }
        if ($stale) {
            Do-OrPreview { Remove-ItemProperty -LiteralPath $owl -Name $p.Name -Force } "[$($_.PSChildName)] 删除菜单项 $($p.Name)=$v"
            if ($mru) { $mru = $mru -replace [regex]::Escape($p.Name), '' }
        }
    }
    if ($Apply -and $mru -ne $props.MRUList) {
        if ($mru) { Set-ItemProperty -LiteralPath $owl -Name MRUList -Value $mru }
        else      { Remove-ItemProperty -LiteralPath $owl -Name MRUList -ErrorAction SilentlyContinue }
    }
}

# ---------- 8. 检查 UserChoice 是否指向已失效的 ProgID ----------
Write-Step "检查默认打开方式 (UserChoice)"
Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts' -ErrorAction SilentlyContinue | ForEach-Object {
    $uc = Join-Path $_.PSPath 'UserChoice'
    if (-not (Test-Path $uc)) { return }
    $progid = (Get-ItemProperty -LiteralPath $uc -Name ProgID -ErrorAction SilentlyContinue).ProgID
    if ($progid -match 'Vivaldi' -and -not (Test-Path "Registry::HKEY_CLASSES_ROOT\$progid")) {
        Write-Host "  警告: $($_.PSChildName) 的默认程序指向已不存在的 $progid" -ForegroundColor Red
        Write-Host "        UserChoice 受系统保护无法脚本删除，请双击该类型文件重新选择一次 Vivaldi" -ForegroundColor Red
    }
}
$ucHtml = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice'
if (Test-Path $ucHtml) {
    $p = (Get-ItemProperty -LiteralPath $ucHtml -Name ProgID).ProgID
    Write-Host "  .html 当前默认: $p"
}

Write-Host "`n完成。共 $script:Changed 项变更$(if (-not $Apply) {'（预演模式，未实际修改；加 -Apply 执行）'})。" -ForegroundColor Cyan
