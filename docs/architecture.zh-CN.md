# 架构与治理

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [日本語](architecture.ja.md) | [Français](architecture.fr.md) | [Español](architecture.es.md)

本套件把概率性的内容工作与确定性的文档构造分开。Authoring Agent 理解混合文件和对话，只应用经批准的内部规范并输出受限 PPT-HTML；固定 compiler 验证内嵌 JSON 模型并创建 PowerPoint 原生对象；QA Agent 检查意图和证据；Curator 在日常制稿会话之外更新规范。

```text
来源 -> Authoring Agent -> PPT-HTML -> validator/plan -> 固定 VBA host -> PPTX -> QA
                               ^
GitHub -> 隔离 -> Curator -> 测试/批准 -> Published/Current
```

Compiler 在流程上嵌套于总控能力，物理上则是同级独立 Skill `$ppt-html-vba-compiler`，因此可单独验证和编译，也不会因藏在另一个 Skill 目录中而无法发现。

PowerPoint 支持时，一个语义视觉对象应对应一个原生对象。带文字的 HTML 容器映射为一个含 `TextFrame2` 的 shape；图表和表格携带重建数据并生成原生对象。不支持的效果必须明确声明 native、SVG、raster 或 unsupported fallback。

`Published/Current` 是唯一生产知识面。每个版本记录来源、许可证、Schema/compiler 兼容性、测试、批准人、不可变快照和回滚目标。不能使用 Git 时，由 SharePoint 版本历史、发布目录、登记表、哈希、批准字段和保留策略构成可审计版本控制。定时 Power Automate、获批服务或人工检查只能建立 `Incoming` 项，不能自动发布。

外部仓库和文档内容被视为数据而非可信指令；宏只从获批或签名宿主运行；未知主版本和对象类型关闭失败。视觉一致性必须有渲染对比，原生可编辑性必须有对象清单或直接检查。
