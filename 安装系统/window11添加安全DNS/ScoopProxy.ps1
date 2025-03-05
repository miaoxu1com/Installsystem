$env:http_proxy='http://127.0.0.1:7890'
$env:https_proxy='http://127.0.0.1:7890'
scoop config proxy 127.0.0.1:7890
# 暂不知晓curl 和 ping层面上检测代理是否成功,设置完临时代理，通过命令行界面已成功获得下载相关速度