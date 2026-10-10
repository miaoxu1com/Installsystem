# Docker 国内镜像配置

## 安装 Docker（中科大镜像）

参考 [USTC Docker CE 帮助](https://mirrors.ustc.edu.cn/help/docker-ce.html)。

脚本已提取至: [安装Docker-中科大镜像.sh](安装Docker-中科大镜像.sh)

## 替换 Docker Hub 镜像

镜像站列表：

- [docker.xuanyuan.me](https://docker.xuanyuan.me/)
- [DockerHub 镜像汇总](https://fcp7.com/docker-dockerhub-mirrors.html)

测试镜像是否可用: [测试Docker镜像站是否可用.sh](测试Docker镜像站是否可用.sh)

临时配置（通过 `--registry-mirror` 指定镜像源地址）：

```bash
docker pull 镜像名称 --registry-mirror=国内镜像源地址
```

测试可用后可写入 daemon.json 永久生效。

## 相关

- apt 镜像源（Ubuntu/Debian）见本目录 [apt/README.md](../apt/README.md)
