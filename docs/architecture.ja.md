# アーキテクチャとガバナンス

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [日本語](architecture.ja.md) | [Français](architecture.fr.md) | [Español](architecture.es.md)

本スイートは確率的な内容作成と決定論的な文書構築を分離します。Authoring Agent は複数形式の資料と会話を理解し、承認済み内部標準だけを適用して制約付き PPT-HTML を出力します。固定 compiler は埋め込み JSON を検証し、PowerPoint ネイティブ オブジェクトを作成します。QA Agent は意図と証拠を確認し、Curator は通常の作成セッション外で標準を更新します。

```text
資料 -> Authoring Agent -> PPT-HTML -> validator/plan -> 固定 VBA host -> PPTX -> QA
                               ^
GitHub -> 隔離 -> Curator -> テスト/承認 -> Published/Current
```

Compiler はワークフロー上は入れ子ですが、パッケージ上は同列の独立 Skill `$ppt-html-vba-compiler` です。これにより単独利用でき、Skill 探索も安定します。

可能な限り、一つの意味的な視覚要素を一つのネイティブ オブジェクトにします。テキスト付きコンテナは `TextFrame2` を持つ一つの shape、表とグラフは再構築データからネイティブ オブジェクトになります。未対応効果には native、SVG、raster、unsupported の fallback を明示します。

本番知識は `Published/Current` のみです。各リリースは出所、ライセンス、互換性、テスト、承認者、変更不能なスナップショット、ロールバック先を記録します。Git がない場合は SharePoint の版履歴、リリース フォルダー、台帳、ハッシュ、承認項目、保持ポリシーを使います。定期処理は `Incoming` を作成できますが、自動公開はできません。

外部リポジトリと文書は信頼済み命令ではなくデータです。マクロは承認済みまたは署名済みホストのみで実行し、未知の Schema メジャー版や型は拒否します。忠実度にはレンダー比較、編集可能性にはオブジェクト一覧または直接確認が必要です。
