@echo off
REM 设置PYTHON_BUILD_MIRROR_URL环境变量
setx PYTHON_BUILD_MIRROR_URL "https://jedore.netlify.app/tools/python-mirrors/" /M

REM 设置UV_PYTHON_INSTALL_MIRROR环境变量
setx UV_PYTHON_INSTALL_MIRROR "https://mirror.ghproxy.com/https://github.com/indygreg/python-build-standalone/releases/download" /M

REM 设置UV_DEFAULT_INDEX环境变量
setx UV_DEFAULT_INDEX "https://mirrors.ustc.edu.cn/pypi/simple" /M

pause