#!/usr/bin/env bash
set -euo pipefail

# タイムゾーン設定
export TZ=UTC

# publicディレクトリ内を全削除（隠しファイル含む）
rm -rf public/* public/.??*

# Hugoビルド
echo "🏗️ビルドしています..."
HUGO_MINIFY_TDEWOLFF_HTML_KEEPCOMMENTS=true HUGO_ENABLEMISSINGTRANSLATIONPLACEHOLDERS=true hugo --gc
grep -inorE "<\!-- raw HTML omitted -->|ZgotmplZ|\[i18n\]|\(<nil>\)|(&lt;nil&gt;)|hahahugo" public/ || true
echo "🏰ビルド成功しました!"
