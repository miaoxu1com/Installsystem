1.在powershell配置中添加启用ctrl r 代替默认的ctrl r实现反向查找
# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
2.使用fzf模糊 tab代替默认的tab补全，默认的是列一个支持命令的菜单，如果命令少了可以，多的话交互就比较复杂，fzf tab是调用fzf进行模糊搜索命令
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }


3.使用git Get-Service， Start-Service， Stop-Service Get-Process， Start-Process 后面** 再按tab触发功能
Set-PsFzfOption -TabExpansion
