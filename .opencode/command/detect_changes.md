---
description: ファイルの変更を検出して記録
agent: flutter
---

プロジェクト内のファイル変更を検出して `AI/logs/change_history.md` に記録します。

以下のコマンドを実行:
!`./AI/scripts/bash/detect_changes.sh`

## 検出内容

- ファイルの作成
- ファイルの変更
- ファイルの削除
- ディレクトリの作成（24時間以内）

実行結果を確認し、検出された変更を簡潔に報告してください。

## オプション

履歴をクリアする場合:
```bash
./AI/scripts/bash/detect_changes.sh --clear-history
```

古い履歴をアーカイブする場合（30日以上前）:
```bash
./AI/scripts/bash/detect_changes.sh --archive-old 30
```
