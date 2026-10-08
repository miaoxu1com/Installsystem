# Obsidian PKMer 插件自动安装脚本

通过 **PKMer 国内 CDN 源**自动下载并安装 [PKMer 插件市场](https://pkmer.cn/products/market/) 插件，解决国内访问 Obsidian 官方社区插件市场困难的问题，全程**无需访问 GitHub**。

## 功能

- 自动检测本机所有 Obsidian 库（读取 `%APPDATA%\obsidian\obsidian.json`）
- 从 PKMer 国内源下载插件包：`https://pkmer.cn/_release/obsidian-pkmer.zip`
- 校验压缩包完整性（main.js / manifest.json / styles.css）
- 自动解压安装到每个库的 `.obsidian\plugins\obsidian-pkmer\` 目录
- 已安装过时执行覆盖更新，**不会删除插件配置**（`data.json`）

## 使用方法

### 自动检测所有库并安装

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-PKMer.ps1
```

### 只安装到指定的库

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-PKMer.ps1 -VaultPath "D:\valut\我的知识库"
```

## 安装后操作

脚本只负责把插件文件放到位，还需在 Obsidian 中手动启用：

1. 重启 Obsidian（完全退出再打开）
2. `设置` → `第三方插件` → 关闭「安全模式」
3. 在已安装插件列表中启用「PKMer」
4. 点插件设置中的「登录」，登录 PKMer 账号（[免费注册](https://pkmer.cn/)）

启用后点左侧边栏 PKMer 图标即可打开插件市场，通过国内 CDN 浏览、搜索、一键安装所有官方社区插件和主题。

## 注意事项

- 免费用户每月 100 次插件下载额度，会员 300 次/月
- 如果 Obsidian 正在运行且插件文件被占用导致解压失败，请先关闭 Obsidian 再运行脚本
- PKMer 只收录发布过正式版本号的社区插件，未上架的插件可配合 [BRAT](https://pkmer.cn/Pkmer-Docs/10-obsidian/obsidian社区插件/obsidian42-brat/) 使用
- 移动端安装参考：[PKMer 插件安卓端安装手把手教程](https://pkmer.cn/Pkmer-Docs/10-obsidian/obsidian社区插件/pkmer-market/pkmer插件安卓端安装手把手教程/)

## 环境要求

- Windows 10/11
- PowerShell 5.1+（系统自带）
- 已安装 Obsidian 并至少打开过一次

## 相关链接

- PKMer 官网：https://pkmer.cn/
- 插件介绍：https://pkmer.cn/products/market/
- 官方安装教程：https://pkmer.cn/show/20231208024655
