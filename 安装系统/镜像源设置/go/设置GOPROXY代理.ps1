# 来源: go/README.md
# 功能: 设置 Go 模块代理 GOPROXY (Windows PowerShell，仅当前会话生效)

$env:GOPROXY = "https://goproxy.io,direct"
# 不走 proxy 的私有仓库或组，多个用逗号相隔(可选)
$env:GOPRIVATE = "git.mycompany.com,github.com/my/private"
