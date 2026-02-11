# リポジトリ改善チェックリスト

- [x] 1. 依存関係とバージョンの最適化
- [x] 2. coreに env ディレクトリを追加
- [x] 3. database のマイグレーション構造再検討
- [x] 4. status.sh テンプレートのスラッシュコマンド表記修正
- [x] 5. その他の細かい改善

---

## ✅ 完了サマリー

以下の改善を実施しました：

### 改善① 依存関係とバージョンの最適化
- `technology_stack.md` を基盤パッケージのみに更新
- `recommended_packages.md` を新規作成（9カテゴリ）
- `add_dependencies.sh` を同期更新
- Riverpod を `hooks_riverpod` に統一

### 改善② core構造改善
- `core/env/` ディレクトリを追加（環境変数管理）
- `core/database/migration/` ディレクトリを追加（バージョン別マイグレーション）
- 関連ドキュメントを全面更新
  - `core_architecture.md`
  - `directory_structure_and_naming_rules.md`
  - `generate_core.sh`
  - `database/instructions.md`
- 新規インストラクションファイル作成
  - `env/instructions.md`
  - `database/migration/instructions.md`

### 改善③ status.shスラッシュコマンド表記修正
- `/status snapshot` → `/generate_structure_snapshot` に修正
- Core基盤チェックに `env/` を追加

### 改善④ 構造検証とステータス管理の更新
- `validate_structure.sh` に `env/` と `database/migration/` を追加
- `project_status.md` に `env/` と `database/migration/` を追加

### 検証結果
- README.md：全11スクリプトが正しく記載済み✅
- PowerShellディレクトリ：実際には存在せず（調査レポートの誤記）

---

## 1. 依存関係とバージョンの最適化

### 方針

- **ファイル構成**: 2ファイルに分離
  - `AI/architecture/technology_stack.md` — 全プロジェクト共通の基盤パッケージ
  - `AI/architecture/recommended_packages.md`（新規）— 機能・用途別の推奨パッケージカタログ
- **Riverpod**: `hooks_riverpod` のみ（`flutter_riverpod`/`riverpod` 単体は不要）
- **バージョン**: 最低バージョン指定（`^x.y.z`）を維持

### ファイル①: technology_stack.md（基盤パッケージ）

以下のみを基盤として残す：

| カテゴリ | パッケージ | 理由 |
|---------|-----------|------|
| 状態管理 | `hooks_riverpod` | Riverpod + Hooks 統合（flutter_riverpod を含む） |
| 状態管理 | `riverpod_annotation` | Riverpod コード生成アノテーション |
| UI補助 | `flutter_hooks` | フックベースの状態管理 |
| データモデル | `freezed_annotation` | イミュータブルデータクラス |
| データモデル | `json_annotation` | JSONシリアライズ |
| 画面遷移 | `go_router` | 宣言的ルーティング |
| ローカルDB | `drift` | 型安全ローカルDB |
| ローカルDB | `sqlite3_flutter_libs` | SQLiteネイティブライブラリ |
| ローカルDB | `path_provider` | ファイルパス取得 |
| ローカルDB | `path` | パス操作 |
| ユーティリティ | `logger` | ログ出力 |

**dev_dependencies（基盤）:**

| カテゴリ | パッケージ |
|---------|-----------|
| コード生成 | `build_runner` |
| コード生成 | `freezed` |
| コード生成 | `json_serializable` |
| コード生成 | `drift_dev` |
| コード生成 | `riverpod_generator` |
| 品質管理 | `flutter_lints` |

### ファイル②: recommended_packages.md（機能別推奨パッケージ）

用途ごとにセクション分けし「この機能を実装するならこれ」を案内：

#### 🌐 HTTP通信・API連携
| パッケージ | 用途 | 補足 |
|-----------|------|------|
| `http` | 基本的なHTTP通信 | 軽量、シンプルなREST API向け |
| `dio` | 高機能HTTP通信 | インターセプター、キャンセル、リトライ等が必要な場合 |

