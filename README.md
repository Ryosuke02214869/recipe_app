# レシピ保存アプリ (Recipe App)

Flutterで作成したレシピ管理アプリです。レシピの登録、編集、削除、タグによる検索ができます。

## 機能

- レシピの登録・編集・削除
- タグによるレシピの分類とフィルタリング
- 材料と作り方の管理
- 作成日・更新日の自動記録

## プラットフォーム

- Android（現在開発中）
- iOS（今後対応予定）

## カラースキーム

- メインカラー（背景）: #FFFFFF
- ベースカラー（文字・要素）: #333333
- アクセントカラー1（強調）: #4CAF50（グリーン）
- アクセントカラー2（サブ）: #2196F3（ブルー）

## 開発環境のセットアップ

### 必要なもの

- Flutter SDK 3.24.5以上
- Dart SDK 3.9.2以上
- Android Studio（Android開発用）
- Xcode（iOS開発用、macOSのみ）

### インストール手順

1. リポジトリのクローン
```bash
git clone https://github.com/Ryosuke02214869/recipe_app.git
cd recipe_app
```

2. 依存関係のインストール
```bash
flutter pub get
```

3. アプリの起動
```bash
flutter run
```

## Android APKのビルド（GitHub Actions）

このプロジェクトでは、GitHub ActionsでAndroid APKを自動ビルドできます。

### 自動ビルド

以下のブランチにプッシュすると自動的にAPKがビルドされます：

- `main`ブランチ
- `claude/**`で始まるブランチ

ビルドされたAPKは、GitHubの**Actions**タブから**Artifacts**としてダウンロードできます。

### 手動ビルド

1. GitHubリポジトリの**Actions**タブを開く
2. 左サイドバーから**Android APK Build**を選択
3. 右上の**Run workflow**ボタンをクリック
4. ビルドモードを選択（Release or Debug）
5. **Run workflow**をクリックして実行

### APKのダウンロード方法

1. **Actions**タブを開く
2. 完了したワークフローをクリック
3. 下部の**Artifacts**セクションから`android-release-apk-xxxxx`または`android-debug-apk-xxxxx`をダウンロード
4. ZIPファイルを解凍してAPKを取得
5. Android実機にAPKをインストール

**注意**: 初回インストール時は「提供元不明のアプリ」のインストール許可が必要です。

### ビルドの種類

- **Release**: 本番環境用の最適化されたAPK（推奨）
- **Debug**: デバッグ用のAPK（開発時のみ）

### トラブルシューティング

**ビルドが失敗する場合:**

1. `pubspec.yaml`の依存関係が正しいか確認
2. `android/app/build.gradle.kts`の設定を確認
3. GitHub Actionsのログを確認

**APKがインストールできない場合:**

1. Android端末で「提供元不明のアプリ」のインストールを許可
2. 古いバージョンがインストールされている場合は先にアンインストール
3. 端末のAndroidバージョンがminSdkVersion以上か確認

## ローカルでのAPKビルド

GitHub Actionsを使わず、ローカルでビルドする場合：

```bash
# Releaseビルド
flutter build apk --release

# Debugビルド
flutter build apk --debug

# APKの場所
# build/app/outputs/flutter-apk/app-release.apk
# または
# build/app/outputs/flutter-apk/app-debug.apk
```

## プロジェクト構成

```
lib/
├── main.dart              # アプリのエントリーポイント
├── models/
│   └── recipe.dart        # レシピデータモデル
└── screens/
    ├── home_screen.dart          # ホーム画面（レシピ一覧）
    ├── recipe_detail_screen.dart # レシピ詳細画面
    └── recipe_form_screen.dart   # レシピ追加・編集画面
```

## 技術スタック

- **Framework**: Flutter 3.24.5
- **Language**: Dart 3.9.2
- **UI**: Material Design 3
- **CI/CD**: GitHub Actions

## 今後の予定

- [ ] iOS対応
- [ ] データの永続化（SharedPreferences or SQLite）
- [ ] レシピ画像の追加機能
- [ ] レシピの共有機能
- [ ] ダークモード対応

## ライセンス

このプロジェクトはプライベートプロジェクトです。

## 参考リンク

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart公式ドキュメント](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
