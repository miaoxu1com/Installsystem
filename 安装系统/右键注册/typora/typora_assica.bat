@echo off
:: 定义Typora的安装路径
set TyporaPath="E:\Develop\Typora\Typora.exe"

:: 创建文件类型关联
assoc .md=Markdown.Document

:: 设置程序打开方式
ftype Markdown.Document=%TyporaPath% "%%1"

:: 设置图标
reg add "HKEY_CLASSES_ROOT\.md" /ve /t REG_SZ /d "Markdown.Document"
reg add "HKEY_CLASSES_ROOT\Markdown.Document" /v "DefaultIcon" /t REG_SZ /d "%TyporaPath%,0"

:: 提示完成
echo .md files have been associated with Typora.
pause