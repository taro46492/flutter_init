---
applyTo: 'lib/core/env/**'
---

# Core Env Instructions - 環境変数・アプリ設定ガイド

## 概要
`lib/core/env/` はアプリケーション全体の環境変数と設定値を管理します。開発・ステージング・本番環境の切り替えや、APIキー・ベースURLなどの環境依存値を集約します。

## 役割と責務
- 環境別の設定値管理（dev / staging / production）
- `--dart-define` や環境変数からの値取得
- アプリ全体で参照される設定値の一元管理

## してはいけないこと
- フィーチャー固有の設定値の配置（各フィーチャー配下で管理）
- ハードコーディングされたAPIキーやシークレットの直接記述
- UI／状態管理への依存

## 推奨構成
```
lib/core/env/
├── env.dart           # 環境定義（enum: dev, staging, production）
└── app_config.dart    # 環境に応じた設定値を提供
```

## 推奨パターン

```dart
// env.dart
// 環境定義

/// アプリケーションの実行環境
enum Env {
  dev,
  staging,
  production;

  /// --dart-define=ENV=xxx から環境を取得
  static Env fromString(String value) {
    return Env.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Env.dev,
    );
  }
}
```

```dart
// app_config.dart
// 環境別設定

/// 環境に応じた設定値を提供
class AppConfig {
  final Env env;
  
  const AppConfig({required this.env});

  /// API のベースURL
  String get apiBaseUrl => switch (env) {
    Env.dev => 'http://localhost:8080',
    Env.staging => 'https://staging.example.com',
    Env.production => 'https://api.example.com',
  };

  /// デバッグモードかどうか
  bool get isDebug => env == Env.dev;
}
```

## import 指針
### 許可（例）
```dart
import 'package:flutter/foundation.dart'; // kDebugMode等
```
### 禁止（例）
```dart
// UI／ネットワーク層などの責務外
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
```

## テスト指針
- 各環境での設定値が正しいことを検証
- 環境切り替えが正常に動作することを確認
- 不正な環境値に対するフォールバック動作
