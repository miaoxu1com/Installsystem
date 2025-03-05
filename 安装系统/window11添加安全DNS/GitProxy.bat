# 设置ss
git config --global http.proxy socks5://127.0.0.1:7890
git config --global https.proxy socks5://127.0.0.1:7890
# 设置代理
git config --global https.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890
# Github代理 设置有意义的key为http.https://github.com.proxy值是socks5://127.0.0.1:7890
git config --global http.https://github.com.proxy socks5://127.0.0.1:7890