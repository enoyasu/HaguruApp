# はぐる | やさしくつながる共育アプリ

**HaguruApp** — 親子が共通の育成対象を通じて、自然に継続的なコミュニケーションを取れるiPhoneアプリ。

---

## コンセプト

> 一緒に何かを育てることで、離れていても自然につながれる。

- 長文会話を強制せず、スタンプや一言で関われる
- タスク管理・監視アプリに見えない
- 1回10秒〜1分程度でも使える
- 思春期の親子にも重くない接点を作る

---

## 技術スタック

| 項目 | 内容 |
|---|---|
| 言語 | Swift 5.10+ |
| UI | SwiftUI |
| アーキテクチャ | MVVM + Repository パターン |
| 認証 | Firebase Authentication（メール認証） |
| データベース | Cloud Firestore |
| ストレージ | Firebase Storage（将来拡張） |
| 通知 | ローカル通知（将来 FCM/APNs へ拡張） |
| 非同期 | Swift Concurrency (async/await) |

---

## ディレクトリ構成

```
HaguruApp/
├── App/
│   └── HaguruAppApp.swift        # @main エントリポイント + RootView ルーター
├── Core/
│   ├── Extensions/
│   │   └── View+Extensions.swift
│   └── Utils/
│       └── InviteCodeGenerator.swift
├── DesignSystem/
│   ├── ThemeColors.swift          # ブランドカラー / Hex init
│   ├── DesignTokens.swift         # スペーシング / 角丸 / アニメーション / ButtonStyle
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── SoftCard.swift         # GrowthStatusCard を含む
│       ├── TimelineRow.swift
│       ├── StampPicker.swift
│       ├── EmptyStateView.swift
│       ├── InviteCodeCard.swift
│       └── SectionHeader.swift    # HaguruBrandHeader を含む
├── Models/
│   ├── HaguruUser.swift
│   ├── PairLink.swift
│   ├── GrowthObject.swift
│   ├── ActivityLog.swift
│   ├── Diary.swift
│   └── NotificationItem.swift
├── Services/
│   ├── FirebaseService.swift      # Firebase 設定ガード
│   ├── AuthService.swift          # Firebase Auth ラッパー
│   └── NotificationService.swift  # ローカル通知 / 将来 FCM 拡張
├── Repositories/
│   ├── UserRepository.swift
│   ├── PairLinkRepository.swift
│   ├── GrowthObjectRepository.swift
│   └── ActivityLogRepository.swift
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   ├── NicknameSetupView.swift
│   │   └── RoleSelectionView.swift
│   ├── Invitation/
│   │   ├── RelationshipSelectionView.swift
│   │   ├── GrowthObjectSelectionView.swift
│   │   ├── WaitingForPairView.swift
│   │   └── EnterInviteCodeView.swift
│   ├── Home/
│   │   ├── HomeViewModel.swift
│   │   └── HomeView.swift
│   ├── Timeline/
│   │   ├── TimelineViewModel.swift
│   │   └── TimelineView.swift
│   ├── Connection/
│   │   ├── ConnectionViewModel.swift
│   │   └── ConnectionView.swift
│   ├── Profile/
│   │   ├── ProfileViewModel.swift
│   │   └── ProfileView.swift
│   └── Main/
│       └── MainTabView.swift
└── Resources/
    └── Assets.xcassets/           # ブランドカラー colorset 含む
```

---

## セットアップ手順

### 1. Xcodeプロジェクトを開く

```bash
open HaguruApp.xcodeproj
```

### 2. Firebase SDK を SPM で追加

Xcode メニュー: `File > Add Package Dependencies`

- URL: `https://github.com/firebase/firebase-ios-sdk`
- バージョン: 10.x 以降
- 追加するパッケージ:
  - `FirebaseAuth`
  - `FirebaseFirestore`
  - `FirebaseStorage`（将来拡張用）

### 3. Firebase プロジェクトを作成

