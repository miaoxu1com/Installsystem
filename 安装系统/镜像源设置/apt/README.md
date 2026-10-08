# apt 镜像源（Ubuntu/Debian）

## 替换为中科大镜像

```bash
# sudo add-apt-repository --remove "deb http://archive.ubuntu.com/ubuntu jammy InRelease"
sudo add-apt-repository "deb http://mirrors.ustc.edu.cn/ubuntu jammy main"
```

## 相关

- WSL 环境配置见 window-dev 仓库 [wsl/README.md](https://github.com/miaoxu1com/window-dev/tree/main/wsl)
- Docker 安装与镜像见本目录 [docker/README.md](../docker/README.md)
