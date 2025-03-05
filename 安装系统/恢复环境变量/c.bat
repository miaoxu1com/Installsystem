@echo off
REM 设置C_INCLUDE_PATH环境变量
setx C_INCLUDE_PATH "D:\scoop\apps\gcc\current\include"

REM 设置CPLUS_INCLUDE_PATH环境变量
setx CPLUS_INCLUDE_PATH "D:\scoop\apps\gcc\current\include"

REM 提示用户配置已完成
echo C_INCLUDE_PATH and CPLUS_INCLUDE_PATH environment variables have been set to D:\scoop\apps\gcc\current\include.
echo Please restart your command line or computer to apply the changes.
pause