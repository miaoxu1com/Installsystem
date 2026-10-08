# 环境变量配置

语言/工具的环境变量初始化脚本（setx 写入用户或系统环境变量）：

| 脚本 | 内容 |
|---|---|
| [c.bat](c.bat) | C_INCLUDE_PATH / CPLUS_INCLUDE_PATH 指向 scoop gcc |
| [git.bat](git.bat) | GIT_INSTALL_ROOT 指向 scoop git |
| [go.bat](go.bat) | GOPATH / GOROOT / PATH |

[环境变量备份.reg](环境变量备份.reg)：完整的用户 + 系统环境变量导出备份（含 scoop/rust/uv/java 等全套路径），仅供恢复参考，导入前需按实际盘符修改。

## 相关

- rust 的 RUSTUP/CARGO 镜像环境变量见 [镜像源设置/rust](../镜像源设置/rust/)
- uv 的镜像环境变量见 [镜像源设置/uv](../镜像源设置/uv/)
