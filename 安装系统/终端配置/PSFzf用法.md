# PSFzf 用法

脚本已提取至: `终端配置/配置PSFzf快捷键与模糊补全.ps1`(加入 `$PROFILE` 生效)

1. 在 PowerShell 配置中启用 Ctrl+r 模糊反向搜索历史命令，代替默认的 Ctrl+r(Ctrl+t 为模糊查找文件)
2. 使用 fzf 模糊 Tab 代替默认的 Tab 补全: 默认是列出支持命令的菜单，命令少可以，多了交互复杂; fzf Tab 调用 fzf 模糊搜索命令
3. `Get-Service`、`Start-Service`、`Stop-Service`、`Get-Process`、`Start-Process` 等命令参数后面输入 `**` 再按 Tab 触发 fzf 模糊选择
