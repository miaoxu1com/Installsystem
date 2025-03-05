New-Item -ItemType HardLink `
		 -Path  e:\网络\fping\fping.exe `
		 -Name fping `
		 -Target e:\网络\fping.exe
		 
		 
window powershell多行用 `换行
linux多行 \

PowerShell创建软链接（符号链接），快捷方式也可以实现
New-Item -ItemType SymbolicLink -Path "E:\网络\fping.exe" -Target "E:\网络\fping\fping.exe"

软连接可以实现放在一个目录下添加环境变量就可以使用的方法
New-Item -ItemType SymbolicLink -Path "E:\网络\fscan.exe" -Target "E:\网络\fscan\fscan-main\fscan.exe"

PowerShell创建硬链接不行相当于copy
New-Item -ItemType HardLink -Path "新建的硬链接文件路径" -Target "源文件"
New-Item -ItemType HardLink -Path "E:\网络\fping.exe" -Target "E:\网络\fping\fping.exe"


Get-ChildItem -Path C:\Temp\
Directory:  C:\Temp

Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d-----        5/15/2019   6:45 AM        1   One
d-----        5/15/2019   6:45 AM        1   Two
d-----        5/15/2019   6:45 AM        1   Three

New-Item -Path C:\Temp\* -Name temp.txt -ItemType File | Select-Object FullName

FullName
--------
C:\Temp\One\temp.txt
C:\Temp\Three\temp.txt
C:\Temp\Two\temp.txt

$link = New-Item -ItemType SymbolicLink -Path .\link -Target .\Notice.txt
$link | Select-Object LinkType, Target

LinkType     Target
--------     ------
SymbolicLink {.\Notice.txt}

从 PowerShell 7.1 开始，现在可以使用相对路径创建到 Windows 上的文件夹的 SymbolicLink。

ls | Format-Table name,LinkType,Target