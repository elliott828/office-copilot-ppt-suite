# Skills 使用说明

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

可将以下任一完整目录复制到兼容 `SKILL.md` 的 Agent 运行环境：

- `office-copilot-ppt-orchestrator`：配置 Copilot Agents、共享知识库、治理、制稿合同和 QA 流程。
- `ppt-html-vba-compiler`：可独立验证 PPT-HTML、生成确定性编译计划，并在可用时调用获批的固定 VBA host。

```text
Use $office-copilot-ppt-orchestrator to prepare this tenant's deployment bundle.
Use $ppt-html-vba-compiler to validate deck.html and compile it with the approved host.
```

Orchestrator 可以把已验证的 HTML 交给 Compiler，但两个目录保持同级，因为并非所有运行时都能发现嵌套 Skill。Compiler 不得重新设计页面、猜测未知类型、为每份文档注入新 VBA，也不能在没有输出证据时声称编译成功。

Microsoft 365 Copilot 用户不安装这些 Skills，而是使用 `../office-copilot/` 中可复制的文件，通过 Agent Instructions 和 SharePoint 知识内部化同一套合同。
