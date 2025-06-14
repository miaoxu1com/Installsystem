@echo off
setlocal
:: 定义路径，父目录和子目录都有软连接时，直接设置父目录即可子目录直接使用链接的子目录路径
set targetDir1=%LOCALAPPDATA%\Vivaldi\
set linkTarget1=E:\浏览器\Application\Vivaldi\
:: 检查目标路径是否存在，并静默删除，rd /S /Q 删除指定目录下的所有子目录和文件  只用该命令删除软连接 删除的是目标目录的所有文件
if exist "%targetDir1%" (
    rd /S /Q "%targetDir1%"
)
:: 创建符号链接
mklink /D "%targetDir1%" "%linkTarget1%"
endlocal
pause

