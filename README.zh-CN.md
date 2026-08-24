# Office Copilot PPT Agent Suite

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

这是一套可部署的能力包，面向无法安装社区 Skills、但可以使用 Microsoft 365 Copilot Agent 的企业环境，用于生成由 PowerPoint 原生对象组成、可继续编辑的演示文稿。

> 本仓库不是 Microsoft 365 Copilot 原生可安装的 Skill。它通过 Copilot Agents、受治理的 SharePoint 知识库、受约束的 PPT-HTML 格式和固定 VBA 编译器提供可复用能力。支持 `SKILL.md` 的平台可以安装 `skills/` 下的两个 Skills。

## 包含内容

| 组件 | 用途 |
|---|---|
| PPT Authoring Agent | 将对话以及 Word、PowerPoint、Excel、PDF、文本、HTML、Markdown 和图片资料转换成 16:9 PPT-HTML |
| PPT Skill Curator | 审阅外部演示文稿 Skills，并通过受控发布流程形成批准后的内部规范 |
| PPT QA Agent | 检查 Schema、原生对象可编辑性、几何位置、视觉一致性、内容准确性和无障碍要求 |
| PPT-HTML VBA Compiler Skill | 验证 PPT-HTML，并由固定 VBA 引擎将内嵌模型编译成 PowerPoint 原生对象 |
| Orchestrator Skill | 部署并维护整套 Office Copilot Agents |
| Shared Library 模板 | 提供 `Incoming`、`Draft`、`Test`、`Registry`、`Published/Current` 和不可变发布区 |

## 这套架构的底层逻辑

1. **从企业环境的限制出发。** 很多组织配备了 Microsoft 365 Copilot，却不允许安装社区 Skills、任意软件包或直接执行下载的代码。真正可用的扩展点通常只有 Copilot Agents、获批的 SharePoint 知识库和受控的桌面自动化。因此，本仓库按照这条边界设计，而不是假设用户拥有不受限制的开发环境。
2. **把 HTML 作为设计界面。** 现有演示文稿和网页生成方法最擅长在 HTML 与 CSS 中组织版式。固定的 16:9 画布可以让位置和尺寸保持可预测，因此先在 HTML 中完成视觉构图，再进入 PowerPoint 构造阶段。
3. **编译受约束的契约，不解析任意网页。** PPT-HTML 使用 960 × 540 坐标系，并内嵌语义化 JSON 模型。编译器读取这份模型，而不尝试反向推导完整的 DOM 和 CSS 层叠结果。这样才能让映射范围有限、可测试并且可以版本化。
4. **编译器保持固定。** Agent 会为每次请求生成不同的演示文稿模型，但不会重新编写 VBA 转换引擎。稳定的编译器可以集中审阅、签名、回归测试和批准，变化只留在演示文稿内容中。
5. **保留原生可编辑性，同时避免对象膨胀。** PowerPoint 对象模型允许时，一个语义视觉对象只生成一个 PowerPoint 对象。带文字的样式容器会生成一个含 `TextFrame2` 的 shape，而不是背景 shape 加独立文本框。表格和图表携带重建数据，因此可以继续作为原生表格和图表存在。
6. **通过治理流程内部化外部 Skills。** GitHub 上游 Skills 只作为不受信任的研究输入。Curator 记录来源和许可证，提取可用方法，完成兼容性测试和人工批准，再发布为内部规范。生产 Agents 只读取 `Published/Current`，上游变化不会无声影响日常制稿。
7. **分离不同职责。** 内容生成、规范维护、编译和 QA 有不同的失败模式与发布节奏，因此由不同 Agent 或能力负责，并使用明确的交接产物。Compiler 在完整流程中属于嵌套能力，但物理上以同级 Skill `$ppt-html-vba-compiler` 存放，确保它可以被独立发现和调用。
8. **以证据为准，不做乐观推断。** 未知 Schema 主版本和对象类型会触发失败关闭。视觉一致性需要渲染对比，原生可编辑性需要对象清单或直接检查，桌面编译需要输出文件和编译报告。语言模型只准备输入时，不能声称自己已经执行 VBA。

## Office Copilot 快速部署

1. 将 `shared-library-template/PPT-Skill-Library` 复制到批准使用的 SharePoint 文档库。
2. 把 `{{SHARED_LIBRARY_ROOT_URL}}` 替换成以 `PPT-Skill-Library` 结尾的 SharePoint URL。
3. 打开 Microsoft 365 Copilot Agent Builder，依次粘贴 `office-copilot/*-agent-generator.txt`。
4. 按每个 Generator Prompt 的说明添加知识库文件夹。
5. 使用 `skills/ppt-html-vba-compiler/vba/` 构建受信任的 `.pptm` 或 `.ppam` 编译器宿主。
6. 先完成私有测试，再共享 Agents。

具体步骤见 [Office Copilot 部署指南](office-copilot/README.zh-CN.md)。

## 安装 Skills

对于支持 `SKILL.md` 的平台，可以将以下一个或两个目录复制到 Skills 目录：

```text
skills/office-copilot-ppt-orchestrator
skills/ppt-html-vba-compiler
```

两个 Skill 均可独立调用：

```text
Use $office-copilot-ppt-orchestrator to configure this tenant's PPT agent suite.
Use $ppt-html-vba-compiler to validate and compile deck.html.
```

Compiler Skill 在逻辑上属于整个套件，但在目录和发现机制中保持独立，以保证平台能够稳定识别。

## 仓库结构

```text
office-copilot/           可复制到 Agent Builder 的 Prompts 和 Instructions
shared-library-template/  SharePoint 知识库与发布模板
ppt-html/                 Schema、映射契约和示例
skills/                   两个可独立安装的 Skills
docs/                     架构和治理文档
tools/                    配置与仓库验证工具
```

## 当前状态

本仓库处于早期实现阶段，已经包含 PPT-HTML Schema、确定性验证器、对象编译计划、VBA 源码、Agent Prompts、治理流程、QA 契约、测试和示例文件。桌面编译仍需组织批准的宏宿主和 Windows 版 Microsoft PowerPoint。复杂网页效果必须明确选择原生、SVG、栅格或不支持等降级方式。

发布前运行：

```powershell
python tools/validate_repository.py
python -m unittest discover -s skills/ppt-html-vba-compiler/tests -v
```

## 安全与治理

生产 Agents 只能读取 `Published/Current`。GitHub 内容以及 `Incoming`、`Draft`、`Test` 或历史发布区中的文件不能充当生产指令。引入外部更新前，必须完成来源和许可证记录、兼容性测试、人工批准、不可变发布快照和回滚方案。

宏只能在符合组织政策的受信任或已签名宿主中运行。遇到未知 Schema 主版本或未知对象类型时，编译器会中止，而不是自行猜测。

## 文档

- [Office Copilot 部署](office-copilot/README.zh-CN.md)
- [架构与治理](docs/architecture.zh-CN.md)
- [Skills 使用说明](skills/README.zh-CN.md)
- [PPT-HTML 示例](ppt-html/examples/sample-deck/deck.html)

## 许可证

项目自行编写的内容采用 MIT License。引入的 VBA 依赖保留各自的 MIT 声明，存放在 `skills/ppt-html-vba-compiler/vba/vendor/`。