#### 🔐 認証・セキュリティ
| パッケージ | 用途 |
|-----------|------|
| `google_sign_in` | Google認証 |
| `googleapis` / `googleapis_auth` | Google API連携 |
| `extension_google_sign_in_as_googleapis_auth` | 上記の橋渡し |
| `flutter_secure_storage` | セキュアなデータ保存 |

#### 💾 データ保存（Drift以外）
| パッケージ | 用途 |
|-----------|------|
| `shared_preferences` | 簡易Key-Valueストア（設定値等） |

#### 🌍 WebView・ブラウザ
| パッケージ | 用途 |
|-----------|------|
| `flutter_inappwebview` | アプリ内ブラウザ |
| `url_launcher` | 外部ブラウザでURL起動 |

#### 📱 ネットワーク・接続
| パッケージ | 用途 |
|-----------|------|
| `connectivity_plus` | ネットワーク接続状態の監視 |

#### 🖥️ デスクトップ対応
| パッケージ | 用途 | 対象 |
|-----------|------|------|
| `flutter_single_instance` | 多重起動防止 | Windows / macOS |
| `window_manager` | ウィンドウサイズ・位置制御 | Windows / macOS |
| `macos_window_utils` | macOS専用ウィンドウ制御 | macOS |

#### 🕷️ スクレイピング
| パッケージ | 用途 |
|-----------|------|
| `html` | HTMLパース |

#### 🧪 テスト
| パッケージ | 用途 |
|-----------|------|
| `mockito` | モックオブジェクト生成 |
| `integration_test` | 統合テスト |

#### 🎨 ビルド・配布
| パッケージ | 用途 |
|-----------|------|
| `flutter_launcher_icons` | アプリアイコン自動生成 |

---

## 2. core に env ディレクトリ追加

環境変数管理用のディレクトリを追加する。

## 3. database マイグレーション構造再検討

現状の AI/architecture/lib/core/database ではマイグレーションファイルを一つずつ残す術がないので構造を再検討。

---

## 参考：最近のプロジェクトで使用した依存関係

以下は実際に最近のプロジェクトで使用している依存関係
吟味して、AI/architecture/technology_stack.mdに追加していきたい
dependencies:
  flutter:
    sdk: flutter
  
  # ========================================
  # 基盤（technology_stack.md準拠）
  # ========================================
  
  # 状態管理
  riverpod: ^2.4.0
  hooks_riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.4.0
  flutter_hooks: ^0.20.0
  
  # データモデル
  freezed_annotation: ^3.1.0
  json_annotation: ^4.8.0
  
  # 画面遷移
  go_router: ^12.0.0
  
  # ローカルDB
  drift: ^2.14.0
  path_provider: ^2.1.0
  path: ^1.8.0
  
  # ========================================
  # アプリ固有機能
  # ========================================
  
  # WebView（内蔵ブラウザ）
  flutter_inappwebview: ^6.1.5
  
  # スクレイピング
  http: ^1.2.0
  html: ^0.15.5
  
  # Google API連携
  googleapis: ^15.0.0
  googleapis_auth: ^2.0.0
  google_sign_in: ^6.3.0
  extension_google_sign_in_as_googleapis_auth: ^2.0.13
  
  # ユーティリティ
  url_launcher: ^6.3.2
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.2.2
  connectivity_plus: ^6.0.5
  logger: ^2.4.0
  
  # デスクトップ専用（Windows / macOS 共通）
  flutter_single_instance: ^1.7.0
  window_manager: ^0.5.0
  
  # macOS専用
  macos_window_utils: ^1.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  integration_test:
    sdk: flutter
  
  # コード生成
  build_runner: ^2.4.0
  freezed: ^3.1.0
  json_serializable: ^6.7.0
  drift_dev: ^2.14.0
  riverpod_generator: ^2.4.0
  
  # 品質管理
  flutter_lints: ^5.0.0
  mockito: ^5.4.4
  
  # アイコン生成
  flutter_launcher_icons: ^0.13.1