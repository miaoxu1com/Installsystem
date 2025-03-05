#  http.proxy代表的是key
# 查看代理设置
git config --global --get http.proxy
git config --global --get https.proxy
# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy