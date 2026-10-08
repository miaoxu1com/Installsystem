<#
.SYNOPSIS
    添加 Scoop 的 Gitee 镜像 buckets（当前验证可用的国内源）

.DESCRIPTION
    添加以下 buckets（全部为 Gitee 纯净官方镜像库）：
      - main      https://gitee.com/scoop-installer/Main
      - extras    https://gitee.com/scoop-installer/Extras
      - versions  https://gitee.com/scoop-installer/Versions
      - scoopcn   https://gitee.com/scoop-installer/scoopcn
    已存在的同名 bucket 会先移除再按新源添加，保证源地址正确。

.EXAMPLE
    .\Add-ScoopBuckets.ps1

.NOTES
    运行结束后自动执行 scoop bucket list 验证结果。
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# bucket 名 -> Gitee 镜像地址
$buckets = [ordered]@{
    "main"     = "https://gitee.com/scoop-installer/Main"
    "extras"   = "https://gitee.com/scoop-installer/Extras"
    "versions" = "https://gitee.com/scoop-installer/Versions"
    "scoopcn"  = "https://gitee.com/scoop-installer/scoopcn"
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

# ---------- 获取已存在的 buckets ----------
$existing = @()
try {
    $existing = (scoop bucket list 6>$null | Out-String -Stream | Select-String '^\S+' | ForEach-Object {
        ($_ -split '\s+')[0]
    }) | Where-Object { $_ -and $_ -ne 'Name' -and $_ -notmatch '^-' }
}
catch {
    # 兼容旧版本 scoop 无 bucket list 输出的情况
    $existing = @()
}

foreach ($name in $buckets.Keys) {
    $url = $buckets[$name]
    Write-Step "配置 bucket: $name"

    if ($existing -contains $name) {
        Write-Host "  已存在，先移除再重新添加以保证源地址正确" -ForegroundColor Yellow
        scoop bucket rm $name 2>$null | Out-Null
    }

    scoop bucket add $name $url
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  添加成功: $url" -ForegroundColor Green
    }
    else {
        Write-Host "  添加失败: $url" -ForegroundColor Red
    }
}

# ---------- 验证 ----------
Write-Step "当前 bucket 列表："
scoop bucket list

Write-Host "`n完成！现在可以直接使用 scoop search / scoop install。" -ForegroundColor Green
