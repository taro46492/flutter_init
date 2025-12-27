#!/usr/bin/env bash
set -Eeuo pipefail

# update_status.sh
# check_status.sh の結果を元に project_status.md を自動更新するスクリプト
# 実行は Flutter プロジェクトのルートで行ってください。

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
STATUS_FILE="$PROJECT_ROOT/AI/logs/project_status.md"

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -y, --yes     Skip confirmation prompt (non-interactive)."
  echo "  -h, --help    Show this help."
  exit 0
}

CONFIRM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)
      CONFIRM="y"; shift;;
    -h|--help)
      usage;;
    *)
      echo "Unknown option: $1"
      usage;;
  esac
done

echo -e "${BLUE}📝 project_status.md を更新します...${NC}\n"

if [ "$CONFIRM" != "y" ]; then
  echo "project_status.md を現在の状態で更新しますか？ (y/n)"
  read CONFIRM
  if [ "$CONFIRM" != "y" ]; then
    echo "処理を中断しました。"
    exit 0
  fi
fi

# 現在時刻を取得
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
CURRENT_USER=$(whoami)

# 各項目のチェック
check_exists() {
  [ -e "$1" ] && echo "[x]" || echo "[ ]"
}

PUBSPEC_CHECK=$(check_exists "$PROJECT_ROOT/pubspec.yaml")
LIB_CHECK=$(check_exists "$PROJECT_ROOT/lib")
MAIN_CHECK=$(check_exists "$PROJECT_ROOT/lib/main.dart")
APP_CHECK=$(check_exists "$PROJECT_ROOT/lib/app.dart")

ROUTING_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/routing")
ROUTING_PATH_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/routing/path")
THEME_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/theme")
API_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/api")
DATABASE_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/database")
DATABASE_TABLE_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/database/table")
EXCEPTIONS_CHECK=$(check_exists "$PROJECT_ROOT/lib/core/exceptions")

# ドキュメントの状態チェック
SPEC_FILE="$PROJECT_ROOT/AI/document/application_specification.md"
PLAN_FILE="$PROJECT_ROOT/AI/document/structure_plan.md"

SPEC_STATUS="未作成"
PLAN_STATUS="未作成"

if [ -f "$SPEC_FILE" ]; then
  if grep -q "^- プロジェクト名: $" "$SPEC_FILE" 2>/dev/null; then
    SPEC_STATUS="テンプレートのみ"
  else
    SPEC_STATUS="作成済み"
  fi
fi

if [ -f "$PLAN_FILE" ]; then
  if grep -q "^- プロジェクト名: $" "$PLAN_FILE" 2>/dev/null; then
    PLAN_STATUS="テンプレートのみ"
  else
    PLAN_STATUS="作成済み"
  fi
fi

# Features数のカウント
FEATURES_COUNT=0
if [ -d "$PROJECT_ROOT/lib/features" ]; then
  FEATURES_COUNT=$(find "$PROJECT_ROOT/lib/features" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
fi

# project_status.md の該当行を更新
# sedの互換性のため、一時ファイルを使用
TMP_FILE=$(mktemp)

# 最終更新日時を更新
sed "s/^最終更新: .*/最終更新: $CURRENT_TIME/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

# 更新者を更新
sed "s/^更新者: .*/更新者: $CURRENT_USER (update_status.sh)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

# Core 基盤の状態を更新
sed "s/^- \[.\] routing\/ (ルーティング設定)/- $ROUTING_CHECK routing\/ (ルーティング設定)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] routing\/path\/ (パス定義)/- $ROUTING_PATH_CHECK routing\/path\/ (パス定義)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] theme\/ (テーマ設定)/- $THEME_CHECK theme\/ (テーマ設定)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] api\/ (HTTP クライアント)/- $API_CHECK api\/ (HTTP クライアント)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] database\/ (データベース)/- $DATABASE_CHECK database\/ (データベース)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] database\/table\/ (テーブル定義)/- $DATABASE_TABLE_CHECK database\/table\/ (テーブル定義)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] exceptions\/ (共通例外)/- $EXCEPTIONS_CHECK exceptions\/ (共通例外)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

# エントリポイントを更新
sed "s/^- \[.\] \`lib\/main.dart\` (初期化・ブートシーケンス)/- $MAIN_CHECK \`lib\/main.dart\` (初期化・ブートシーケンス)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] \`lib\/app.dart\` (最上位ウィジェット)/- $APP_CHECK \`lib\/app.dart\` (最上位ウィジェット)/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

# Flutter プロジェクト初期化を更新
sed "s/^- \[.\] \`flutter create\` 実行済み/- $PUBSPEC_CHECK \`flutter create\` 実行済み/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] \`pubspec.yaml\` 存在/- $PUBSPEC_CHECK \`pubspec.yaml\` 存在/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

sed "s/^- \[.\] \`lib\/\` ディレクトリ存在/- $LIB_CHECK \`lib\/\` ディレクトリ存在/" "$STATUS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATUS_FILE"

echo ""
echo -e "${GREEN}✅ project_status.md を更新しました${NC}"
echo -e "${YELLOW}📄 更新内容:${NC}"
echo "  - 最終更新: $CURRENT_TIME"
echo "  - Core 基盤の状態を反映"
echo "  - ドキュメント状態: 仕様書($SPEC_STATUS), 構造計画書($PLAN_STATUS)"
echo "  - Features: $FEATURES_COUNT 個検出"
echo ""
echo -e "${BLUE}💡 詳細は以下で確認:${NC}"
echo "  cat $STATUS_FILE"
