#!/usr/bin/env bash
set -euo pipefail

# タイムゾーン設定
export TZ=UTC

# publicディレクトリ内を全削除（隠しファイル含む）
rm -rf public/* public/.??*

# Hugoビルド
echo "🏗️ビルドしています..."
hugo --gc
echo "🏰ビルド成功しました!"
