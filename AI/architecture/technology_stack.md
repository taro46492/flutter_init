# 技術スタック (Technology Stack)

Flutterアプリケーション開発における**基盤パッケージ**の一覧です。
ここに記載されたパッケージは、すべてのプロジェクトで共通して使用されます。

> 機能・用途別の推奨パッケージは [recommended_packages.md](recommended_packages.md) を参照してください。

## 主要ライブラリ一覧

| カテゴリ | 主要ライブラリ | 役割 |
|----------|----------------|------|
| 状態管理 | hooks_riverpod | DIコンテナとして機能し、アプリケーション全体の状態を安全に管理する。Flutter Hooks統合版。 |
| データモデル | freezed | イミュータブルなデータクラス（エンティティ）とユニオンを生成する。 |
| 画面遷移 | go_router | 型安全で宣言的なパスベースのルーティングを実現する。 |
| ローカルDB | drift | 型安全で高性能なローカルデータベースとして、オフライン対応やデータ永続化を担う。 |
| UI補助 | flutter_hooks | ウィジェットのローカル状態を簡潔に管理するためのフックを提供する。 |
| ログ | logger | 構造化されたログ出力を提供する。 |

## 各ライブラリの詳細

### 状態管理: Riverpod (hooks_riverpod)

- **hooks_riverpod**: Riverpod + Flutter Hooks 統合パッケージ（`flutter_riverpod` を内包）
- **riverpod_annotation**: コード生成用アノテーション（`riverpod_generator` と対で使用）
- **特徴**:
  - 型安全な依存性注入
  - テストしやすい設計
  - コンパイル時エラー検出
  - 自動的なメモリ管理

### データモデル: Freezed

- **freezed_annotation**: ランタイム用アノテーション
- **json_annotation**: JSON シリアライゼーション用アノテーション
- **特徴**:
  - イミュータブルなデータクラス
  - copyWithメソッドの自動生成
  - JSON シリアライゼーション対応
  - パターンマッチング対応

### 画面遷移: GoRouter

- **用途**: アプリケーションのルーティング管理
- **特徴**:
  - 型安全なナビゲーション
  - 宣言的なルート定義
  - ディープリンク対応
  - ネストしたルーティング

### ローカルDB: Drift

- **drift**: ORM / クエリビルダー
- **sqlite3_flutter_libs**: ネイティブSQLiteバイナリ（iOS/Android向け）
- **path_provider**: ファイルパス取得
- **path**: パス操作ユーティリティ
- **特徴**:
  - 型安全なクエリビルダー
  - コンパイル時のSQL検証
  - 自動生成されるDAOクラス
  - リアクティブなクエリ（Stream対応）
  - マイグレーション管理
  - マルチプラットフォーム対応

### UI補助: Flutter Hooks

- **用途**: ウィジェットのローカル状態管理
- **特徴**:
  - useState, useEffect等のフック提供
  - ライフサイクル管理の簡素化
  - 再利用可能なロジック
  - メモリリークの防止

### ログ: Logger

- **用途**: 構造化されたログ出力
- **特徴**:
  - レベル別ログ（debug, info, warning, error）
  - 見やすいコンソール出力
  - スタックトレース対応

## 依存関係の管理

### pubspec.yaml での設定例

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状態管理
  hooks_riverpod: ^2.4.0
  riverpod_annotation: ^2.4.0
  flutter_hooks: ^0.20.0
  
  # データモデル
  freezed_annotation: ^3.1.0
  json_annotation: ^4.8.0
  
  # 画面遷移
  go_router: ^12.0.0
  
  # ローカルDB
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.0
  
  # ログ
  logger: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # コード生成
  build_runner: ^2.4.0
  freezed: ^3.2.3
  json_serializable: ^6.7.0
  drift_dev: ^2.14.0
  riverpod_generator: ^2.4.0
  
  # 品質管理
  flutter_lints: ^5.0.0
```

## ライブラリ選定理由

### なぜ hooks_riverpod か？
- Riverpod + Flutter Hooks を1パッケージで統合
- `flutter_riverpod` を内包するため個別追加不要
- Presentation層で `HookConsumerWidget` を標準採用

### なぜFreezedか？
- ボイラープレートコードの削減
- イミュータブルな設計の強制
- JSON変換の自動化
- ユニオン型のサポート

### なぜGoRouterか？
- Flutter公式推奨
- 宣言的なルーティング
- 型安全性
- ディープリンク対応

### なぜDriftか？
- 型安全性によるランタイムエラーの削減
- コンパイル時のSQL検証でバグの早期発見
- 自動生成されるDAOによる開発効率の向上
- リアクティブなクエリでUI更新の自動化
- 現在の技術スタック（Freezed、Riverpod）との高い親和性
- マイグレーション管理の自動化

### なぜFlutter Hooksか？
- Reactのフックパターンを採用
- ウィジェットの状態管理が簡潔
- 再利用可能なロジック
- メモリ管理の自動化

### なぜLoggerか？
- 開発・デバッグ効率の向上
- レベル別のログ出力でノイズを制御
- 本番ビルドでの無効化が容易