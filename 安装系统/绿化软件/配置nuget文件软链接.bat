@echo off
setlocal EnableDelayedExpansion

:: 设置目标目录和链接目标
set "targetDir1=%ProgramFiles(x86)%\NuGet\Config"
set "linkTarget1=E:\Develop\VisualStudio\NuGet"
set "targetDir2=%APPDATA%\NuGet"
set "linkTarget2=%linkTarget1%\config"
set "targetDir3=%ProgramFiles(x86)%\Microsoft SDKs\NuGetPackages"
set "linkTarget3=E:\Develop\VisualStudio\NuGetPackages"

:: 删除旧目录或链接
call :DeleteLinkOrDir targetDir1
call :DeleteLinkOrDir targetDir2
call :DeleteLinkOrDir targetDir3

:: 创建符号链接
echo 正在创建符号链接...
call :CreateLink targetDir1 linkTarget1
call :CreateLink targetDir2 linkTarget2
call :CreateLink targetDir3 linkTarget3

echo 所有操作已完成。
pause
exit /b

:: 子程序：删除目录或符号链接
:DeleteLinkOrDir
setlocal
set "dirPath=!%~1!"
if exist "!dirPath!" (
    echo 正在尝试删除: !dirPath!
    rd /S /Q "!dirPath!" >nul 2>&1
)
endlocal
exit /b

:: 子程序：创建符号链接
:CreateLink
setlocal
set "dirPath=!%~1!"
set "linkPath=!%~2!"
mklink /D "!dirPath!" "!linkPath!"
endlocal
exit /b