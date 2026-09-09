#!/usr/bin/env bash
# goodvibesagency.tokyo にレポートを公開するスクリプト
#
#   ./publish.sh <zipまたはhtmlファイル> <URLスラッグ>
#   例: ./publish.sh ~/Downloads/SNIDEL_レポート.zip 202609-snidel-ig-pr-report
#   → https://goodvibesagency.tokyo/202609-snidel-ig-pr-report/
#
# 前提: git が使えること / このリポジトリへの書き込み権限があること
# オプション: --dry-run で push せず動作確認のみ

set -euo pipefail

REPO_URL="https://github.com/GOOD-VIBES-AGENCY/good-vibes-agency.github.io.git"
BASE_URL="https://goodvibesagency.tokyo"
DRY_RUN=0

# --- 引数の解析 ---
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) ARGS+=("$arg") ;;
  esac
done

if [ "${#ARGS[@]}" -ne 2 ]; then
  echo "エラー: 引数が足りません" >&2
  echo "使い方: $0 <zipまたはhtmlファイル> <URLスラッグ> [--dry-run]" >&2
  exit 1
fi

SOURCE_FILE="${ARGS[0]}"
SLUG="${ARGS[1]}"

# --- 入力チェック ---
if [ ! -f "$SOURCE_FILE" ]; then
  echo "エラー: ファイルが見つかりません: $SOURCE_FILE" >&2
  exit 1
fi

if ! [[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "エラー: スラッグは半角英小文字・数字・ハイフンのみ使えます: $SLUG" >&2
  echo "  例: 202609-snidel-ig-pr-report" >&2
  exit 1
fi

command -v git >/dev/null 2>&1 || { echo "エラー: git が見つかりません" >&2; exit 1; }

WORK_DIR="$(mktemp -d)"
# 途中で失敗しても一時ディレクトリを消す
trap 'rm -rf "$WORK_DIR"' EXIT

# --- 素材を index.html として組み立てる ---
STAGE_DIR="$WORK_DIR/stage"
mkdir -p "$STAGE_DIR"

case "$SOURCE_FILE" in
  *.zip)
    command -v unzip >/dev/null 2>&1 || { echo "エラー: unzip が見つかりません" >&2; exit 1; }
    unzip -q -o "$SOURCE_FILE" -d "$STAGE_DIR" || { echo "エラー: zip の展開に失敗しました" >&2; exit 1; }
    # zip 内が1フォルダだけの場合は中身を1階層上げる
    inner_count="$(find "$STAGE_DIR" -mindepth 1 -maxdepth 1 ! -name '__MACOSX' | wc -l | tr -d ' ')"
    inner_dir="$(find "$STAGE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '__MACOSX')"
    if [ "$inner_count" = "1" ] && [ -n "$inner_dir" ]; then
      mv "$inner_dir"/* "$STAGE_DIR"/ 2>/dev/null || true
      rmdir "$inner_dir" 2>/dev/null || true
    fi
    rm -rf "$STAGE_DIR/__MACOSX"
    ;;
  *.html|*.htm)
    cp "$SOURCE_FILE" "$STAGE_DIR/"
    ;;
  *)
    echo "エラー: zip か html を指定してください: $SOURCE_FILE" >&2
    exit 1
    ;;
esac

# index.html が無ければ、唯一の html をリネームして充てる
if [ ! -f "$STAGE_DIR/index.html" ]; then
  html_files="$(find "$STAGE_DIR" -maxdepth 1 -iname '*.html' -o -maxdepth 1 -iname '*.htm')"
  html_count="$(printf '%s\n' "$html_files" | grep -c . || true)"
  if [ "$html_count" -eq 0 ]; then
    echo "エラー: html ファイルが含まれていません" >&2
    exit 1
  elif [ "$html_count" -gt 1 ]; then
    echo "エラー: html が複数あります。index.html を用意してから再実行してください" >&2
    printf '%s\n' "$html_files" >&2
    exit 1
  fi
  mv "$html_files" "$STAGE_DIR/index.html"
fi

echo "素材の準備 OK: $(find "$STAGE_DIR" -type f | wc -l | tr -d ' ') ファイル"

# --- リポジトリを取得して配置 ---
CLONE_DIR="$WORK_DIR/repo"
echo "リポジトリを取得中..."
if ! git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR"; then
  echo "エラー: clone に失敗しました。書き込み権限と GitHub 認証を確認してください" >&2
  exit 1
fi

TARGET_DIR="$CLONE_DIR/$SLUG"
if [ -d "$TARGET_DIR" ]; then
  echo "警告: $SLUG は既に存在します。上書きしますか? [y/N]"
  read -r answer
  [ "$answer" = "y" ] || { echo "中止しました"; exit 1; }
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"
cp -R "$STAGE_DIR"/. "$TARGET_DIR"/

if [ "$DRY_RUN" = "1" ]; then
  echo "[dry-run] push はしません。配置結果:"
  find "$TARGET_DIR" -type f | sed "s|$CLONE_DIR/||"
  echo "[dry-run] 公開予定 URL: $BASE_URL/$SLUG/"
  exit 0
fi

# --- コミットして公開 ---
cd "$CLONE_DIR"
git add "$SLUG"
if git diff --cached --quiet; then
  echo "変更がありません。既に同じ内容が公開されています"
  exit 0
fi
git commit --quiet -m "$SLUG を公開"

if ! git push --quiet origin HEAD; then
  echo "エラー: push に失敗しました。権限を確認するか、時間をおいて再実行してください" >&2
  exit 1
fi

# --- 公開されるまで待つ ---
URL="$BASE_URL/$SLUG/"
echo "公開処理中... (最大3分)"
for i in $(seq 1 18); do
  code="$(curl -s -o /dev/null -w '%{http_code}' -L "$URL" || true)"
  if [ "$code" = "200" ]; then
    echo ""
    echo "公開完了: $URL"
    exit 0
  fi
  sleep 10
done

echo ""
echo "push は成功しましたが、まだ反映されていません（GitHub Pages のビルド待ち）"
echo "数分後にアクセスしてください: $URL"
