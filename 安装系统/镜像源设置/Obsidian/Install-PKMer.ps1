<#
.SYNOPSIS
    自动下载并安装 PKMer 插件到 Obsidian（国内源，无需访问 GitHub）

.DESCRIPTION
    通过 PKMer 国内 CDN 源下载 obsidian-pkmer 插件包，
    自动检测本机所有 Obsidian 库，并安装到每个库的 .obsidian\plugins\ 目录下。
    安装后启用该插件即可通过国内 CDN 浏览/下载官方社区插件和主题。

.PARAMETER VaultPath
    可选。指定 Obsidian 库路径。不指定时自动读取 Obsidian 配置检测所有库。

.EXAMPLE
    .\Install-PKMer.ps1
    自动检测所有库并安装

.EXAMPLE
    .\Install-PKMer.ps1 -VaultPath "D:\valut\我的知识库"
    只安装到指定的库

.NOTES
    插件源: https://pkmer.cn/_release/obsidian-pkmer.zip
    作者: miaoxu1com
#>

[CmdletBinding()]
param(
    [string]$VaultPath
)

$ErrorActionPreference = "Stop"

$DownloadUrl = "https://pkmer.cn/_release/obsidian-pkmer.zip"
$PluginDirName = "obsidian-pkmer"
$TempZip = Join-Path $env:TEMP "obsidian-pkmer.zip"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

# ---------- 1. 获取目标库列表 ----------
Write-Step "检测 Obsidian 库..."

$vaults = @()

if ($VaultPath) {
    if (-not (Test-Path $VaultPath)) {
        Write-Host "错误：指定的库路径不存在: $VaultPath" -ForegroundColor Red
        exit 1
    }
    $vaults += $VaultPath
}
else {
    $obsidianConfig = Join-Path $env:APPDATA "obsidian\obsidian.json"
    if (-not (Test-Path $obsidianConfig)) {
        Write-Host "错误：未找到 Obsidian 配置文件 $obsidianConfig" -ForegroundColor Red
        Write-Host "请确认已安装并至少打开过一次 Obsidian，或使用 -VaultPath 手动指定库路径" -ForegroundColor Yellow
        exit 1
    }

    $config = Get-Content $obsidianConfig -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($vault in $config.vaults.PSObject.Properties) {
        $path = $vault.Value.path
        if (Test-Path $path) {
            $vaults += $path
        }
    }
}

if ($vaults.Count -eq 0) {
    Write-Host "错误：未检测到任何 Obsidian 库" -ForegroundColor Red
    exit 1
}

Write-Host "检测到 $($vaults.Count) 个库：" -ForegroundColor Green
$vaults | ForEach-Object { Write-Host "  - $_" }

# ---------- 2. 下载插件包 ----------
Write-Step "从 PKMer 国内源下载插件包..."

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing -TimeoutSec 120
}
catch {
    Write-Host "错误：下载失败 - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$zipSize = (Get-Item $TempZip).Length
if ($zipSize -lt 10KB) {
    Write-Host "错误：下载的文件过小 ($zipSize 字节)，可能下载失败" -ForegroundColor Red
    Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "下载完成：$([math]::Round($zipSize / 1KB)) KB" -ForegroundColor Green

# ---------- 3. 验证压缩包内容 ----------
Write-Step "验证插件包完整性..."

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($TempZip)
$entries = $zip.Entries | ForEach-Object { $_.FullName }
$zip.Dispose()

$requiredFiles = @("$PluginDirName/main.js", "$PluginDirName/manifest.json", "$PluginDirName/styles.css")
foreach ($file in $requiredFiles) {
    if ($entries -notcontains $file) {
        Write-Host "错误：插件包缺少必要文件 $file" -ForegroundColor Red
        Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
        exit 1
    }
}
Write-Host "插件包完整（main.js / manifest.json / styles.css）" -ForegroundColor Green

# ---------- 4. 安装到每个库 ----------
foreach ($vault in $vaults) {
    Write-Step "安装到库: $vault"

    $pluginsDir = Join-Path $vault ".obsidian\plugins"
    if (-not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
        Write-Host "  已创建 plugins 目录"
    }

    $targetDir = Join-Path $pluginsDir $PluginDirName

    # 备份已有配置（data.json 不会被覆盖，这里只是提示）
    if (Test-Path $targetDir) {
        Write-Host "  检测到已存在的 PKMer 插件，将覆盖更新（保留 data.json 配置）" -ForegroundColor Yellow
    }

    try {
        Expand-Archive -Path $TempZip -DestinationPath $pluginsDir -Force
    }
    catch {
        Write-Host "  错误：解压失败 - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  提示：如果 Obsidian 正在运行且插件被占用，请先关闭 Obsidian 后重试" -ForegroundColor Yellow
        continue
    }

    Write-Host "  安装成功 -> $targetDir" -ForegroundColor Green
}

# ---------- 5. 清理临时文件 ----------
Remove-Item $TempZip -Force -ErrorAction SilentlyContinue

# ---------- 6. 完成提示 ----------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PKMer 插件安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "接下来请在 Obsidian 中完成以下操作：" -ForegroundColor White
Write-Host "  1. 重启 Obsidian（完全退出再打开）"
Write-Host "  2. 设置 -> 第三方插件 -> 关闭「安全模式」"
Write-Host "  3. 在已安装插件列表中启用「PKMer」"
Write-Host "  4. 点插件设置中的「登录」，登录 PKMer 账号（可免费注册）"
Write-Host ""
Write-Host "启用后即可通过国内 CDN 浏览和下载所有社区插件/主题，无需访问 GitHub。" -ForegroundColor White
Write-Host "免费用户每月 100 次下载额度。" -ForegroundColor DarkGray
