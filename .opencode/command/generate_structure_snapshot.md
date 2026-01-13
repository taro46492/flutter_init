---
description: 現在のプロジェクト構造のスナップショットを生成
agent: flutter
---

現在の`lib/`構造をスナップショットとして `AI/document/current_structure.md` に出力します。

以下のコマンドを実行:
!`./AI/scripts/bash/status.sh snapshot`

## 出力内容

- `lib/` 配下の全ディレクトリとファイルの構造
- 各フィーチャーの統計情報（層ごとのファイル数）
- 総ファイル数・ディレクトリ数
- 生成日時

スナップショット生成が完了したら、簡潔に結果を報告してください。

出力先: `AI/document/current_structure.md` (自動上書き)
