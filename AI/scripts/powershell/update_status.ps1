# update_status.ps1
# check_status.ps1 の結果を元に project_status.md を自動更新するスクリプト
# 実行は Flutter プロジェクトのルートで行ってください。

param(
    [switch]$Yes
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$StatusFile = Join-Path $ProjectRoot "AI\logs\project_status.md"

Write-Host "📝 project_status.md を更新します...`n" -ForegroundColor Cyan

if (-not $Yes) {
    $Response = Read-Host "project_status.md を現在の状態で更新しますか？ (y/n)"
    if ($Response -ne "y") {
        Write-Host "処理を中断しました。"
        exit 0
    }
}

# 現在時刻を取得
$CurrentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$CurrentUser = $env:USERNAME

# 各項目のチェック
function Check-Exists {
    param([string]$Path)
    if (Test-Path $Path) { return "[x]" } else { return "[ ]" }
}

$PubspecCheck = Check-Exists (Join-Path $ProjectRoot "pubspec.yaml")
$LibCheck = Check-Exists (Join-Path $ProjectRoot "lib")
$MainCheck = Check-Exists (Join-Path $ProjectRoot "lib\main.dart")
$AppCheck = Check-Exists (Join-Path $ProjectRoot "lib\app.dart")

$RoutingCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\routing")
$RoutingPathCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\routing\path")
$ThemeCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\theme")
$ApiCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\api")
$DatabaseCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\database")
$DatabaseTableCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\database\table")
$ExceptionsCheck = Check-Exists (Join-Path $ProjectRoot "lib\core\exceptions")

# ドキュメントの状態チェック
$SpecFile = Join-Path $ProjectRoot "AI\document\application_specification.md"
$PlanFile = Join-Path $ProjectRoot "AI\document\structure_plan.md"

$SpecStatus = "未作成"
$PlanStatus = "未作成"

if (Test-Path $SpecFile) {
    $SpecContent = Get-Content $SpecFile -Raw
    if ($SpecContent -match "^- プロジェクト名: `$") {
        $SpecStatus = "テンプレートのみ"
    } else {
        $SpecStatus = "作成済み"
    }
}

if (Test-Path $PlanFile) {
    $PlanContent = Get-Content $PlanFile -Raw
    if ($PlanContent -match "^- プロジェクト名: `$") {
        $PlanStatus = "テンプレートのみ"
    } else {
        $PlanStatus = "作成済み"
    }
}

# Features数のカウント
$FeaturesCount = 0
$FeaturesPath = Join-Path $ProjectRoot "lib\features"
if (Test-Path $FeaturesPath) {
    $FeaturesCount = (Get-ChildItem -Path $FeaturesPath -Directory | Measure-Object).Count
}

# project_status.md を読み込み
$Content = Get-Content $StatusFile -Raw

# 最終更新日時を更新
$Content = $Content -replace "最終更新: .*", "最終更新: $CurrentTime"

# 更新者を更新
$Content = $Content -replace "更新者: .*", "更新者: $CurrentUser (update_status.ps1)"

# Core 基盤の状態を更新
$Content = $Content -replace "^- \[.\] routing/ \(ルーティング設定\)", "- $RoutingCheck routing/ (ルーティング設定)"
$Content = $Content -replace "^- \[.\] routing/path/ \(パス定義\)", "- $RoutingPathCheck routing/path/ (パス定義)"
$Content = $Content -replace "^- \[.\] theme/ \(テーマ設定\)", "- $ThemeCheck theme/ (テーマ設定)"
$Content = $Content -replace "^- \[.\] api/ \(HTTP クライアント\)", "- $ApiCheck api/ (HTTP クライアント)"
$Content = $Content -replace "^- \[.\] database/ \(データベース\)", "- $DatabaseCheck database/ (データベース)"
$Content = $Content -replace "^- \[.\] database/table/ \(テーブル定義\)", "- $DatabaseTableCheck database/table/ (テーブル定義)"
$Content = $Content -replace "^- \[.\] exceptions/ \(共通例外\)", "- $ExceptionsCheck exceptions/ (共通例外)"

# エントリポイントを更新
$Content = $Content -replace "^- \[.\] ``lib/main.dart`` \(初期化・ブートシーケンス\)", "- $MainCheck ``lib/main.dart`` (初期化・ブートシーケンス)"
$Content = $Content -replace "^- \[.\] ``lib/app.dart`` \(最上位ウィジェット\)", "- $AppCheck ``lib/app.dart`` (最上位ウィジェット)"

# Flutter プロジェクト初期化を更新
$Content = $Content -replace "^- \[.\] ``flutter create`` 実行済み", "- $PubspecCheck ``flutter create`` 実行済み"
$Content = $Content -replace "^- \[.\] ``pubspec.yaml`` 存在", "- $PubspecCheck ``pubspec.yaml`` 存在"
$Content = $Content -replace "^- \[.\] ``lib/`` ディレクトリ存在", "- $LibCheck ``lib/`` ディレクトリ存在"

# ファイルに書き込み
Set-Content -Path $StatusFile -Value $Content -Encoding UTF8

Write-Host ""
Write-Host "✅ project_status.md を更新しました" -ForegroundColor Green
Write-Host "📄 更新内容:" -ForegroundColor Yellow
Write-Host "  - 最終更新: $CurrentTime"
Write-Host "  - Core 基盤の状態を反映"
Write-Host "  - ドキュメント状態: 仕様書($SpecStatus), 構造計画書($PlanStatus)"
Write-Host "  - Features: $FeaturesCount 個検出"
Write-Host ""
Write-Host "💡 詳細は以下で確認:" -ForegroundColor Cyan
Write-Host "  Get-Content $StatusFile"
