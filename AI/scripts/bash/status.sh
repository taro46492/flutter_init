#!/usr/bin/env bash
set -Eeuo pipefail

# status.sh
# プロジェクトの状態管理を統合したスクリプト
# check_status.sh, update_status.sh, generate_structure_snapshot.sh の機能を統合

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
STATUS_FILE="$PROJECT_ROOT/AI/logs/project_status.md"
STRUCTURE_FILE="$PROJECT_ROOT/AI/document/current_structure.md"

usage() {
  echo "Usage: $0 <command> [options]"
  echo ""
  echo "Commands:"
  echo "  check      - プロジェクト状態をチェックして表示"
  echo "  update     - project_status.md を更新"
  echo "  snapshot   - current_structure.md にスナップショット出力"
  echo "  report     - すべて実行 (check + update + snapshot)"
  echo ""
  echo "Options:"
  echo "  -y, --yes  - 確認プロンプトをスキップ (update時)"
  echo "  -h, --help - このヘルプを表示"
  exit 0
}

# コマンドが指定されていない場合
if [ $# -eq 0 ]; then
  usage
fi

COMMAND=$1
shift

# オプション解析
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

# ========================================
# 共通チェック関数
# ========================================

check_exists() {
  [ -e "$1" ] && echo "[x]" || echo "[ ]"
}

check_dir_with_msg() {
  local dir="$PROJECT_ROOT/lib/core/$1"
  local name=$2
  if [ -d "$dir" ]; then
    echo -e "${GREEN}  ✓ $name${NC}"
    echo "[x]"
  else
    echo -e "${RED}  ✗ $name${NC}"
    echo "[ ]"
  fi
}

check_file_with_msg() {
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

get_document_status() {
  local file=$1
  if [ -f "$file" ]; then
    if grep -q "^- プロジェクト名: $" "$file" 2>/dev/null; then
      echo "テンプレートのみ"
    else
      echo "作成済み"
    fi
  else
    echo "未作成"
  fi
}

# ========================================
# check: プロジェクト状態をチェックして表示
# ========================================

cmd_check() {
  echo -e "${BLUE}🔍 プロジェクトステータスをチェック中...${NC}\n"
  
  CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  
  # Flutter プロジェクト初期化状態
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
  
  # Core 基盤の状態
  echo -e "${YELLOW}🏗️  Core 基盤の状態:${NC}"
  
  CORE_ROUTING=$(check_dir_with_msg "routing" "routing/")
  CORE_THEME=$(check_dir_with_msg "theme" "theme/")
  CORE_API=$(check_dir_with_msg "api" "api/")
  CORE_ENV=$(check_dir_with_msg "env" "env/")
  CORE_DATABASE=$(check_dir_with_msg "database" "database/")
  CORE_EXCEPTIONS=$(check_dir_with_msg "exceptions" "exceptions/")
  
  echo ""
  
  # エントリポイントの状態
  echo -e "${YELLOW}🚪 エントリポイントの状態:${NC}"
  
  MAIN_DART=$(check_file_with_msg "$PROJECT_ROOT/lib/main.dart" "lib/main.dart")
  APP_DART=$(check_file_with_msg "$PROJECT_ROOT/lib/app.dart" "lib/app.dart")
  
  echo ""
  
  # ドキュメントの状態
  echo -e "${YELLOW}📄 ドキュメントの状態:${NC}"
  
  SPEC_STATUS=$(get_document_status "$PROJECT_ROOT/AI/document/application_specification.md")
  PLAN_STATUS=$(get_document_status "$PROJECT_ROOT/AI/document/structure_plan.md")
  
  if [ "$SPEC_STATUS" = "作成済み" ]; then
    echo -e "${GREEN}  ✓ 仕様書作成済み${NC}"
  else
    echo -e "${RED}  ✗ 仕様書未作成${NC}"
  fi
  
  if [ "$PLAN_STATUS" = "作成済み" ]; then
    echo -e "${GREEN}  ✓ 構造計画書作成済み${NC}"
  else
    echo -e "${RED}  ✗ 構造計画書未作成${NC}"
  fi
  
  echo ""
  
  # Features の状態
  echo -e "${YELLOW}🎯 Features の状態:${NC}"
  
  FEATURES_COUNT=0
  if [ -d "$PROJECT_ROOT/lib/features" ]; then
    FEATURES_COUNT=$(find "$PROJECT_ROOT/lib/features" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "$FEATURES_COUNT" -gt 0 ]; then
      echo -e "${GREEN}  ✓ $FEATURES_COUNT 個のフィーチャーを検出${NC}"
    else
      echo -e "${YELLOW}  ⚠ フィーチャー未実装${NC}"
    fi
  else
    echo -e "${YELLOW}  ⚠ lib/features/ ディレクトリなし${NC}"
  fi
  
  echo ""
  
  # サマリー表示
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
  echo "  - env/: $(echo "$CORE_ENV" | tail -n1)"
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
}

# ========================================
# update: project_status.md を更新
# ========================================

cmd_update() {
  echo -e "${BLUE}📝 project_status.md を更新します...${NC}\n"
  
  if [ "$CONFIRM" != "y" ]; then
    echo "project_status.md を現在の状態で更新しますか？ (y/n)"
    read CONFIRM
    if [ "$CONFIRM" != "y" ]; then
      echo "処理を中断しました。"
      exit 0
    fi
  fi
  
  CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  CURRENT_USER=$(whoami)
  
  # 各項目のチェック
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
  
  SPEC_STATUS=$(get_document_status "$PROJECT_ROOT/AI/document/application_specification.md")
  PLAN_STATUS=$(get_document_status "$PROJECT_ROOT/AI/document/structure_plan.md")
  
  FEATURES_COUNT=0
  if [ -d "$PROJECT_ROOT/lib/features" ]; then
    FEATURES_COUNT=$(find "$PROJECT_ROOT/lib/features" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  fi
  
  # project_status.md を更新 (sed で一時ファイル使用)
  TMP_FILE=$(mktemp)
  
  sed "s/^最終更新: .*/最終更新: $CURRENT_TIME/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^更新者: .*/更新者: $CURRENT_USER (status.sh update)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  # Core 基盤の状態を更新
  sed "s/^- \\[.\\] routing\\/ (ルーティング設定)/- $ROUTING_CHECK routing\\/ (ルーティング設定)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] routing\\/path\\/ (パス定義)/- $ROUTING_PATH_CHECK routing\\/path\\/ (パス定義)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] theme\\/ (テーマ設定)/- $THEME_CHECK theme\\/ (テーマ設定)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] api\\/ (HTTP クライアント)/- $API_CHECK api\\/ (HTTP クライアント)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] database\\/ (データベース)/- $DATABASE_CHECK database\\/ (データベース)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] database\\/table\\/ (テーブル定義)/- $DATABASE_TABLE_CHECK database\\/table\\/ (テーブル定義)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] exceptions\\/ (共通例外)/- $EXCEPTIONS_CHECK exceptions\\/ (共通例外)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  # エントリポイントを更新
  sed "s/^- \\[.\\] \`lib\\/main.dart\` (初期化・ブートシーケンス)/- $MAIN_CHECK \`lib\\/main.dart\` (初期化・ブートシーケンス)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] \`lib\\/app.dart\` (最上位ウィジェット)/- $APP_CHECK \`lib\\/app.dart\` (最上位ウィジェット)/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  # Flutter プロジェクト初期化を更新
  sed "s/^- \\[.\\] \`flutter create\` 実行済み/- $PUBSPEC_CHECK \`flutter create\` 実行済み/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] \`pubspec.yaml\` 存在/- $PUBSPEC_CHECK \`pubspec.yaml\` 存在/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  sed "s/^- \\[.\\] \`lib\\/\` ディレクトリ存在/- $LIB_CHECK \`lib\\/\` ディレクトリ存在/" "$STATUS_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$STATUS_FILE"
  
  echo ""
  echo -e "${GREEN}✅ project_status.md を更新しました${NC}"
  echo -e "${YELLOW}📄 更新内容:${NC}"
  echo "  - 最終更新: $CURRENT_TIME"
  echo "  - Core 基盤の状態を反映"
  echo "  - ドキュメント状態: 仕様書($SPEC_STATUS), 構造計画書($PLAN_STATUS)"
  echo "  - Features: $FEATURES_COUNT 個検出"
  echo ""
}

# ========================================
# snapshot: current_structure.md にスナップショット出力
# ========================================

cmd_snapshot() {
  echo -e "${BLUE}📸 プロジェクト構造のスナップショットを生成中...${NC}\n"
  
  CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  
  # ファイルを生成
  {
    echo "# 現在のプロジェクト構造"
    echo ""
    echo "> このファイルは自動生成されます。手動で編集しないでください。  "
    echo "> 生成日時: $CURRENT_TIME"
    echo ""
    echo "---"
    echo ""
    
    if [ ! -d "$PROJECT_ROOT/lib" ]; then
      echo "## lib/ 構造"
      echo ""
      echo "プロジェクトにlibディレクトリが存在しません。"
    else
      echo "## lib/ 構造"
      echo ""
      echo "\`\`\`"
      # tree コマンドがあれば使用、なければ find で代替
      if command -v tree &> /dev/null; then
        tree -L 5 -I '*.g.dart|*.freezed.dart' "$PROJECT_ROOT/lib"
      else
        # tree がない場合は find で表示
        cd "$PROJECT_ROOT/lib"
        find . -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" | sort | sed 's|^\./||'
      fi
      echo "\`\`\`"
      echo ""
      
      # ファイル数の統計
      echo "## 統計情報"
      echo ""
      
      TOTAL_FILES=$(find "$PROJECT_ROOT/lib" -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" 2>/dev/null | wc -l | tr -d ' ')
      TOTAL_DIRS=$(find "$PROJECT_ROOT/lib" -type d 2>/dev/null | wc -l | tr -d ' ')
      
      echo "- **総ファイル数**: $TOTAL_FILES (生成ファイルを除く)"
      echo "- **総ディレクトリ数**: $TOTAL_DIRS"
      echo ""
      
      # 各層のファイル数
      if [ -d "$PROJECT_ROOT/lib/features" ]; then
        echo "### Features 内訳"
        echo ""
        
        for feature_dir in "$PROJECT_ROOT/lib/features"/*; do
          if [ ! -d "$feature_dir" ]; then continue; fi
          feature_name=$(basename "$feature_dir")
          
          domain_count=$(find "$feature_dir/1_domain" -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" 2>/dev/null | wc -l | tr -d ' ')
          infra_count=$(find "$feature_dir/2_infrastructure" -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" 2>/dev/null | wc -l | tr -d ' ')
          app_count=$(find "$feature_dir/3_application" -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" 2>/dev/null | wc -l | tr -d ' ')
          pres_count=$(find "$feature_dir/4_presentation" -type f -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" 2>/dev/null | wc -l | tr -d ' ')
          
          echo "#### $feature_name"
          echo ""
          echo "- Domain: $domain_count ファイル"
          echo "- Infrastructure: $infra_count ファイル"
          echo "- Application: $app_count ファイル"
          echo "- Presentation: $pres_count ファイル"
          echo ""
        done
      fi
    fi
    
    echo "---"
    echo ""
    echo "## 生成方法"
    echo ""
    echo "このファイルは以下のコマンドで自動生成されます:"
    echo ""
    echo "\`\`\`bash"
    echo "./AI/scripts/bash/status.sh snapshot"
    echo "\`\`\`"
    echo ""
    echo "またはワークフローから:"
    echo ""
    echo "\`\`\`"
    echo "/generate_structure_snapshot"
    echo "\`\`\`"
    
  } > "$STRUCTURE_FILE"
  
  echo -e "${GREEN}✅ 構造スナップショットを生成しました: $STRUCTURE_FILE${NC}"
  echo ""
}

# ========================================
# report: すべて実行
# ========================================

cmd_report() {
  echo -e "${BLUE}📋 完全なステータスレポートを生成します...${NC}\n"
  
  # check を実行
  cmd_check
  
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  # update を実行 (非対話モード)
  CONFIRM="y"
  cmd_update
  
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  # snapshot を実行
  cmd_snapshot
  
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ すべての処理が完了しました${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ========================================
# コマンド実行
# ========================================

case "$COMMAND" in
  check)
    cmd_check
    ;;
  update)
    cmd_update
    ;;
  snapshot)
    cmd_snapshot
    ;;
  report)
    cmd_report
    ;;
  *)
    echo "Unknown command: $COMMAND"
    usage
    ;;
esac

exit 0
