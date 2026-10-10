# 添加硬链接 / 符号链接

脚本已提取至: `绿化软件/创建符号链接与硬链接-绿化exe到PATH目录.ps1`

## 说明

- Windows PowerShell 多行命令用 `` ` ``(反引号)换行，Linux 用 `\`
- **软链接(SymbolicLink)** 可以实现把 exe 放在一个目录下、添加环境变量即可直接使用的方法，可跨盘
- **硬链接(HardLink)** 相当于同一文件的另一个名字，不能跨盘跨卷
- PowerShell 7.1 开始支持用相对路径创建指向文件夹的 SymbolicLink
- `ls | Format-Table Name, LinkType, Target` 可查看链接类型和目标
