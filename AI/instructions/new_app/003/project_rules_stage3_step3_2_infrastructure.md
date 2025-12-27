# 💻 第三段階：実装フェーズ — ステップ3-2: Infrastructure層の実装

## 🏗️ 実装順序 — Infrastructure
- [ ] AI/architecture/lib/features/2_infrastructure/1_models/instructions.md　を確認後　models ファイル生成
- [ ] AI/architecture/lib/features/2_infrastructure/2_data_sources/1_local/instructions.md　を確認後　local インターフェイスファイル生成
- [ ] ローカルデータソースの実装ファイル生成（インターフェイスの具象実装）
- [ ] ローカルデータソースの例外処理ファイル生成（`2_data_sources/1_local/exceptions/` ディレクトリ内）
- [ ] AI/architecture/lib/features/2_infrastructure/2_data_sources/2_remote/instructions.md　を確認後　remote インターフェイスファイル生成
- [ ] リモートデータソースの実装ファイル生成（インターフェイスの具象実装）
- [ ] リモートデータソースの例外処理ファイル生成（`2_data_sources/2_remote/exceptions/` ディレクトリ内）
- [ ] AI/architecture/lib/features/2_infrastructure/3_repositories/instructions.md　を確認後　repositories ファイル生成
- [ ] `flutter analyze` 実行・検証

## ステータス管理とログ記録

### このステップで実行するコマンド

// turbo
```
# 構造検証（命名規則・ディレクトリ構造）
/validate_structure

# 実装内容をステータスに反映
/status update

# flutter analyzeで静的解析
/flutter_analyze
```

### 目的
- Infrastructure層の実装が構造規則に準拠しているか検証
- ファイル命名規則を厳密にチェック
- 実装進捗をproject_status.mdに記録