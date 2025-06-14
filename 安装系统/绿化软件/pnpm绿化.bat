@echo off
setlocal
:: 定义路径
set targetDir1=%LOCALAPPDATA%\pnpm\config
set linkTarget1=E:\Develop\configs\pnpm\rc


:: 检查目标路径是否存在，并静默删除，rd /S /Q 删除指定目录下的所有子目录和文件  只用该命令删除软连接 删除的是目标目录的所有文件
rd /S /Q "%targetDir1%"
:: 创建目录
mkdir "%targetDir1%"
:: 创建符号链接
mklink "%targetDir1%\rc" "%linkTarget1%"
endlocal
pause