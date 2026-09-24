# 数据结构

- `schema_version(version)`：数据库版本，初始为 1。
- `projects`：`id` UUID 主键、名称、类型、城市、地址、联系人、创建与修改时间、状态、JSON 数据。
- JSON 数据 `fields`：按 PDF 原始中文字段名保存普通表单字段。
- `shareholders`：股东名称、比例、出资金额、治理条款数组。
- `investments`：投资项目、金额、含税、浮动区间、备注数组。
- `images`、`attachments`、`videos`：按影像位或清单项索引资产元数据；资产实体在项目目录下。
- `richtext`：富文本 HTML；粘贴图片位于 `richtext-assets/`。

每个资产记录有 UUID、原文件名、项目内相对路径、字节大小、类型和可选备注。项目包含 `project.json`、`assets/`，清单含格式标识、数据版本、软件版本和导出时间。项目包导入会校验格式版本与路径。
