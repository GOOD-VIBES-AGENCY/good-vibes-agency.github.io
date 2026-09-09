# サイト直下にページを公開する（管理者向け）

このリポジトリは **会社サイト本体** です。`index.html` や `CNAME` を壊すとサイト全体が落ちるため、
**メンバーのレポート公開には使いません。**

- メンバー向けのレポート公開先 → https://github.com/GOOD-VIBES-AGENCY/reports
- 公開URL → https://goodvibesagency.tokyo/reports/

## publish.sh

サイト直下（`https://goodvibesagency.tokyo/<スラッグ>/`）にページを追加する場合に使います。

```bash
./tools/publish.sh <zipまたはhtmlファイル> <URLスラッグ>
```

例:

```bash
./tools/publish.sh ~/Downloads/レポート.zip 202609-snidel-ig-pr-report
# → https://goodvibesagency.tokyo/202609-snidel-ig-pr-report/
```

zipの展開 → `index.html` へのリネーム → commit → push → 公開確認まで自動で行います。
`--dry-run` を付けると push せずに配置結果だけ確認できます。

## 注意

- スラッグは半角英小文字・数字・ハイフンのみ
- 既存のリポジトリ名（`gva-cast`、`talents`、`reports` など）と重複させないこと。
  重複するとリポジトリ側が優先され、フォルダが表示されません
