#!/usr/bin/env python3
"""
はぐるアプリ テストアカウント作成スクリプト
Firebase Authentication REST API を使用してテスト用アカウントを作成します。

使い方:
  1. Firebase Console → プロジェクト設定 → 全般 → ウェブ API キー をコピー
  2. 以下の API_KEY を書き換える
  3. python3 scripts/create_test_account.py を実行

必要なもの: Python 3.x (追加ライブラリ不要)
"""

import urllib.request
import urllib.error
import json
import sys

# ─── 設定 ────────────────────────────────────────────────────────────────────
API_KEY = "YOUR_FIREBASE_WEB_API_KEY"   # ← Firebase Console から取得して置き換え

TEST_ACCOUNTS = [
    {"email": "parent@haguru.test", "password": "haguru2026", "role": "親"},
    {"email": "child@haguru.test",  "password": "haguru2026", "role": "子"},
]
# ─────────────────────────────────────────────────────────────────────────────


def create_account(email: str, password: str) -> dict:
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={API_KEY}"
    payload = json.dumps({
        "email": email,
        "password": password,
        "returnSecureToken": True
    }).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = json.loads(e.read())
        error_msg = body.get("error", {}).get("message", str(e))
        return {"error": error_msg}


def main():
    if API_KEY == "YOUR_FIREBASE_WEB_API_KEY":
        print("❌ API_KEY を設定してください。")
        print("   Firebase Console → プロジェクト設定 → ウェブ API キー")
        sys.exit(1)

    print("🔑 テストアカウントを作成します...\n")
    for acc in TEST_ACCOUNTS:
        result = create_account(acc["email"], acc["password"])
        if "error" in result:
            if "EMAIL_EXISTS" in result["error"]:
                print(f"  ✅ [{acc['role']}] {acc['email']} — すでに存在します（スキップ）")
            else:
                print(f"  ❌ [{acc['role']}] {acc['email']} — {result['error']}")
        else:
            uid = result.get("localId", "?")
            print(f"  🎉 [{acc['role']}] {acc['email']} — 作成完了 (uid: {uid})")

    print("\n📋 ログイン情報")
    print("─" * 40)
    for acc in TEST_ACCOUNTS:
        print(f"  {acc['role']:4}  {acc['email']}")
        print(f"        PW: {acc['password']}")
    print("─" * 40)
    print("注意: テスト後は Firebase Console からアカウントを削除してください。")


if __name__ == "__main__":
    main()
