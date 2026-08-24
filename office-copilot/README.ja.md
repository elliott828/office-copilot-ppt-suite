# Office Copilot の導入

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

このディレクトリは Microsoft 365 Copilot Agent Builder 向けのコピー＆ペースト導入キットです。Microsoft 365 Copilot は本リポジトリの Skills をインストールせず、3つの Agent Prompt と承認済み SharePoint ナレッジを使用します。

## 前提条件

- Agent Builder と承認済み SharePoint ドキュメント ライブラリ
- デスクトップ コンパイル用 Windows 版 PowerPoint
- 承認済みマクロ ポリシーと、信頼済みまたは署名済み `.pptm`/`.ppam` ホスト
- オーサリング、キュレーション、QA、セキュリティ、リリースの責任者

## 導入手順

1. `../shared-library-template/PPT-Skill-Library` を構造を変えず SharePoint にコピーします。
2. `python ../tools/configure_package.py --root-url "https://TENANT.sharepoint.com/sites/SITE/LIBRARY/PPT-Skill-Library" --output PATH` を実行するか、`{{SHARED_LIBRARY_ROOT_URL}}` を置換します。
3. Agent Builder で各 `*-agent-generator.txt` を別々の新規 Agent 会話に貼り付けます。
4. Authoring と QA は `Published/Current` のみを参照し、Curator は `Registry`、`Incoming`、`Draft`、`Test`、`Published/Current`、`Published/Releases` を参照できます。
5. Generator Prompt が使えない場合は、`instructions/` の対応ファイルを Instructions に直接貼り付けます。
6. `../skills/ppt-html-vba-compiler/vba/` から承認済みコンパイラ ホストを作成します。詳細は `references/compiler-host.md` を参照してください。
7. `../ppt-html/examples/sample-deck/deck.html` で非公開テストを行い、オブジェクト一覧を確認し、人の承認後に公開します。

Prompt の規範版は英語です。Agent はユーザーの言語で回答します。表示ラベルは翻訳できますが、パス、プレースホルダー、Schema キー、コマンド、バージョン文字列は翻訳しないでください。

## 実行フロー

ユーザー資料 → Authoring Agent → 制約付き PPT-HTML と manifest → 固定 VBA compiler → PowerPoint ネイティブ オブジェクト → QA Agent → 人の承認。

Copilot は成果物を準備・レビュー・説明しますが、デスクトップ VBA を実行したと主張してはいけません。外部 GitHub 内容は、出所・ライセンス確認、テスト、承認、変更不能な内部リリースの公開まで隔離します。
