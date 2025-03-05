@echo off
REM 设置RUSTUP_HOME环境变量
setx RUSTUP_HOME "E:\Develop\Rust\rustup_home" /M

REM 设置CARGO_HOME环境变量
setx CARGO_HOME "E:\Develop\Rust\cargo_home" /M

REM 设置RUSTUP_DIST_SERVER环境变量
setx RUSTUP_DIST_SERVER "https://mirrors.tuna.tsinghua.edu.cn/rustup" /M

REM 设置RUSTUP_UPDATE_ROOT环境变量
setx RUSTUP_UPDATE_ROOT "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup" /M

REM 设置CARGO_HOME路径
set CARGO_HOME=E:\Develop\Rust\cargo_home

REM 创建CARGO_HOME目录（如果不存在）
if not exist "%CARGO_HOME%" (
    mkdir "%CARGO_HOME%"
)


REM 创建或覆盖config.toml文件
(
    echo [source.crates-io]
    echo replace-with = "ustc"
    echo.  
    echo [source.ustc]
    echo registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
) > "%CARGO_HOME%\config.toml"

REM 提示用户配置已完成
echo config.toml file has been created or updated in %CARGO_HOME%.

REM 提示用户重启命令行或计算机以使更改生效
echo RUSTUP_HOME and CARGO_HOME environment variables have been set.
echo Please restart your command line or computer to apply the changes.
pause