# 设置Scoop bucket  临时和永久设置并用
function Set-ScoopBucket {
    param (
        [string]$name,
        [string]$url
    )
    
    # 检查bucket是否存在
    if (Test-Path (Join-Path $env:SCOOP 'buckets' $name)) {
        # 如果bucket存在，则更新它
        Write-Host "正在更新bucket: $name"
        scoop bucket rm $name
        scoop bucket add $name $url
    } else {
        # 如果bucket不存在，则添加它
        Write-Host "正在添加bucket: $name"
        scoop bucket add $name $url
    }
}

# 设置执行策略（仅对本次会话有效）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 确保以管理员权限运行脚本
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "请以管理员权限重新运行此脚本" -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 设置Scoop的bucket
$buckets = @{
    'main'     = 'https://gitee.com/scoop-installer/Main';
    'extras'   = 'https://gitee.com/scoop-installer/Extras';
}

foreach ($bucket in $buckets.GetEnumerator()) {
    Set-ScoopBucket -name $bucket.Key -url $bucket.Value
}

Write-Host "所有Scoop仓库设置完毕。" -ForegroundColor Green