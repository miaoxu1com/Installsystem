# 来源: window11添加安全DNS/添加硬链接-powershell换行.md
# 功能: 创建符号链接(软链接)/硬链接，把 exe 链接到已加入 PATH 的目录即可直接命令行调用
# 注意: PowerShell 多行命令用反引号 ` 换行; 创建符号链接需管理员或开发者模式

# ============ 符号链接(推荐，相当于快捷方式，可跨盘) ============
# 软链接: 把 fping.exe 链接到上级目录，配合环境变量直接使用
New-Item -ItemType SymbolicLink -Path "E:\网络\fping.exe" -Target "E:\网络\fping\fping.exe"

# 同样的方法链接 fscan
New-Item -ItemType SymbolicLink -Path "E:\网络\fscan.exe" -Target "E:\网络\fscan\fscan-main\fscan.exe"

# ============ 硬链接(相当于同一份文件的另一个名字，不能跨盘跨卷) ============
New-Item -ItemType HardLink -Path "E:\网络\fping.exe" -Target "E:\网络\fping\fping.exe"

# 多行写法示例(反引号换行)
New-Item -ItemType HardLink `
         -Path  e:\网络\fping\fping.exe `
         -Name fping `
         -Target e:\网络\fping.exe

# ============ 验证: 查看链接类型和目标 ============
$link = New-Item -ItemType SymbolicLink -Path .\link -Target .\Notice.txt
$link | Select-Object LinkType, Target

# 列出当前目录所有项的链接信息(PowerShell 7.1+ 支持相对路径符号链接)
Get-ChildItem | Format-Table Name, LinkType, Target
