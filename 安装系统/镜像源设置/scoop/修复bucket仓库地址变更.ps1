# 来源: scoop/README.md
# 功能: bucket 上游仓库地址变更后的迁移修复
# 当 bucket 上游仓库地址变化时，scoop list 和 scoop install 会报错，
# 需要把已安装 app 记录的仓库地址替换为新地址

# 1. 修改 bucket 仓库的 remote 地址(目录必须是 .git 仓库)
git -C "E:\Tools\Scoop\buckets\main" remote set-url origin https://github.com.cnpmjs.org/ScoopInstaller/Main.git
git -C "E:\Tools\Scoop\buckets\extras" remote set-url origin https://github.com.cnpmjs.org/lukesampson/scoop-extras.git

# 2. 批量替换已安装应用的 bucket 归属(示例: main -> spc)
Get-ChildItem -Path "D:\Scoop\apps" -Recurse -Filter "install.json" | ForEach-Object { try { $jsonContent = Get-Content $_.FullName -Raw | ConvertFrom-Json; if ($jsonContent.bucket -eq "main") { $jsonContent.bucket = "spc"; $jsonContent | ConvertTo-Json -Depth 10 | Set-Content $_.FullName -NoNewline; Write-Host "✓ 已更新: $($_.FullName)" -ForegroundColor Green } } catch { Write-Host "✗ JSON 解析失败: $($_.FullName) - $($_.Exception.Message)" -ForegroundColor Red } }
