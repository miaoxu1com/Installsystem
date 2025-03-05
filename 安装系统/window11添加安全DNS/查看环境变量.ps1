gci env:*
ls Env:
ls env:*

#排序显示 短格式powershell命令
gci env:* | sort-object name
#条件查询
gci env: | where name -like WT_SESSION

# 长格式显示
 [System.Environment]::GetEnvironmentVariables()
# 短格式显示
 dir env:
 
# 长格式显示	
[System.Environment]::GetEnvironmentVariable("USERNAME")
# 短格式显示
$env:USERNAME
# 指定名字环境变量显示
gci env: -Name
# 编程风格显示环境变量名字
(gci env:).Name

# Alternative, using gc (alias of Get-Content)
# Needed if the name is stored in a variable.
gc env:USERNAME

# 完整显示环境变量的值
# % 是 ForEach-Object cmdlet 的内置别名
gci env: | % tostring
gci env: | Write-Host


# 如果在 PowerShell 会话期间的某个时间，需要查看或临时修改 PATH 环境变量，可以键入以下命令之一：
$env:Path                             # 显示实际内容 [Environment]::GetEnvironmentVariable('ALICLOUD_ACCESSKEY_ID')
$env:Path = 'C:\foo;' + $env:Path     # 追加到开头
$env:Path += ';C:\foo'                # 追加到结尾

# 配置文件脚本在计算机中的位置，请键入：
$profile                                     
$profile.AllUsersAllHosts           
$profile.AllUsersCurrentHost        
$profile.CurrentUserAllHosts    
$profile.CurrentUserCurrentHost

# 您还可以通过以下方式永久修改用户/系统环境变量（即在 shell 重新启动后保持不变）：
# 修改系统环境变量
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
# 修改用户环境变量
[Environment]::SetEnvironmentVariable("INCLUDE", $env:INCLUDE, [System.EnvironmentVariableTarget]::User)
# 注释中的用法 - 添加到系统环境变量中
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\bin",
    [EnvironmentVariableTarget]::Machine)
# 如果您不想编写类型，也可以使用基于字符串的解决方案
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\bin", "Machine")

#Delete/remove variable:
[Environment]::SetEnvironmentVariable("oldEnvVar", "", "Machine")

# 会话级别环境变量
Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH
(Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH).path
# 获取旧的追击新的
$oldpath = (Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH).path
$newpath = “$oldpath;c:\path\to\folder”

Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH -Value $newPath
# 现在做最后检查一下，它看起来像你期望的样子：
(Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH).Path
($env:path).split(";")
