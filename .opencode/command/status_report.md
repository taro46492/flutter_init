---
description: プロジェクトステータスをチェックして更新（完全レポート）
agent: flutter
---

プロジェクトの完全レポートを生成します。以下をすべて実行:
1. プロジェクト状態のチェック
2. project_status.md の更新
3. current_structure.md のスナップショット生成

以下のコマンドを実行:
!`./AI/scripts/bash/status.sh check`
!`./AI/scripts/bash/status.sh update --yes`
!`./AI/scripts/bash/status.sh snapshot`

## 使用タイミング

- 新しい AI エージェントとの会話開始前
- 大きな実装を完了した後
- プロジェクト全体の状況を把握したい時

すべての処理が完了したら、カラフルなチェック結果、更新されたステータス、スナップショット結果を整理して報告してください。
