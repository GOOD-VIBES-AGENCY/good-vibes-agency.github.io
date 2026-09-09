# レポート公開マニュアル

HTMLレポートを `https://goodvibesagency.tokyo/<スラッグ>/` で公開するための手順です。

---

## STEP 0. 招待を承認する（初回だけ）

1. GitHub から届いた招待メールを開き、**Accept invitation** をクリック
   - メールが見つからない場合はログイン後にこちら → https://github.com/GOOD-VIBES-AGENCY/good-vibes-agency.github.io/invitations
2. 画面上部に **Code / Issues / Settings** などのタブが見えれば権限OK

---

## STEP 1. ファイルを準備する

1. 公開したいHTMLファイルの名前を **`index.html`** に変更する
2. デスクトップに **フォルダ** を作り、その中に `index.html` を入れる

フォルダ名がそのままURLになります。

```
202609-snidel-ig-pr-report/     ← このフォルダ名がURLになる
└── index.html
```

→ 公開URL: `https://goodvibesagency.tokyo/202609-snidel-ig-pr-report/`

### フォルダ名（スラッグ）のルール

| ルール | 例 |
|---|---|
| 半角英小文字・数字・ハイフンのみ | `202609-snidel-ig-pr-report` |
| 形式は `年月-ブランド名-内容` | `202610-tangle-lp` |
| 日本語・スペース・アンダースコアは使わない | ❌ `SNIDEL_レポート` |
| 既存フォルダ名と重複させない | 重複すると上書きになります |

画像などを一緒に載せる場合は、同じフォルダに入れて `index.html` から相対パスで参照してください。

---

## STEP 2. アップロードする（ブラウザだけで完結）

1. https://github.com/GOOD-VIBES-AGENCY/good-vibes-agency.github.io を開く
2. 緑の **Add file** ボタン → **Upload files** をクリック
3. STEP 1 で作った **フォルダごと** 画面にドラッグ＆ドロップ
   - フォルダ構造はそのまま保持されます
4. 下部の **Commit changes** ボタンをクリック

---

## STEP 3. 公開を確認する

- コミットから **1〜3分** で反映されます
- ブラウザで `https://goodvibesagency.tokyo/<フォルダ名>/` を開いて表示を確認
- 404 の場合はもう少し待ってから再読み込み（反映待ちです）

### 修正したいとき

同じ手順で同じフォルダ名のままアップロードし直せば上書きされます。

---

## ⚠️ 注意

- このサイトは **誰でも見られる公開ページ** です。URLを知っていればアクセスできます
- 未公開情報・個人情報・単価などが含まれていないか、アップロード前に必ず確認してください
- ルート直下の他のファイル（`index.html`, `CNAME` など）は**触らないでください**。会社サイト本体です

---

## （上級者向け）コマンドで公開する

Git が使える場合は1コマンドで完結します。

```bash
git clone https://github.com/GOOD-VIBES-AGENCY/good-vibes-agency.github.io.git
cd good-vibes-agency.github.io
./tools/publish.sh ~/Downloads/レポート.zip 202609-snidel-ig-pr-report
```

zipの展開 → `index.html` へのリネーム → commit → push → 公開確認まで自動で行います。
push せずに動作確認だけしたい場合は `--dry-run` を付けてください。
