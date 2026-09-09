# レポート公開ツール

`https://goodvibesagency.tokyo/<スラッグ>/` にHTMLレポートを公開するためのスクリプトです。

## 初回だけやること

1. GitHub の招待メールを承認する（このリポジトリへの書き込み権限）
2. このリポジトリを clone する

```bash
git clone https://github.com/GOOD-VIBES-AGENCY/good-vibes-agency.github.io.git
cd good-vibes-agency.github.io
```

## 公開する

```bash
./tools/publish.sh <zipまたはhtmlファイル> <URLスラッグ>
```

例:

```bash
./tools/publish.sh ~/Downloads/SNIDEL_レポート.zip 202609-snidel-ig-pr-report
# → https://goodvibesagency.tokyo/202609-snidel-ig-pr-report/
```

push せずに動作確認だけしたい場合は `--dry-run` を付けます。

## ルール

- スラッグは半角英小文字・数字・ハイフンのみ。`YYYYMM-ブランド名-内容` の形式で統一する
  - 例: `202609-snidel-ig-pr-report`
- zip の中身は HTML 1枚（画像などを同梱する場合は `index.html` を必ず含める）
- 公開反映まで 1〜3分かかります
- ルート直下のフォルダ名は、既存のリポジトリ名と重複させないこと（リポジトリ側が優先されて表示されません）
