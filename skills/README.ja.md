# Skills の使用方法

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

次の完全なディレクトリを `SKILL.md` 対応 Agent ランタイムの Skills 保存先にコピーできます。

- `office-copilot-ppt-orchestrator`: Copilot Agents、共有ライブラリ、ガバナンス、作成契約、QA を設定します。
- `ppt-html-vba-compiler`: PPT-HTML を単独で検証し、決定論的なコンパイル計画を作り、利用可能なら承認済み固定 VBA host を呼び出します。

```text
Use $office-copilot-ppt-orchestrator to prepare this tenant's deployment bundle.
Use $ppt-html-vba-compiler to validate deck.html and compile it with the approved host.
```

Orchestrator は検証済み HTML を Compiler に渡せますが、両ディレクトリは同列です。入れ子の Skill を発見できないランタイムがあるためです。Compiler は再デザイン、未知型の推測、文書ごとの VBA 注入、証拠のない成功報告を行いません。

Microsoft 365 Copilot では Skills をインストールせず、`../office-copilot/` のコピー用ファイルを使い、同じ契約を Agent Instructions と SharePoint ナレッジに組み込みます。
