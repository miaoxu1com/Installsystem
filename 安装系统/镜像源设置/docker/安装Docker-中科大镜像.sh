#!/usr/bin/env bash
# 来源: docker/README.md
# 功能: 通过中科大(USTC)镜像安装 Docker CE
# 参考: https://mirrors.ustc.edu.cn/help/docker-ce.html

curl -fsSL https://get.docker.com -o get-docker.sh
sudo DOWNLOAD_URL=https://mirrors.ustc.edu.cn/docker-ce sh get-docker.sh
