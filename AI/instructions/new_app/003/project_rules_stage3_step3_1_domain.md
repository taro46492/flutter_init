# 💻 第三段階：実装フェーズ — ステップ3-1: Domain層の実装

## 🏗️ 実装順序 — Domain
- [ ] AI/architecture/lib/features/1_domain/1_entities/instructions.md　を確認後　entities ファイル生成
- [ ] AI/architecture/lib/features/1_domain/2_repositories/instructions.md　を確認後　repositories ファイル生成
- [ ] AI/architecture/lib/features/1_domain/3_usecases/instructions.md　を確認後　usecases ファイル生成
- [ ] Domain層の例外処理ファイル生成（`exceptions/` ディレクトリ内）
- [ ] コード生成時の遵守事項確認
- [ ] ファイルパス・ファイル名明記でユーザー提示
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
- Domain層の実装が構造規則に準拠しているか検証
- ファイル命名規則を厳密にチェック
- 実装進捗をproject_status.mdに記録