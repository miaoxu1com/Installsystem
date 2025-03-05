@echo off
set pnmp_dir=E:\Develop\Node\pnpm-store
REM 创建pnpm-store目录（如果不存在）
if not exist "%pnmp_dir%" (
    mkdir "%pnmp_dir%"
)

if not exist "%pnmp_dir%\global" (
    mkdir "%pnmp_dir%\global"
)
if not exist "%pnmp_dir%\cache" (
    mkdir "%pnmp_dir%\cache"
)
if not exist "%pnmp_dir%\state" (
    mkdir "%pnmp_dir%\state"
)
if not exist "%pnmp_dir%\store" (
    mkdir "%pnmp_dir%\store"
)
# 基本目录、可执行文件目录
pnpm config set global-bin-dir=E:\Develop\Node\pnpm-store
# 全局包目录
pnpm config set global-dir=E:\Develop\Node\pnpm-store\global
# 缓存目录
pnpm config set cache-dir=E:\Develop\Node\pnpm-store\cache
# 状态文件目录
pnpm config set state-dir=E:\Develop\Node\pnpm-store\state
# 依赖包文件目录
pnpm config set store-dir=E:\Develop\Node\pnpm-store\store
pause