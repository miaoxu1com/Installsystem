#!/usr/bin/env bash
# 来源: go/README.md
# 功能: Arch Linux 安装 AUR 助手 yay 时走 GOPROXY 国内代理

git clone https://aur.archlinux.org/yay
cd yay
GOPROXY=https://goproxy.cn makepkg -si
