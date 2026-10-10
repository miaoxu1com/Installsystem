# 来源: winget/README.md
# 功能: 远程下载 winget-fast.ps1 并执行(把 <包ID> 换成实际包 ID，如 GitHub.cli)

iwr "https://gh-proxy.com/https://raw.githubusercontent.com/miaoxu1com/Installsystem/main/安装系统/镜像源设置/winget/winget-fast.ps1" -OutFile winget-fast.ps1
powershell -ExecutionPolicy Bypass -File .\winget-fast.ps1 -Id <包ID>
