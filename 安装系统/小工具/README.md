# 小工具

## lanzou-dl.ps1 — 蓝奏云 CLI 下载器

输入蓝奏云分享地址（文件夹或单文件）+ 可选提取码，列出文件列表让你选择下载，默认下载到 `F:\迅雷下载`。

自动处理：阿里云盾 WAF 验证（acw_sc__v2）、提取码校验、2026 年 10 月新版 `/fn?` 内页 + 动态签名（wp_sign）、跳转链接等全部环节。

### 用法

```powershell
# 文件夹分享：列出文件后按序号选择
powershell -ExecutionPolicy Bypass -File .\lanzou-dl.ps1 -Url https://www.lanzoum.com/b0o0eakaj -Pwd 2grk

# 单文件直链（无需密码）
powershell -ExecutionPolicy Bypass -File .\lanzou-dl.ps1 -Url https://www.lanzoum.com/i8Gy74astj4f

# 只列出文件不下载
powershell -ExecutionPolicy Bypass -File .\lanzou-dl.ps1 -Url <地址> -Pwd <密码> -ListOnly

# 全部下载 / 选第 1、3 个 / 选 1-3
-Select all
-Select 1,3
-Select 1-3
```

### 参数

| 参数 | 默认 | 说明 |
|---|---|---|
| `-Url` | （必填） | 蓝奏云分享地址 |
| `-Pwd` | 空 | 提取码 |
| `-Select` | 交互询问 | `all` / `1,3` / `1-3` |
| `-ListOnly` | 关 | 只列出文件 |
| `-OutDir` | `F:\迅雷下载` | 下载目录 |

### 环境要求

- Windows 10/11，PowerShell 5.1+
- 无需登录蓝奏云账号
