# 环境变量配置

语言/工具的环境变量初始化脚本(setx 写入用户或系统环境变量):

| 脚本 | 内容 |
|---|---|
| [配置开发环境变量.ps1](配置开发环境变量.ps1) | 统一入口: `-C`(C_INCLUDE_PATH/CPLUS_INCLUDE_PATH 指向 scoop gcc)、`-Git`(GIT_INSTALL_ROOT 指向 scoop git)、`-Go`(GOPATH/GOROOT/PATH)、`-BetterCap`(系统级)、`-All` |

> 原 c.bat / git.bat / go.bat / 添加系统环境变量-BetterCap.ps1 已合并为上面的统一脚本。

[环境变量备份.reg](环境变量备份.reg)：完整的用户 + 系统环境变量导出备份（含 scoop/rust/uv/java 等全套路径），仅供恢复参考，导入前需按实际盘符修改。

## 相关

- rust 的 RUSTUP/CARGO 镜像环境变量见 [镜像源设置/rust](../镜像源设置/rust/)
- uv 的镜像环境变量见 [镜像源设置/uv](../镜像源设置/uv/)
