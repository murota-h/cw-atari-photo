# 写真リネーマー（部品タグ読み取りアプリ）

部品検査タグに書かれた **Ch.No**（チャージナンバー）と **PIN** を OCR で自動読み取りし、
写真のファイル名を `{ChNo}_{PIN}.jpg` 形式で生成するFlutterアプリです。

## 機能

- 📷 カメラ撮影 / ギャラリーから画像選択
- 🔍 Google ML Kit による**オフライン OCR**（インターネット不要）
- ✏️ 読み取り結果の手動修正
- 💾 ギャラリーへの保存
- 📋 ファイル名のクリップボードコピー

## ファイル名フォーマット

```
{Ch.No} No{PIN数字}スロー.jpg

例: W50414-D-1R No1スロー.jpg
    W50799-D-1R No8スロー.jpg
```

- `PIN` が `1P` の場合 → 数字部分の `1` を使用
- サフィックス「スロー」は確認画面で変更可能

---

## セットアップ手順

### 必要環境

- Flutter SDK 3.19以上
- Android Studio または Xcode
- Android API 21以上 / iOS 12以上

### 1. 依存パッケージのインストール

```bash
flutter pub get
```

### 2. Android の追加設定

`android/app/src/main/res/xml/file_paths.xml` を作成：

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <cache-path name="cache" path="." />
</paths>
```

`android/app/build.gradle` で minSdk を確認：

```groovy
android {
    defaultConfig {
        minSdk 21  // ← 21以上にする
    }
}
```

### 3. iOS の追加設定

`ios/Podfile` に以下を追加（既存の `platform :ios` 行を更新）：

```ruby
platform :ios, '14.0'
```

その後 Pod をインストール：

```bash
cd ios && pod install && cd ..
```

### 4. ビルド & 実行

```bash
# Android
flutter run

# iOS（実機が必要）
flutter run --release
```

---

## プロジェクト構成

```
lib/
├── main.dart                  # アプリエントリーポイント
├── screens/
│   ├── camera_screen.dart     # メイン画面（撮影・選択）
│   ├── ocr_confirm_screen.dart # OCR確認・修正画面
│   └── result_screen.dart     # 保存完了画面
└── services/
    └── ocr_service.dart       # OCR処理・ファイル名生成ロジック
```

---

## OCR認識パターン

以下のような表記を認識します：

| タグの書き方 | 認識例 |
|---|---|
| `Ch.No W50414-D-1R` | W50414-D-1R |
| `CH.NO W50414-D-1R` | W50414-D-1R |
| `Ch No W50414-D-1R` | W50414-D-1R |
| `PIN 1P` | 1P |
| `Pin 1P` | 1P |

認識できなかった場合は手動入力画面で修正できます。

---

## 使い方

1. アプリを起動
2. 「カメラで撮影」または「ギャラリーから選択」をタップ
3. 部品タグが写るように撮影（タグをしっかり画角に入れる）
4. OCR結果を確認・修正
5. 「この名前で保存」をタップ
6. 必要に応じて「ギャラリーに保存」

---

## トラブルシューティング

### OCRの精度を上げるコツ

- タグにしっかりフォーカスを合わせる
- 光源が均一になるよう撮影する
- タグが傾かないよう正面から撮影する
- 文字が鮮明に写るよう近づいて撮影する

### よくあるエラー

| エラー | 対処 |
|---|---|
| カメラが起動しない | AndroidManifest.xml のパーミッションを確認 |
| ギャラリーに保存できない | READ/WRITE_EXTERNAL_STORAGE パーミッションを確認 |
| OCRが起動しない | `flutter pub get` を再実行 |