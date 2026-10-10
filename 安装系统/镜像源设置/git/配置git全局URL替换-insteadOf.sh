#!/usr/bin/env bash
# 来源: git/README.md
# 功能: 配置 git 全局 URL 替换(insteadOf)，让 github.com 的拉取走加速站
# 注意: insteadOf 会影响所有 git 拉取操作(包括 scoop bucket 同步)，
#       镜像站失效后会导致所有 git 操作报错，不建议长期使用

# 方式一(地址容易失效，且会影响所有 git 拉取操作，谨慎使用)
git config --global url."https://hub.fastgit.org".insteadOf https://github.com

# 方式二
git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com"

# GitHub 登录凭据走加速站
git config --global credential."https://githubfast.com".provider github
git config --global credential.https://githubfast.com.provider github

# 查看当前配置
git config --global --list

# 取消设置
# git config --global --unset url.https://github.com/.insteadof
