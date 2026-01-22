#!/bin/bash

# ==========================================
# Flutter + JUCE Native Environment Setup
# Target: JUCE 8.0.12 (Stable as of Jan 2026)
# ==========================================

JUCE_REPO="https://github.com/juce-framework/JUCE.git"
JUCE_TAG="8.0.12" # 2026年1月時点の推奨バージョン
NATIVE_DIR="native"

echo "🚀 Setting up native environment for Flutter + JUCE..."

# 1. ディレクトリ作成
if [ -d "$NATIVE_DIR" ]; then
    echo "⚠️  Directory '$NATIVE_DIR' already exists. Skipping creation to avoid overwrite."
else
    mkdir -p "$NATIVE_DIR"/{src,include}
    echo "✅ Created directory structure: $NATIVE_DIR/{src,include}"
fi

# 2. JUCEのインストール (git submodule優先、失敗ならgit clone)
JUCE_DIR="$NATIVE_DIR/juce"
if [ -d "$JUCE_DIR" ]; then
    echo "ℹ️  JUCE directory already exists."
else
    echo "📥 Installing JUCE ($JUCE_TAG)..."
    # gitリポジトリ内かチェック
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git submodule add --depth 1 --branch $JUCE_TAG $JUCE_REPO $JUCE_DIR
    else
        echo "⚠️  Not a git repository. Cloning JUCE directly..."
        git clone --depth 1 --branch $JUCE_TAG $JUCE_REPO $JUCE_DIR
    fi
fi

# 3. CMakeLists.txt の生成 (FFI用共有ライブラリ設定)
CMAKE_FILE="$NATIVE_DIR/CMakeLists.txt"
if [ ! -f "$CMAKE_FILE" ]; then
    cat <<EOF > "$CMAKE_FILE"
cmake_minimum_required(VERSION 3.15)

project(native_audio VERSION 0.0.1 LANGUAGES C CXX)

# JUCEの設定
add_subdirectory(juce)

# 共有ライブラリとしてビルド (Android=.so, iOS=.dylib/Framework)
add_library(native_audio SHARED
    src/audio_engine.cpp
    # 追加のソースファイルはここに記述
)

# ヘッダーファイルのパス設定
target_include_directories(native_audio PUBLIC
    include
    juce/modules
)

# JUCEモジュールのリンク
# ボーカルDAWに必要なモジュール (DSP, AudioDevices等) を指定
target_link_libraries(native_audio PRIVATE
    juce::juce_core
    juce::juce_events
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_audio_formats
    juce::juce_audio_processors
    juce::juce_dsp
)

# コンパイルオプション (C++20推奨)
target_compile_features(native_audio PUBLIC cxx_std_20)

# FFI用のシンボルを公開するための設定
if (MSVC)
    target_compile_definitions(native_audio PRIVATE JUCE_MSVC=1)
elseif (APPLE)
    target_link_options(native_audio PRIVATE "-undefined" "dynamic_lookup")
endif()

EOF
    echo "✅ Created $CMAKE_FILE"
else
    echo "ℹ️  $CMAKE_FILE already exists. Skipping."
fi

# 4. ヘッダーファイル (Bridge API) の生成
HEADER_FILE="$NATIVE_DIR/include/bridge_api.h"
if [ ! -f "$HEADER_FILE" ]; then
    cat <<EOF > "$HEADER_FILE"
#pragma once

#include <stdint.h>

// FFI export macro
#if _WIN32
    #define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
    #define FFI_PLUGIN_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

extern "C" {
    // ここにDartから呼び出したい関数を定義します
    
    // エンジンの初期化
    FFI_PLUGIN_EXPORT void native_audio_init();

    // マイクテスト用：入力音量を0.0-1.0で取得する（仮）
    FFI_PLUGIN_EXPORT float native_audio_get_input_level();
    
    // リソース解放
    FFI_PLUGIN_EXPORT void native_audio_cleanup();
}
EOF
    echo "✅ Created $HEADER_FILE"
else
    echo "ℹ️  $HEADER_FILE already exists. Skipping."
fi

# 5. 実装ファイル (Source) の生成
SRC_FILE="$NATIVE_DIR/src/audio_engine.cpp"
if [ ! -f "$SRC_FILE" ]; then
    cat <<EOF > "$SRC_FILE"
#include "bridge_api.h"
#include <juce_audio_devices/juce_audio_devices.h>

// 簡易的なグローバルインスタンス（実際はクラス管理推奨）
namespace {
    std::unique_ptr<juce::AudioDeviceManager> deviceManager;
}

extern "C" {

    void native_audio_init() {
        // JUCEのメッセージスレッド初期化
        juce::MessageManager::getInstance();
        
        deviceManager = std::make_unique<juce::AudioDeviceManager>();
        
        // オーディオデバイスの初期化 (入力:1, 出力:2)
        deviceManager->initialiseWithDefaultDevices(1, 2);
    }

    float native_audio_get_input_level() {
        // ここにレベル取得処理を実装
        return 0.5f; // ダミー値
    }

    void native_audio_cleanup() {
        deviceManager = nullptr;
        juce::MessageManager::deleteInstance();
    }
}
EOF
    echo "✅ Created $SRC_FILE"
else
    echo "ℹ️  $SRC_FILE already exists. Skipping."
fi

echo "🎉 Setup complete! Next steps:"
echo "  1. Add 'native/include/bridge_api.h' to your ffigen configuration."
echo "  2. Configure android/app/build.gradle to build this CMake project."
