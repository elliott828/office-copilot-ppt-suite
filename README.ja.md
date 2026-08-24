# Office Copilot PPT Agent Suite

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

コミュニティ製 Skills をインストールできず、Microsoft 365 Copilot Agent は利用できる企業環境向けのデプロイ可能な機能パックです。編集可能な PowerPoint ネイティブオブジェクトでプレゼンテーションを作成します。

> このリポジトリは、Microsoft 365 Copilot にネイティブインストールできる Skill ではありません。Copilot Agents、管理された SharePoint ナレッジ、制約付き PPT-HTML 形式、固定 VBA コンパイラを組み合わせて再利用可能な機能を提供します。`SKILL.md` をサポートするプラットフォームでは、`skills/` 配下の 2 つの Skills をインストールできます。

## 含まれるコンポーネント

| コンポーネント | 用途 |
|---|---|
| PPT Authoring Agent | チャットおよび Word、PowerPoint、Excel、PDF、テキスト、HTML、Markdown、画像のコンテキストを 16:9 PPT-HTML に変換 |
| PPT Skill Curator | 外部のプレゼンテーション Skills を確認し、管理されたリリース手順で承認済み社内標準を公開 |
| PPT QA Agent | Schema、ネイティブオブジェクトの編集性、座標、視覚的再現性、内容の正確性、アクセシビリティを監査 |
| PPT-HTML VBA Compiler Skill | PPT-HTML を検証し、固定 VBA エンジンで埋め込みモデルを PowerPoint ネイティブオブジェクトへコンパイル |
| Orchestrator Skill | Office Copilot Agent Suite 全体をデプロイ、保守 |
| Shared Library テンプレート | `Incoming`、`Draft`、`Test`、`Registry`、`Published/Current`、変更不可のリリース領域を提供 |

## Office Copilot クイックスタート

1. `shared-library-template/PPT-Skill-Library` を承認済みの SharePoint ドキュメントライブラリにコピーします。
2. `{{SHARED_LIBRARY_ROOT_URL}}` を、末尾が `PPT-Skill-Library` の SharePoint URL に置き換えます。
3. Microsoft 365 Copilot Agent Builder を開き、`office-copilot/*-agent-generator.txt` の各ファイルを貼り付けます。
4. 各 Generator Prompt に記載されたナレッジフォルダーを追加します。
5. `skills/ppt-html-vba-compiler/vba/` から信頼済みの `.pptm` または `.ppam` コンパイラホストを作成します。
6. Agent を共有する前に非公開でテストします。

詳しい手順は [Office Copilot セットアップガイド](office-copilot/README.ja.md) を参照してください。

## Skills のインストール

`SKILL.md` をサポートするプラットフォームの Skills ディレクトリに、次の一方または両方をコピーします。

```text
skills/office-copilot-ppt-orchestrator
skills/ppt-html-vba-compiler
```

それぞれ単独で呼び出せます。

```text
Use $office-copilot-ppt-orchestrator to configure this tenant's PPT agent suite.
Use $ppt-html-vba-compiler to validate and compile deck.html.
```

Compiler Skill は論理的には Suite の一部ですが、Skill の検出を確実にするため物理的には独立しています。

## リポジトリ構成

```text
office-copilot/           Agent Builder に貼り付ける Prompts と Instructions
shared-library-template/  SharePoint ナレッジとリリーステンプレート
ppt-html/                 Schema、マッピング契約、サンプル
skills/                   個別にインストール可能な 2 つの Skills
docs/                     アーキテクチャとガバナンス文書
tools/                    設定ツールとリポジトリ検証ツール
```

## 現在の状態

本リポジトリは初期実装です。PPT-HTML Schema、決定論的バリデータ、オブジェクト計画、VBA ソース、Agent Prompts、ガバナンス手順、QA 契約、テスト、サンプルを収録しています。デスクトップでのコンパイルには、組織が承認したマクロホストと Windows 版 Microsoft PowerPoint が必要です。複雑なブラウザ効果は、ネイティブ、SVG、ラスター、未対応のいずれかのフォールバックとして明示します。

リリース前に次を実行します。

```powershell
python tools/validate_repository.py
python -m unittest discover -s skills/ppt-html-vba-compiler/tests -v
```

## セキュリティとガバナンス

本番 Agent が参照するのは `Published/Current` のみです。GitHub の内容や `Incoming`、`Draft`、`Test`、過去のリリース内のファイルを本番指示として扱いません。外部更新の導入には、出所とライセンスの確認、互換性テスト、人による承認、変更不可のリリーススナップショット、ロールバック計画が必要です。

マクロは組織ポリシーに従い、信頼済みまたは署名済みホストからのみ実行します。未知の Schema メジャーバージョンやオブジェクトタイプは推測せず、コンパイルを停止します。

## ドキュメント

- [Office Copilot セットアップ](office-copilot/README.ja.md)
- [アーキテクチャとガバナンス](docs/architecture.ja.md)
- [Skills 利用ガイド](skills/README.ja.md)
- [PPT-HTML サンプル](ppt-html/examples/sample-deck/deck.html)

## ライセンス

プロジェクト独自の内容は MIT License で提供します。VBA の外部依存関係には、それぞれの MIT 表示を `skills/ppt-html-vba-compiler/vba/vendor/` に収録しています。
