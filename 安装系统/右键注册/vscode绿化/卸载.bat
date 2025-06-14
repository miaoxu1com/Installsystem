@echo off
setlocal
:: 定义路径
set targetDir1=%APPDATA%\Code
set targetDir2=%USERPROFILE%\.vscode

:: 检查目标路径是否存在，并静默删除
if exist "%targetDir1%" (
    rmdir "%targetDir1%"
)
if exist "%targetDir2%" (
    rmdir "%targetDir2%"
)
endlocal
pause