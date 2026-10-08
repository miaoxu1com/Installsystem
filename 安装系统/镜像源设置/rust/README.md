# Rust 镜像源

## rustup 清华镜像（环境变量）

```powershell
$env:RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
$env:RUSTUP_UPDATE_ROOT = "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
```

## 其他

- [rsproxy.cn（字节跳动 Rust 镜像，含 rustup/crates 换源教程）](https://rsproxy.cn/#getStarted)
- [cargo 换源教程](https://books.niqin.com/read/rust-guide/zh-cn/4-cargo/4.1-source-replacement.html)

## 相关

- Rust 安装指南类链接见 soft 仓库 [软件.md](https://github.com/miaoxu1com/soft/blob/main/软件.md) 的 Rust 环境安装一节

## 脚本

- [rust.bat](rust.bat)：一键写入 RUSTUP/CARGO 环境变量 + 生成 ustc cargo config.toml
- [uninstall_rust.bat](uninstall_rust.bat)：rustup self uninstall
