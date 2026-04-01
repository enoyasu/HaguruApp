# Xcode セットアップ手順

## 新規ファイルをXcodeプロジェクトに追加する

ファイルはすでに `HaguruApp/` フォルダに生成されていますが、
Xcodeプロジェクト（.xcodeproj）に登録する必要があります。

### 最も簡単な方法

1. Xcode で `HaguruApp.xcodeproj` を開く
2. プロジェクトナビゲーター（左パネル）で `HaguruApp` グループを右クリック
3. `Add Files to "HaguruApp"...` を選択
4. 以下のフォルダを選択して追加（**Create groups** を選択）：
   - `App/`
   - `Core/`
   - `DesignSystem/`
   - `Models/`
   - `Services/`
   - `Repositories/`
   - `Features/`

### 確認事項

追加後、以下を確認してください：

- `HaguruAppApp.swift`（元のファイル、空のプレースホルダに変更済み）
- `App/HaguruAppApp.swift`（新しいエントリポイント）— `@main` はここにある

重複する `@main` がある場合はビルドエラーになります。
`HaguruApp/HaguruAppApp.swift` が空のプレースホルダになっているか確認してください。

### Item.swift について

`HaguruApp/Item.swift` は SwiftData 参照を削除済みです。
`ContentView.swift` も RootView へのパススルーに変更しています。

### Firebase SPM パッケージ追加後

`FirebaseAuth`、`FirebaseFirestore` を追加すると、
`#if canImport(FirebaseAuth)` ブロックが有効になり、実際の Firebase 通信が始まります。
