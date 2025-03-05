@echo off
setlocal
:: 定义路径
set targetDir1=%LOCALAPPDATA%\Vivaldi\

:: 检查目标路径是否存在，并静默删除
if exist "%targetDir1%" (
    rmdir "%targetDir1%"
)
endlocal
pause