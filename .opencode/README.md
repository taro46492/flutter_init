# OpenCode カスタム設定ガイド

このディレクトリには、OpenCodeのカスタムエージェントとコマンドの設定が含まれています。

## 📁 ディレクトリ構造

```
.opencode/
├── agent/          # カスタムエージェント
│   └── flutter.md  # Flutter開発専門エージェント
└── command/        # カスタムコマンド
    ├── check_status.md                    # プロジェクト状態チェック
    ├── detect_changes.md                  # ファイル変更検出
    ├── generate_structure_snapshot.md     # 構造スナップショット生成
    ├── status_report.md                   # 完全レポート生成
    ├── update_status.md                   # ステータス更新
    └── validate_structure.md              # 構造検証
```

## 🤖 カスタムエージェント

### Flutter エージェント

Flutter開発に特化したエージェント。このプロジェクトの構造規約とベストプラクティスに従ってコーディングします。

**使用方法:**
```bash
# OpenCodeでFlutterエージェントに切り替え
Tab キーでエージェントを選択 → "flutter"を選択
```

**特徴:**
- モード選択機能（新規開発/既存開発）
- 構造規約の厳密な遵守
- ドキュメント同期管理

## ⚡ カスタムコマンド

### 1. `/check_status` - プロジェクト状態チェック

現在のプロジェクト状態を確認します。

```bash
/check_status
```

**確認内容:**
- Flutter初期化状態
- Coreコンポーネント
- エントリポイント
- ドキュメント
- Features数

---

### 2. `/detect_changes` - ファイル変更検出

プロジェクト内の変更を検出して記録します。

```bash
/detect_changes
```

**検出内容:**
- ファイルの作成/変更/削除
- ディレクトリの作成（24時間以内）

**出力:** `AI/logs/change_history.md`

---

### 3. `/generate_structure_snapshot` - 構造スナップショット

現在の`lib/`構造をスナップショット化します。

```bash
/generate_structure_snapshot
```

**出力:** `AI/document/current_structure.md`

**使用タイミング:**
- AI会話開始前
- 大きな実装完了後

---

### 4. `/status_report` - 完全レポート

プロジェクトの完全レポートを生成します。

```bash
/status_report
```

**実行内容:**
1. 状態チェック
2. ステータス更新
3. スナップショット生成

**最も包括的なコマンド。新しいAI会話開始時に推奨。**

---

### 5. `/update_status` - ステータス更新

`project_status.md`を最新状態に更新します。

```bash
/update_status
```

**更新内容:**
- 更新日時
- コンポーネント状態
- Features数

**出力:** `AI/logs/project_status.md`

---

### 6. `/validate_structure` - 構造検証

ディレクトリ構造が規約に準拠しているかを検証します。

```bash
/validate_structure
```

**検証対象:**
- `lib/`直下の構造
- `lib/core/`配下
- `lib/features/`の4層構造

**違反が見つかった場合:** `AI/logs/structure_violations.md`に記録

---

## 🚀 使い方

### OpenCodeのインストール

```bash
# Homebrewでインストール（推奨）
brew install anomalyco/tap/opencode
```

### このプロジェクトでOpenCodeを使う

```bash
# プロジェクトルートで起動
cd /path/to/flutter_init-2
opencode
```

### カスタムコマンドの実行

OpenCode起動後、`/`を入力するとコマンド一覧が表示されます。

```
/check_status
/detect_changes
/generate_structure_snapshot
/status_report
/update_status
/validate_structure
```

### カスタムエージェントの選択

`Tab`キーでエージェント選択画面を開き、`flutter`を選択します。

---

## 📝 注意事項

1. **スクリプトの実行権限**: コマンドは`./AI/scripts/bash/`配下のスクリプトを実行します。実行権限を確認してください。

```bash
chmod +x ./AI/scripts/bash/*.sh
```

2. **プロジェクトルートから実行**: コマンドはプロジェクトルートで実行されることを前提としています。

3. **ドキュメントの自動更新**: 一部のコマンドはドキュメントファイルを自動上書きします。

---

## 🔗 関連ドキュメント

- [OpenCode公式ドキュメント](https://opencode.ai/docs)
- [カスタムエージェント設定](https://opencode.ai/docs/agents)
- [カスタムコマンド設定](https://opencode.ai/docs/commands)

---

## 📌 元の設定ファイル

このOpenCode設定は、`.agent/`ディレクトリの内容を変換したものです:

- `.agent/rules/flutter.md` → `.opencode/agent/flutter.md`
- `.agent/workflows/*.md` → `.opencode/command/*.md`

両方のディレクトリは並行して維持されます。
