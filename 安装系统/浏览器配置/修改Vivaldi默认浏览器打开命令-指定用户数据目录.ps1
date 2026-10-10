# 来源: 浏览器配置/默认浏览器配置.md
# 功能: 修改 Vivaldi 的打开命令，追加 --user-data-dir 指定绿色版用户数据目录
# 注意: Vivaldi 更新后 ProgId 后缀(PUK5654O77IMHDNSZZWMZSHXVU)可能会变，
#       更新后若参数丢失，先重新查 ProgId 再执行本脚本

# 方式1: 固定 ProgId 直接设置
Set-ItemProperty -Path "HKCU:\Software\Classes\VivaldiHTM.PUK5654O77IMHDNSZZWMZSHXVU\shell\open\command" -Name "(default)" -Value '"E:\浏览器\Application\Application\vivaldi.exe" --user-data-dir="E:\浏览器\Application\Vivaldi\User Data" --single-argument %1'

# 方式2: 单行自动查询当前默认浏览器 ProgId + 设置 + 回显修改结果
$p = "HKCU:\Software\Classes\$((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice').ProgId)\shell\open\command"
Set-ItemProperty -Path $p -Name "(default)" -Value '"E:\浏览器\Application\Application\vivaldi.exe" --user-data-dir="E:\浏览器\Application\Vivaldi\User Data" --single-argument %1' -PassThru

# 等价的 cmd 命令(供参考):
# reg add "HKCU\SOFTWARE\Classes\VivaldiHTM.PUK5654O77IMHDNSZZWMZSHXVU\shell\open\command" /ve /t REG_SZ /d "\"E:\浏览器\Application\Application\vivaldi.exe\" --user-data-dir=\"E:\浏览器\Application\Vivaldi\User Data\" --single-argument %1" /f
