# 项目投资资料管理工具

本项目是离线 Electron 桌面应用，基于《项目投资资料在线提交表.pdf》的 10 页字段建立。源文件位于 `main/`、`renderer/`、`shared/`。正式运行时不需要浏览器、网址、账号或服务器。

## 开发与构建

安装 Node.js 22+ 与 pnpm，执行 `pnpm install`、`pnpm build`。开发时可执行 `pnpm dev`。Windows 安装包执行 `pnpm pack:win`。Apple Silicon 安装包由 GitHub Actions 的 **Build and release macOS app** 工作流在 arm64 Runner 上构建。推送版本标签后，工作流运行测试、生成 DMG，并对 DMG 内的 `.app` 检查 Info.plist、Electron Framework、Helper、资源、原生模块、arm64 架构与签名。发布附件只有 `Project-Investment-Manager-mac-arm64.dmg`。

目前 macOS 包使用 ad-hoc 签名。这能检查包内代码的完整性，但不能代替 Apple Developer ID 签名和公证；从网络下载后的 Gatekeeper 检查仍可能拒绝它。工作流记录 `spctl` 的真实结果，不把临时签名的完整性检查当成可在其他 Mac 正常打开的证明。若要求下载后直接双击运行，需要 Developer ID 签名及 Apple 公证。

## 数据位置

Windows：`%APPDATA%/项目投资资料管理工具/`。macOS：`~/Library/Application Support/项目投资资料管理工具/`。其中 `database/app.db` 保存字段和索引，`projects/<项目ID>/` 保存图片、附件、视频及富文本图片，`backups/` 保存数据库备份，`app.log` 保存错误日志。升级安装包不会清空这些目录。

每日首次启动自动备份数据库并保留最近 7 份。首页“备份与恢复”可立即备份或恢复；恢复前会再次备份当前数据库。完整迁移建议使用每个项目的 `.sjproject` 项目包，该文件包含结构化字段和全部资产。

## 版本与旧版

数据库含 `schema_version` 表；后续数据库改动应在启动时逐版本迁移，不得删除原数据。旧网页版 ZIP 因缺少真实样本，仅保留导入适配入口；目前导入器会明确拒绝未知结构。

## 注意

桌面应用安装包应在目标平台构建。Windows 主机不能可靠产出可运行的 macOS `.dmg`。视频超过 100MB 只提示，不强行删除；原 PDF 同时写有“≤2 分钟”和“建议连续拍摄 3–5 分钟”，此冲突按建议提示处理。
