#!/usr/bin/env bash
set -Eeuo pipefail

# check_status.sh
# プロジェクトの現在状態をチェックし、project_status.md を自動更新するスクリプト
# 実行は Flutter プロジェクトのルートで行ってください。

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
STATUS_FILE="$PROJECT_ROOT/AI/logs/project_status.md"

echo -e "${BLUE}🔍 プロジェクトステータスをチェック中...${NC}\n"

# 現在時刻を取得
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# ========================================
# 1. Flutter プロジェクト初期化状態
# ========================================
echo -e "${YELLOW}📦 Flutter プロジェクトの状態:${NC}"

PUBSPEC_EXISTS="[ ]"
LIB_EXISTS="[ ]"
FLUTTER_CREATED="[ ]"

if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
  PUBSPEC_EXISTS="[x]"
  echo -e "${GREEN}  ✓ pubspec.yaml 存在${NC}"
else
  echo -e "${RED}  ✗ pubspec.yaml なし${NC}"
fi

if [ -d "$PROJECT_ROOT/lib" ]; then
  LIB_EXISTS="[x]"
  echo -e "${GREEN}  ✓ lib/ ディレクトリ存在${NC}"
else
  echo -e "${RED}  ✗ lib/ ディレクトリなし${NC}"
fi

if [ "$PUBSPEC_EXISTS" = "[x]" ] && [ "$LIB_EXISTS" = "[x]" ]; then
  FLUTTER_CREATED="[x]"
  echo -e "${GREEN}  ✓ Flutterプロジェクト初期化済み${NC}"
else
  echo -e "${YELLOW}  ⚠ Flutterプロジェクト未初期化${NC}"
fi

echo ""

# ========================================
# 2. Core 基盤の状態
# ========================================
echo -e "${YELLOW}🏗️  Core 基盤の状態:${NC}"

check_dir() {
  local dir=$1
  local name=$2
  if [ -d "$dir" ]; then
    echo -e "${GREEN}  ✓ $name${NC}"
    echo "[x]"
  else
    echo -e "${RED}  ✗ $name${NC}"
    echo "[ ]"
  fi
}

CORE_ROUTING=$(check_dir "$PROJECT_ROOT/lib/core/routing" "routing/")
CORE_ROUTING_PATH=$(check_dir "$PROJECT_ROOT/lib/core/routing/path" "routing/path/")
CORE_THEME=$(check_dir "$PROJECT_ROOT/lib/core/theme" "theme/")
CORE_API=$(check_dir "$PROJECT_ROOT/lib/core/api" "api/")
CORE_DATABASE=$(check_dir "$PROJECT_ROOT/lib/core/database" "database/")
CORE_DATABASE_TABLE=$(check_dir "$PROJECT_ROOT/lib/core/database/table" "database/table/")
CORE_EXCEPTIONS=$(check_dir "$PROJECT_ROOT/lib/core/exceptions" "exceptions/")

echo ""

# ========================================
# 3. エントリポイントの状態
# ========================================
echo -e "${YELLOW}🚪 エントリポイントの状態:${NC}"

check_file() {
  local file=$1
  local name=$2
  if [ -f "$file" ]; then
    echo -e "${GREEN}  ✓ $name${NC}"
    echo "[x]"
  else
    echo -e "${RED}  ✗ $name${NC}"
    echo "[ ]"
  fi
}

MAIN_DART=$(check_file "$PROJECT_ROOT/lib/main.dart" "lib/main.dart")
APP_DART=$(check_file "$PROJECT_ROOT/lib/app.dart" "lib/app.dart")

echo ""

# ========================================
# 4. ドキュメントの状態
# ========================================
echo -e "${YELLOW}📄 ドキュメントの状態:${NC}"

SPEC_FILE="$PROJECT_ROOT/AI/document/application_specification.md"
PLAN_FILE="$PROJECT_ROOT/AI/document/structure_plan.md"

SPEC_STATUS="未作成"
PLAN_STATUS="未作成"

if [ -f "$SPEC_FILE" ]; then
  # プロジェクト名が設定されているかチェック
  if grep -q "^- プロジェクト名: $" "$SPEC_FILE"; then
    SPEC_STATUS="テンプレートのみ"
  else
    SPEC_STATUS="作成済み"
    echo -e "${GREEN}  ✓ 仕様書作成済み${NC}"
  fi
else
  echo -e "${RED}  ✗ 仕様書未作成${NC}"
fi

if [ -f "$PLAN_FILE" ]; then
  if grep -q "^- プロジェクト名: $" "$PLAN_FILE"; then
    PLAN_STATUS="テンプレートのみ"
  else
    PLAN_STATUS="作成済み"
    echo -e "${GREEN}  ✓ 構造計画書作成済み${NC}"
  fi
else
  echo -e "${RED}  ✗ 構造計画書未作成${NC}"
fi

echo ""

# ========================================
# 5. Features の状態 (簡易チェック)
# ========================================
echo -e "${YELLOW}🎯 Features の状態:${NC}"

FEATURES_COUNT=0
if [ -d "$PROJECT_ROOT/lib/features" ]; then
  # lib/features 直下のディレクトリ数をカウント
  FEATURES_COUNT=$(find "$PROJECT_ROOT/lib/features" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  if [ "$FEATURES_COUNT" -gt 0 ]; then
    echo -e "${GREEN}  ✓ $FEATURES_COUNT 個のフィーチャーを検出${NC}"
  else
    echo -e "${YELLOW}  ⚠ フィーチャー未実装${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠ lib/features/ ディレクトリなし${NC}"
fi

echo ""

# ========================================
# 6. サマリー表示
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 ステータスサマリー${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "最終更新: $CURRENT_TIME"
echo ""
echo "Flutter プロジェクト:"
echo "  - pubspec.yaml: $PUBSPEC_EXISTS"
echo "  - lib/ ディレクトリ: $LIB_EXISTS"
echo ""
echo "Core 基盤:"
echo "  - routing/: $(echo "$CORE_ROUTING" | tail -n1)"
echo "  - theme/: $(echo "$CORE_THEME" | tail -n1)"
echo "  - api/: $(echo "$CORE_API" | tail -n1)"
echo "  - database/: $(echo "$CORE_DATABASE" | tail -n1)"
echo "  - exceptions/: $(echo "$CORE_EXCEPTIONS" | tail -n1)"
echo ""
echo "エントリポイント:"
echo "  - main.dart: $(echo "$MAIN_DART" | tail -n1)"
echo "  - app.dart: $(echo "$APP_DART" | tail -n1)"
echo ""
echo "ドキュメント:"
echo "  - 仕様書: $SPEC_STATUS"
echo "  - 構造計画書: $PLAN_STATUS"
echo ""
echo "Features: $FEATURES_COUNT 個実装済み"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅ ステータスチェック完了${NC}"
echo -e "${YELLOW}💡 詳細は project_status.md を確認してください${NC}"
echo -e "${YELLOW}💡 自動更新は update_status.sh を実行してください${NC}"
