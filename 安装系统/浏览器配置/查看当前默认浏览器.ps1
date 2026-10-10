# 来源: 浏览器配置/默认浏览器配置.md
# 功能: 查询当前默认浏览器(http 协议的 UserChoice ProgId)

# 方式1: PowerShell 查看完整属性
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"

# 方式2: 只取 ProgId(例如 ChromeHTML、VivaldiHTM.xxx)
(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice").ProgId

# 方式3: 等价的 reg query 命令
reg query "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
