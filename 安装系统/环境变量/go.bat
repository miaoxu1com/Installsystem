@echo off
REM 设置GOPATH环境变量
setx GOPATH "D:\DemoWorkSpace\go"

REM 设置GOROOT环境变量
setx GOROOT "E:\Develop\go"

REM 添加GOPATH\bin到PATH环境变量
setx PATH "%PATH%;%GOPATH%\bin"

REM 添加GOROOT\bin到PATH环境变量
setx PATH "%PATH%;%GOROOT%\bin"

REM 提示用户配置已完成
echo GOPATH and GOROOT environment variables have been set.
echo GOPATH: D:\DemoWorkSpace\go
echo GOROOT: E:\Develop\go
echo PATH has been updated to include GOPATH\bin and GOROOT\bin.
echo Please restart your command line or computer to apply the changes.
pause


