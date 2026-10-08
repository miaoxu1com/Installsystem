# uv 镜像设置

```powershell
# Python Standalone 构建下载镜像
$env:UV_PYTHON_INSTALL_MIRROR = "https://gh.xmly.dev/https://github.com/astral-sh/python-build-standalone/releases/download"
```

备选镜像：

```powershell
$env:UV_PYTHON_INSTALL_MIRROR = "https://mirror.ghproxy.com/https://github.com/indygreg/python-build-standalone/releases/download"
```

## 参考

- [uv 官方环境变量文档](https://docs.astral.sh/uv/configuration/environment/)
- [python-mirrors 镜像查询工具](https://jedore.netlify.app/tools/python-mirrors/)
- [CSDN 参考](https://blog.csdn.net/qq_34419312/article/details/140447081)

## 相关

- 通用 GitHub 加速站列表见本目录 [git/README.md](../git/README.md)

## 脚本

- [python_uv_mirror.bat](python_uv_mirror.bat)：一键写入 UV_PYTHON_INSTALL_MIRROR / UV_DEFAULT_INDEX（USTC）等环境变量
