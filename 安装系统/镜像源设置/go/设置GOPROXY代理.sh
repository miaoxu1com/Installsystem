#!/usr/bin/env bash
# 来源: go/README.md
# 功能: 设置 Go 模块代理 GOPROXY (Linux/macOS)

export GOPROXY=https://goproxy.io,direct
# 不走 proxy 的私有仓库或组，多个用逗号相隔(可选)
export GOPRIVATE=git.mycompany.com,github.com/my/private
