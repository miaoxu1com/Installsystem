# 来源: 终端配置/PSFzf用法.md
# 功能: 配置 PSFzf，增强 PowerShell 交互体验
# 用法: 把以下内容加入 PowerShell 配置文件 $PROFILE

# 1. Ctrl+t 模糊查找文件，Ctrl+r 模糊反向搜索历史命令(替换默认 Ctrl+r)
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# 2. Tab 键改用 fzf 模糊补全(代替默认的候选菜单，命令多时更好用)
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# 3. 启用 Tab 扩展: Get-Service、Start-Service、Stop-Service、Get-Process、Start-Process
#    等命令参数后面输入 ** 再按 Tab 触发 fzf 模糊选择
Set-PsFzfOption -TabExpansion
