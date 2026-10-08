# Docker 国内镜像配置

## 安装 Docker（中科大镜像）

参考 [USTC Docker CE 帮助](https://mirrors.ustc.edu.cn/help/docker-ce.html)，一起复制下面两行命令：

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo DOWNLOAD_URL=https://mirrors.ustc.edu.cn/docker-ce sh get-docker.sh
```

## 替换 Docker Hub 镜像

镜像站列表：

- [docker.xuanyuan.me](https://docker.xuanyuan.me/)
- [DockerHub 镜像汇总](https://fcp7.com/docker-dockerhub-mirrors.html)

测试镜像是否可用：

```bash
docker pull hub-mirror.c.163.com/library/nginx:latest
```

临时配置（通过 `--registry-mirror` 指定镜像源地址）：

```bash
docker pull 镜像名称 --registry-mirror=国内镜像源地址
```

测试可用后可写入 daemon.json 永久生效。

## 相关

- apt 镜像源（Ubuntu/Debian）见本目录 [apt/README.md](../apt/README.md)
