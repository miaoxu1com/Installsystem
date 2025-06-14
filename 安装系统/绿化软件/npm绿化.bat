@echo off
setlocal
:: 定义路径
set targetDir1=%USERPROFILE%\.npmrc
set linkTarget1=D:\浏览器扩展_书签_脚本备份\配置文件\nodejs\.npmrc

if exist "%targetDir1%" (
    :: 删除文件
	del /f /q "%targetDir1%"
)

:: 创建链接
mklink "%targetDir1%" "%linkTarget1%"
endlocal
pause