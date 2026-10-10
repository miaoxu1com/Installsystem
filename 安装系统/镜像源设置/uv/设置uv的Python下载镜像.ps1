# 来源: uv/README.md
# 功能: 设置 uv 的 Python Standalone 构建下载镜像(仅当前会话生效，永久生效见同目录 python_uv_mirror.bat)

# 主镜像
$env:UV_PYTHON_INSTALL_MIRROR = "https://gh.xmly.dev/https://github.com/astral-sh/python-build-standalone/releases/download"

# 备选镜像
# $env:UV_PYTHON_INSTALL_MIRROR = "https://mirror.ghproxy.com/https://github.com/indygreg/python-build-standalone/releases/download"