1. [Firebase Console](https://console.firebase.google.com/) でプロジェクト作成
2. iOS アプリを登録
   - Bundle ID: `com.yasu.HaguruApp`（自分のドメインに変更推奨）
3. `GoogleService-Info.plist` をダウンロード
4. Xcode の `HaguruApp/` 以下にドラッグ＆ドロップ（**Copy items if needed** にチェック）

### 4. Firestore セキュリティルール

Firebase Console の Firestore > ルール に以下を設定：

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userID} {
      allow read, write: if request.auth.uid == userID;
    }
    match /pairLinks/{linkID} {
      allow read: if request.auth.uid == resource.data.parentUserID
                  || request.auth.uid == resource.data.childUserID;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.parentUserID
                    || request.auth.uid == resource.data.childUserID;
    }
    match /growthObjects/{objectID} {
      allow read, write: if request.auth != null;
      // TODO: pairLinkID 経由でユーザー検証を強化
    }
    match /activityLogs/{logID} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Firestore インデックス

以下のインデックスが必要です（Firebase Console > Firestore > インデックス）：

| コレクション | フィールド 1 | フィールド 2 | 順序 |
|---|---|---|---|
| pairLinks | parentUserID | inviteStatus | ASC |
| pairLinks | childUserID | inviteStatus | ASC |
| activityLogs | growthObjectID | createdAt | DESC |

### 6. Authentication を有効化

Firebase Console > Authentication > Sign-in method:
- **メール/パスワード** を有効化

---

## Bundle Identifier の変更

`HaguruApp.xcodeproj/project.pbxproj` の `PRODUCT_BUNDLE_IDENTIFIER` を変更するか、
Xcode の `Signing & Capabilities` タブで変更してください。

現在の設定:
- アプリ: `com.yasu.HaguruApp`
- テスト: `com.yasu.HaguruAppTests`
- UIテスト: `com.yasu.HaguruAppUITests`

---

## CFBundleDisplayName（ホーム画面表示名）

Xcode の `Info` タブ > `Bundle display name` を `はぐる` に設定するか、
`Info.plist` に以下を追加してください：

```xml
<key>CFBundleDisplayName</key>
<string>はぐる</string>
```

---

## Firebase 未設定時の動作

`GoogleService-Info.plist` が存在しない場合でも：
- ビルドは通ります
- 各 Repository はデータを返さず空の状態になります
- Preview は Mock データで動作します

コンソールに以下のログが出力されます：
```
[HaguruApp] ⚠️ GoogleService-Info.plist が見つかりません。Firebase機能はモックモードで動作します。
```

---

## 画面フロー

```
オンボーディング
  └─ サインアップ / ログイン
       └─ ニックネーム設定
            └─ ロール選択（親 / 子）
                 ├─ [子] 関係性選択 → 招待コード発行 → 育成対象選択 → 待機画面
                 └─ [親] 招待コード入力 → メイン画面
                                           └─ タブ: ホーム / 記録 / つながり / マイページ
```

---

## 今後の拡張ポイント

### 近い将来
- Push 通知（FCM 統合）— `NotificationService.swift` に拡張ポイントあり
- 画像投稿（Firebase Storage）— `ActivityLog.imageURL` フィールド実装済み
- 日記タイトル・気分表示の強化
- 複数育成対象のサポート

### 中期
- 電話番号認証の追加（Firebase Auth 対応済み）
- 複数家族グループ
- 成長履歴グラフ・統計
- テーマ・カラーカスタマイズ

### 長期
- AI による会話のきっかけ提案
- 植物 IoT 連携
- AR 育成体験

---

## アプリ名の使い分け

| 場所 | 表示 |
|---|---|
| iOSホーム画面 | はぐる |
| CFBundleDisplayName | はぐる |
| App Store アプリ名 | はぐる |
| App Store サブタイトル | やさしくつながる共育アプリ |
| Xcode プロジェクト名 | HaguruApp |
| Bundle Identifier | com.yourname.HaguruApp |
| コード内クラス/構造体 | HaguruApp〜 |

---

## ライセンス

MIT License — 詳細は LICENSE ファイルを参照してください。
