# Office Copilot 部署

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

本目录是 Microsoft 365 Copilot Agent Builder 的复制部署包。Microsoft 365 Copilot 不安装仓库中的 Skills，而是使用三个 Agent Prompt 和经批准的 SharePoint 知识。

## 前提

- Microsoft 365 Copilot Agent Builder 和获批的 SharePoint 文档库
- 用于桌面编译的 Windows 版 PowerPoint
- 获批的宏策略，以及可信或已签名的 `.pptm`/`.ppam` 编译宿主
- 明确的创作、策展、QA、安全和发布负责人

## 部署

1. 将 `../shared-library-template/PPT-Skill-Library` 原样复制到 SharePoint。
2. 运行 `python ../tools/configure_package.py --root-url "https://TENANT.sharepoint.com/sites/SITE/LIBRARY/PPT-Skill-Library" --output PATH`，或手动替换 `{{SHARED_LIBRARY_ROOT_URL}}`。
3. 在 Agent Builder 中，分别把三个 `*-agent-generator.txt` 粘贴到新的 Agent 对话中；生成器会返回名称、说明、Instructions、知识路径和测试提示词。
4. Authoring 和 QA Agent 只能读取 `Published/Current`；Curator 可访问 `Registry`、`Incoming`、`Draft`、`Test`、`Published/Current` 和 `Published/Releases`。
5. 如果租户不能使用生成器，直接把 `instructions/` 下对应文件粘贴进 Instructions 字段。
6. 用 `../skills/ppt-html-vba-compiler/vba/` 建立获批的编译宿主，详见其 `references/compiler-host.md`。
7. 用 `../ppt-html/examples/sample-deck/deck.html` 做私有测试，检查对象清单，经人工批准后再发布。

`Published/Current` 现在还包含 Style Catalog、匹配规则、图表设计标准、视觉 HTML 画廊和可编译的图表模板。升级已有部署时，需要用 `instructions/` 下的新版本替换三个 Agent 的 Instructions，确认知识源完成刷新，私有测试后重新发布每个 Agent。只更新 SharePoint 知识文件不会自动替换 Agent Instructions。

Prompt 以英文作为规范源，以便一套受控文本服务多语言租户；Agent 已被要求使用用户语言回答。可以本地化显示名称，但不要翻译路径、占位符、Schema 键、命令和版本号。

## 运行流程

用户上下文 → 风格匹配 → Authoring Agent → 受限 PPT-HTML 与 manifest → 固定 VBA compiler → PowerPoint 原生对象 → QA Agent → 人工批准。

Copilot 负责准备、审阅和解释产物，不能声称自己执行了桌面 VBA。外部 GitHub 内容必须先隔离，由 Curator 记录来源和许可证、测试、取得批准并发布不可变内部版本。
