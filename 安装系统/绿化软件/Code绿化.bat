@echo off
setlocal
:: 定义路径
set targetDir1=%USERPROFILE%\.vscode
set linkTarget1=E:\Develop\VSCode\.vscode
set targetDir2=%APPDATA%\Code\
set linkTarget2=%linkTarget1%\user-data\
:: 检查并创建目录
if exist "%targetDir1%\" (
    rd /S /Q "%targetDir1%"
    echo 已删除: %targetDir1%
) 

if exist "%targetDir2%\" (
    rd /S /Q "%targetDir2%"
    echo 已删除: %targetDir2%
) 
:: 创建符号链接
mklink /D "%targetDir1%" "%linkTarget1%"
mklink /D "%targetDir2%" "%linkTarget2%"
endlocal
pause