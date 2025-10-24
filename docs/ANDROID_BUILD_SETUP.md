# Android APKビルド設定ガイド

このドキュメントでは、GitHub ActionsでAndroid APKを自動ビルドする設定について詳しく説明します。

## 目次

1. [GitHub Actionsの概要](#github-actionsの概要)
2. [ワークフローファイルの説明](#ワークフローファイルの説明)
3. [ビルドの実行方法](#ビルドの実行方法)
4. [APKのダウンロードとインストール](#apkのダウンロードとインストール)
5. [カスタマイズ方法](#カスタマイズ方法)
6. [トラブルシューティング](#トラブルシューティング)

## GitHub Actionsの概要

GitHub Actionsは、GitHubが提供する自動化プラットフォームです。コードのプッシュやプルリクエストなどのイベントをトリガーとして、ビルドやテスト、デプロイなどを自動実行できます。

### このプロジェクトでのGitHub Actions

`.github/workflows/android-build.yml`ファイルで定義されたワークフローが、以下のタイミングでAndroid APKをビルドします：

- **自動ビルド**: `main`ブランチまたは`claude/**`で始まるブランチへのプッシュ
- **手動ビルド**: GitHubのActionsタブから手動実行

## ワークフローファイルの説明

### トリガー設定

```yaml
on:
  workflow_dispatch:
    inputs:
      build_mode:
        description: 'ビルドモード'
        required: true
        default: 'release'
        type: choice
        options:
          - release
          - debug

  push:
    branches:
      - main
      - 'claude/**'
```

- `workflow_dispatch`: 手動実行を可能にする
- `push`: 指定されたブランチへのプッシュで自動実行

### ビルドステップ

1. **リポジトリのチェックアウト** (`actions/checkout@v4`)
   - ソースコードを取得

2. **Javaのセットアップ** (`actions/setup-java@v4`)
   - Androidビルドに必要なJava 17をインストール

3. **Flutterのセットアップ** (`subosito/flutter-action@v2`)
   - Flutter SDK（Stable channelの最新版）をインストール

4. **依存関係の取得**
   - `flutter pub get`で必要なパッケージをダウンロード

5. **APKのビルド**
   - `flutter build apk --release`または`--debug`でビルド

6. **Artifactsへのアップロード** (`actions/upload-artifact@v4`)
   - ビルドしたAPKをダウンロード可能な状態で保存（30日間保持）

## ビルドの実行方法

### 方法1: 自動ビルド（プッシュ時）

1. ローカルで変更を加える
2. コミット＆プッシュ
```bash
git add .
git commit -m "機能追加"
git push origin <ブランチ名>
```
3. GitHubの**Actions**タブで自動的にビルドが開始される

### 方法2: 手動ビルド

1. GitHubリポジトリページを開く
2. 上部メニューの**Actions**タブをクリック
3. 左サイドバーから**Android APK Build**を選択
4. 右上の**Run workflow**ボタンをクリック
5. ドロップダウンから以下を選択：
   - Branch: ビルドしたいブランチ
   - ビルドモード: `release`（推奨）または`debug`
6. **Run workflow**ボタンをクリックして実行

### ビルド状況の確認

- **Actions**タブで実行中のワークフローが表示される
- ビルドには約5〜10分かかる
- ✅緑のチェックマーク = 成功
- ❌赤のバツマーク = 失敗（ログを確認）

## APKのダウンロードとインストール

### APKのダウンロード

1. **Actions**タブを開く
2. 完了したワークフロー（✅マーク付き）をクリック
3. ページ下部の**Artifacts**セクションを見る
4. `android-release-apk-YYYYMMDD-HHMMSS`または`android-debug-apk-YYYYMMDD-HHMMSS`をクリック
5. ZIPファイルがダウンロードされる
6. ZIPを解凍してAPKファイルを取り出す

### Android端末へのインストール

#### 方法1: USBケーブル経由

1. Android端末をUSBケーブルでPCに接続
2. 端末で「USBデバッグ」を有効化
   - 設定 → 開発者向けオプション → USBデバッグ
3. adbコマンドでインストール：
```bash
adb install recipe_app-release-YYYYMMDD-HHMMSS.apk
```

#### 方法2: ファイル転送経由

1. APKファイルを端末に転送（メール、クラウド、USB経由など）
2. 端末のファイルマネージャーでAPKファイルを開く
3. 「提供元不明のアプリのインストール」を許可
4. インストールをタップ

### 提供元不明のアプリの許可方法

Android 8.0以降：
1. 設定 → アプリと通知
2. 特別なアプリアクセス
3. 不明なアプリのインストール
4. 使用するアプリ（例：Chrome、Files）を選択
5. 「この提供元を許可する」をオン

## カスタマイズ方法

### ビルド対象ブランチの変更

`.github/workflows/android-build.yml`の`push.branches`を編集：

```yaml
push:
  branches:
    - main
    - develop
    - 'feature/**'
```

### Flutterバージョンの変更

特定のバージョンを指定する場合、`flutter-version`を追加：

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.0'  # 任意のバージョン
    channel: 'stable'
```

**注意**: バージョンを指定しない場合は、Stable channelの最新版が自動的に使用されます（推奨）。

### APKの保存期間の変更

デフォルトは30日間。変更する場合：

```yaml
- name: Upload APK as artifact
  uses: actions/upload-artifact@v4
  with:
    retention-days: 90  # 90日間保存
```

### ビルドの最適化オプション

ファイルサイズを小さくする場合：

```yaml
- name: Build APK
  run: |
    flutter build apk --release --split-per-abi
```

これにより、CPU アーキテクチャごとに分割されたAPKが生成されます（arm64-v8a、armeabi-v7a、x86_64）。

### App Bundleのビルド

Google Play Storeへの公開を予定している場合は、AAB（App Bundle）形式が推奨：

```yaml
- name: Build App Bundle
  run: |
    flutter build appbundle --release
```

## トラブルシューティング

### ビルドが失敗する

#### エラー: Gradle build failed

**原因**: Gradle設定またはAndroid設定の問題

**解決方法**:
1. `android/app/build.gradle.kts`の設定を確認
2. `compileSdk`、`minSdk`、`targetSdk`のバージョンを確認
3. GitHub Actionsのログで詳細なエラーメッセージを確認

#### エラー: Flutter dependencies error

**原因**: `pubspec.yaml`の依存関係の問題

**解決方法**:
1. `pubspec.yaml`の構文エラーを確認
2. ローカルで`flutter pub get`が成功するか確認
3. 依存パッケージのバージョンを更新

#### エラー: Out of memory

**原因**: ビルドプロセスのメモリ不足

**解決方法**:
`android/gradle.properties`に以下を追加：
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
```

### APKがインストールできない

#### エラー: App not installed

**原因1**: 既に古いバージョンがインストールされている

**解決方法**:
1. 既存のアプリをアンインストール
2. 再度APKをインストール

**原因2**: 署名の不一致

**解決方法**:
- Debug APKとRelease APKは署名が異なるため、切り替える場合は一度アンインストールが必要

**原因3**: 端末のAndroidバージョンが古い

**解決方法**:
- `android/app/build.gradle.kts`の`minSdk`を確認
- 端末のAndroidバージョンがminSdk以上であることを確認

### Artifactsが表示されない

**原因**: ビルドが完了していない、または失敗している

**解決方法**:
1. ワークフローが完全に完了するまで待つ（✅マーク）
2. 失敗している場合はログを確認
3. ワークフローを再実行

## 必要な設定（リポジトリ側）

### GitHub Actionsの有効化

1. リポジトリの**Settings**タブを開く
2. 左サイドバーの**Actions** → **General**を選択
3. **Actions permissions**で以下を選択：
   - "Allow all actions and reusable workflows"
4. **Workflow permissions**で以下を選択：
   - "Read and write permissions"

これで、GitHub ActionsがArtifactsをアップロードできるようになります。

## 参考リンク

- [GitHub Actions公式ドキュメント](https://docs.github.com/en/actions)
- [Flutter公式ドキュメント - Android](https://docs.flutter.dev/deployment/android)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)

## 次のステップ

- **自動テストの追加**: ビルド前に`flutter test`を実行
- **コード品質チェック**: `flutter analyze`でコードの静的解析
- **Google Play Storeへの自動デプロイ**: `fastlane`を使用した自動公開
- **署名の設定**: リリースビルド用の署名キーの設定
