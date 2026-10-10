#!/usr/bin/env bash
# 来源: apt/README.md
# 功能: 将 Ubuntu apt 源替换为中科大(USTC)镜像，示例版本代号为 jammy，其他版本替换代号即可

# 如需先移除官方源，取消下一行注释
# sudo add-apt-repository --remove "deb http://archive.ubuntu.com/ubuntu jammy InRelease"
sudo add-apt-repository "deb http://mirrors.ustc.edu.cn/ubuntu jammy main"
