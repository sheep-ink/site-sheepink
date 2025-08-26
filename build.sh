#!/usr/bin/env bash
set -euo pipefail

HUGO_VERSION=0.148.2

# タイムゾーン設定（Cloudflare Workers推奨）
export TZ=UTC

# Hugo Extended のインストール
echo "Installing Hugo Extended ${HUGO_VERSION}..."
curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
mkdir -p "${HOME}/.local/hugo"
tar -C "${HOME}/.local/hugo" -xf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
rm "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
export PATH="${HOME}/.local/hugo:${PATH}"

# Git設定
git config core.quotepath false
if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
  echo "Converting shallow repository to full repository..."
  git fetch --unshallow
fi

# Hugo Modules初期化
echo "Initializing Hugo Modules..."
if [ ! -f "go.mod" ]; then
  hugo mod init github.com/$(echo $GITHUB_REPOSITORY | tr '[:upper:]' '[:lower:]') || true
fi

# Hugo Modules依存関係の取得・整理
echo "Syncing Hugo Modules..."
hugo mod get -u
hugo mod tidy

# バージョン確認
echo "Verifying installations..."
echo "Hugo: $(hugo version)"

# Hugoビルド（GCおよびminify）
echo "Building Hugo site..."
hugo --gc

echo "Build completed successfully!"
