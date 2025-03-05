@echo off
setlocal
:: 定义路径
set targetDir1=%APPDATA%\Code
set targetDir2=%USERPROFILE%\.vscode
set linkTarget1=E:\Develop\VSCode\.vscode\user-data
set linkTarget2=E:\Develop\VSCode\.vscode\

:: 检查目标路径是否存在，并静默删除, rd /S /Q 删除指定目录下的所有子目录和文件  只用该命令删除软连接 删除的是目标目录的所有文件
if exist "%targetDir1%" (
    rd /S /Q "%targetDir1%"
)
if exist "%targetDir2%" (
    rd /S /Q "%targetDir2%"
)
:: 创建符号链接
mklink /D "%targetDir1%" "%linkTarget1%"
mklink /D "%targetDir2%" "%linkTarget2%"
endlocal
pause