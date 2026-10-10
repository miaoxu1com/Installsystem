# 来源: scoop/README.md
# 功能: 添加 spc bucket(约 1 万个软件清单)并切换到 main 分支，安装基础工具
# spc 是 lzwme/scoop-proxy-cn 的 Gitee 镜像

# 添加 spc bucket
scoop bucket add spc https://gitee.com/wlzwme/scoop-proxy-cn.git

# 进入 spc 目录(默认安装路径；自定义安装目录时改成你的路径)
cd "$env:USERPROFILE\scoop\buckets\spc"

# 切换到 main 分支(该仓库默认分支不是 master，不切换会导致清单拉取异常)
git fetch --all; git checkout -b main origin/main

# 推荐安装基础工具
scoop install spc/7zip spc/aria2 spc/scoop-search
