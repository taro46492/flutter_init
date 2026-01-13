---
description: ディレクトリ構造の違反を検出
agent: flutter
---

`lib/`以下のディレクトリ構造が定義に準拠しているかを検証します。
違反があれば `AI/logs/structure_violations.md` に記録されます。

以下のコマンドを実行:
!`./AI/scripts/bash/validate_structure.sh`

## 検証内容

- `lib/` 直下の構造
- `lib/core/` 配下のディレクトリ
- `lib/features/` 配下の各フィーチャーの層構造
- Domain, Infrastructure, Application, Presentation 層の構造

検証結果を確認し、違反が見つかった場合は内容を詳しく報告してください。

## 違反が見つかった場合

1. `AI/logs/structure_violations.md` を確認
2. 違反の内容と推奨アクションを確認
3. 構造を修正
4. 再度検証を実行

すべて解消したら、違反ログをクリア:
```bash
./AI/scripts/bash/validate_structure.sh --clear-violations
```
