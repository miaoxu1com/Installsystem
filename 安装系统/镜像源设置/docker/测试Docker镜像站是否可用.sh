#!/usr/bin/env bash
# 来源: docker/README.md
# 功能: 测试 Docker Hub 镜像站是否可用(以网易镜像为例，测试通过后可写入 daemon.json 永久生效)

docker pull hub-mirror.c.163.com/library/nginx:latest
