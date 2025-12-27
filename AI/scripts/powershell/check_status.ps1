# check_status.ps1
# プロジェクトの現在状態をチェックし、project_status.md を自動更新するスクリプト
# 実行は Flutter プロジェクトのルートで行ってください。

param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$StatusFile = Join-Path $ProjectRoot "AI\logs\project_status.md"

Write-Host "🔍 プロジェクトステータスをチェック中...`n" -ForegroundColor Cyan

# 現在時刻を取得
$CurrentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ========================================
# 1. Flutter プロジェクト初期化状態
# ========================================
Write-Host "📦 Flutter プロジェクトの状態:" -ForegroundColor Yellow

$PubspecExists = "[ ]"
$LibExists = "[ ]"
$FlutterCreated = "[ ]"

if (Test-Path (Join-Path $ProjectRoot "pubspec.yaml")) {
    $PubspecExists = "[x]"
    Write-Host "  ✓ pubspec.yaml 存在" -ForegroundColor Green
} else {
    Write-Host "  ✗ pubspec.yaml なし" -ForegroundColor Red
}

if (Test-Path (Join-Path $ProjectRoot "lib")) {
    $LibExists = "[x]"
    Write-Host "  ✓ lib/ ディレクトリ存在" -ForegroundColor Green
} else {
    Write-Host "  ✗ lib/ ディレクトリなし" -ForegroundColor Red
}

if ($PubspecExists -eq "[x]" -and $LibExists -eq "[x]") {
    $FlutterCreated = "[x]"
    Write-Host "  ✓ Flutterプロジェクト初期化済み" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Flutterプロジェクト未初期化" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# 2. Core 基盤の状態
# ========================================
Write-Host "🏗️  Core 基盤の状態:" -ForegroundColor Yellow

function Check-Dir {
    param([string]$Dir, [string]$Name)
    if (Test-Path $Dir) {
        Write-Host "  ✓ $Name" -ForegroundColor Green
        return "[x]"
    } else {
        Write-Host "  ✗ $Name" -ForegroundColor Red
        return "[ ]"
    }
}

$CoreRouting = Check-Dir (Join-Path $ProjectRoot "lib\core\routing") "routing/"
$CoreRoutingPath = Check-Dir (Join-Path $ProjectRoot "lib\core\routing\path") "routing/path/"
$CoreTheme = Check-Dir (Join-Path $ProjectRoot "lib\core\theme") "theme/"
$CoreApi = Check-Dir (Join-Path $ProjectRoot "lib\core\api") "api/"
$CoreDatabase = Check-Dir (Join-Path $ProjectRoot "lib\core\database") "database/"
$CoreDatabaseTable = Check-Dir (Join-Path $ProjectRoot "lib\core\database\table") "database/table/"
$CoreExceptions = Check-Dir (Join-Path $ProjectRoot "lib\core\exceptions") "exceptions/"

Write-Host ""

# ========================================
# 3. エントリポイントの状態
# ========================================
Write-Host "🚪 エントリポイントの状態:" -ForegroundColor Yellow

function Check-File {
    param([string]$File, [string]$Name)
    if (Test-Path $File) {
        Write-Host "  ✓ $Name" -ForegroundColor Green
        return "[x]"
    } else {
        Write-Host "  ✗ $Name" -ForegroundColor Red
        return "[ ]"
    }
}

$MainDart = Check-File (Join-Path $ProjectRoot "lib\main.dart") "lib/main.dart"
$AppDart = Check-File (Join-Path $ProjectRoot "lib\app.dart") "lib/app.dart"

Write-Host ""

# ========================================
# 4. ドキュメントの状態
# ========================================
Write-Host "📄 ドキュメントの状態:" -ForegroundColor Yellow

$SpecFile = Join-Path $ProjectRoot "AI\document\application_specification.md"
$PlanFile = Join-Path $ProjectRoot "AI\document\structure_plan.md"

$SpecStatus = "未作成"
$PlanStatus = "未作成"

if (Test-Path $SpecFile) {
    $SpecContent = Get-Content $SpecFile -Raw
    if ($SpecContent -match "^- プロジェクト名: $") {
        $SpecStatus = "テンプレートのみ"
    } else {
        $SpecStatus = "作成済み"
        Write-Host "  ✓ 仕様書作成済み" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ 仕様書未作成" -ForegroundColor Red
}

if (Test-Path $PlanFile) {
    $PlanContent = Get-Content $PlanFile -Raw
    if ($PlanContent -match "^- プロジェクト名: $") {
        $PlanStatus = "テンプレートのみ"
    } else {
        $PlanStatus = "作成済み"
        Write-Host "  ✓ 構造計画書作成済み" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ 構造計画書未作成" -ForegroundColor Red
}

Write-Host ""

# ========================================
# 5. Features の状態 (簡易チェック)
# ========================================
Write-Host "🎯 Features の状態:" -ForegroundColor Yellow

$FeaturesCount = 0
$FeaturesPath = Join-Path $ProjectRoot "lib\features"
if (Test-Path $FeaturesPath) {
    $FeaturesCount = (Get-ChildItem -Path $FeaturesPath -Directory | Measure-Object).Count
    if ($FeaturesCount -gt 0) {
        Write-Host "  ✓ $FeaturesCount 個のフィーチャーを検出" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ フィーチャー未実装" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ lib/features/ ディレクトリなし" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# 6. サマリー表示
# ========================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 ステータスサマリー" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "最終更新: $CurrentTime"
Write-Host ""
Write-Host "Flutter プロジェクト:"
Write-Host "  - pubspec.yaml: $PubspecExists"
Write-Host "  - lib/ ディレクトリ: $LibExists"
Write-Host ""
Write-Host "Core 基盤:"
Write-Host "  - routing/: $CoreRouting"
Write-Host "  - theme/: $CoreTheme"
Write-Host "  - api/: $CoreApi"
Write-Host "  - database/: $CoreDatabase"
Write-Host "  - exceptions/: $CoreExceptions"
Write-Host ""
Write-Host "エントリポイント:"
Write-Host "  - main.dart: $MainDart"
Write-Host "  - app.dart: $AppDart"
Write-Host ""
Write-Host "ドキュメント:"
Write-Host "  - 仕様書: $SpecStatus"
Write-Host "  - 構造計画書: $PlanStatus"
Write-Host ""
Write-Host "Features: $FeaturesCount 個実装済み"
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ ステータスチェック完了" -ForegroundColor Green
Write-Host "💡 詳細は project_status.md を確認してください" -ForegroundColor Yellow
Write-Host "💡 自動更新は update_status.ps1 を実行してください" -ForegroundColor Yellow
