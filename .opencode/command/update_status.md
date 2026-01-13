---
description: project_status.mdを現在の状態で自動更新
agent: flutter
---

プロジェクトの現在状態を検出して `AI/logs/project_status.md` を自動更新します。

以下のコマンドを実行:
!`./AI/scripts/bash/status.sh update --yes`

## 更新内容

- 最終更新日時
- Core コンポーネントの状態
- エントリポイントの状態
- Flutter プロジェクトの初期化状態
- ドキュメントの状態
- Features の数

更新が完了したら、変更内容を確認して報告してください。

## 注意

このコマンドは `--yes` フラグで自動承認モードで実行されます。
手動で確認したい場合は、直接スクリプトを実行してください:
```bash
./AI/scripts/bash/update_status.sh
```
