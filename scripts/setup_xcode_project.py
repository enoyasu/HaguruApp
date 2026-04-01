#!/usr/bin/env python3
"""
HaguruApp Xcode プロジェクトセットアップスクリプト
- CFBundleDisplayName = "はぐる" をビルド設定に追加
- Firebase SPM (FirebaseAuth / FirebaseFirestore) をプロジェクトに追加
- UNUserNotification usage description を追加
"""

import re
import sys

PBXPROJ_PATH = "HaguruApp.xcodeproj/project.pbxproj"

# ───────────────────────────────────────────────────────────
# 固定UUID（pbxproj は大文字16進数24桁）
# ───────────────────────────────────────────────────────────
PKG_REF_ID      = "B0FB1A2E0F7C06B2001CFA01"   # XCRemoteSwiftPackageReference firebase-ios-sdk
AUTH_DEP_ID     = "B0FB1A2E0F7C06B2001CFA02"   # XCSwiftPackageProductDependency FirebaseAuth
STORE_DEP_ID    = "B0FB1A2E0F7C06B2001CFA03"   # XCSwiftPackageProductDependency FirebaseFirestore
AUTH_BF_ID      = "B0FB1A2E0F7C06B2001CFA04"   # PBXBuildFile FirebaseAuth
STORE_BF_ID     = "B0FB1A2E0F7C06B2001CFA05"   # PBXBuildFile FirebaseFirestore

# ターゲットの既存ID（project.pbxproj から）
APP_TARGET_ID         = "B02A71312F7C06B2001CD565"
APP_FW_BUILD_PHASE_ID = "B02A712F2F7C06B2001CD565"
APP_DEBUG_CONFIG_ID   = "B02A71562F7C06BA001CD565"
APP_RELEASE_CONFIG_ID = "B02A71572F7C06BA001CD565"
PROJECT_OBJECT_ID     = "B02A712A2F7C06B2001CD565"

def read_pbxproj():
    with open(PBXPROJ_PATH, "r", encoding="utf-8") as f:
        return f.read()

def write_pbxproj(content):
    with open(PBXPROJ_PATH, "w", encoding="utf-8") as f:
        f.write(content)

# ───────────────────────────────────────────────────────────
# 1. CFBundleDisplayName / 通知 usage description を追加
# ───────────────────────────────────────────────────────────
DISPLAY_NAME_LINE = '\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "\\U306f\\U3050\\U308b";'
NOTIF_USAGE_LINE  = '\t\t\t\tINFOPLIST_KEY_NSUserNotificationsUsageDescription = "\\U6c34\\U3084\\U308a\\U3084\\U6c17\\U6301\\U3061\\U306e\\U304a\\U77e5\\U3089\\U305b\\U306b\\U4f7f\\U7528\\U3057\\U307e\\U3059";'
INFOPLIST_KEYS = DISPLAY_NAME_LINE + "\n" + NOTIF_USAGE_LINE

def add_infoplist_keys(content):
    """Debug / Release 両 config に INFOPLIST_KEY を追加"""
    if "INFOPLIST_KEY_CFBundleDisplayName" in content:
        print("  ⏭  CFBundleDisplayName は既に設定されています")
        return content

    # 対象: アプリターゲットの Debug/Release config
    # ASSETCATALOG_COMPILER_APPICON_NAME の後に挿入
    pattern = r'(ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;)'
    insert_str = "\n" + INFOPLIST_KEYS
    def replacer(m):
        return m.group(1) + insert_str
    new_content = re.sub(pattern, replacer, content)
    n = len(re.findall(pattern, content))
    if n == 0:
        print("  ⚠️  ASSETCATALOG_COMPILER_APPICON_NAME が見つかりません")
        return content
    print(f"  ✅  CFBundleDisplayName を {n} 箇所に追加")
    return new_content

# ───────────────────────────────────────────────────────────
# 2. Firebase SPM — XCRemoteSwiftPackageReference セクション追加
# ───────────────────────────────────────────────────────────
REMOTE_PKG_SECTION = f"""
/* Begin XCRemoteSwiftPackageReference section */
\t\t{PKG_REF_ID} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "https://github.com/firebase/firebase-ios-sdk";
\t\t\trequirement = {{
\t\t\t\tkind = upToNextMajorVersion;
\t\t\t\tminimumVersion = 11.0.0;
\t\t\t}};
\t\t}};
/* End XCRemoteSwiftPackageReference section */
"""

PRODUCT_DEP_SECTION = f"""
/* Begin XCSwiftPackageProductDependency section */
\t\t{AUTH_DEP_ID} /* FirebaseAuth */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF_ID} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
\t\t\tproductName = FirebaseAuth;
\t\t}};
\t\t{STORE_DEP_ID} /* FirebaseFirestore */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF_ID} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
\t\t\tproductName = FirebaseFirestore;
\t\t}};
/* End XCSwiftPackageProductDependency section */
"""

BUILD_FILES = f"""\t\t{AUTH_BF_ID} /* FirebaseAuth in Frameworks */ = {{isa = PBXBuildFile; productRef = {AUTH_DEP_ID} /* FirebaseAuth */; }};
\t\t{STORE_BF_ID} /* FirebaseFirestore in Frameworks */ = {{isa = PBXBuildFile; productRef = {STORE_DEP_ID} /* FirebaseFirestore */; }};"""

def add_firebase_spm(content):
    """Firebase SPM パッケージ参照を pbxproj に追加"""
    if PKG_REF_ID in content:
        print("  ⏭  Firebase SPM は既に追加されています")
        return content

    # ─── PBXBuildFile セクションに追加（なければ新規作成） ───
    build_file_end_pat = r'(/\* End PBXBuildFile section \*/)'
    build_file_begin_pat = r'(/\* Begin PBXBuildFile section \*/)'

    if "/* Begin PBXBuildFile section */" in content:
        # 既存セクションの末尾に挿入
        def bf_replacer(m):
            return BUILD_FILES + "\n" + m.group(1)
        content = re.sub(build_file_end_pat, bf_replacer, content)
        print("  ✅  PBXBuildFile セクションに Firebase ビルドファイルを追加")
    else:
        # セクション自体を新規作成し PBXContainerItemProxy の後ろに挿入
        new_section = (
            "\n/* Begin PBXBuildFile section */\n"
            + BUILD_FILES + "\n"
            + "/* End PBXBuildFile section */\n"
        )
        container_end = r'(/\* End PBXContainerItemProxy section \*/)'
        def ci_replacer(m):
            return m.group(1) + new_section
        content = re.sub(container_end, ci_replacer, content)
        print("  ✅  PBXBuildFile セクションを新規作成して Firebase ビルドファイルを追加")

    # ─── XCRemoteSwiftPackageReference セクション を末尾近くに追加 ───
    # XCConfigurationList の後ろに追加
    config_list_end = r'(/\* End XCConfigurationList section \*/)'
    append_sections = REMOTE_PKG_SECTION + PRODUCT_DEP_SECTION
    def cl_replacer(m):
        return m.group(1) + append_sections
    content = re.sub(config_list_end, cl_replacer, content)
    n = len(re.findall(config_list_end, content))
    if n == 0:
        print("  ⚠️  XCConfigurationList セクション末尾が見つかりません")
        return content

    # ─── PBXFrameworksBuildPhase にビルドファイルを追加 ───
    # アプリターゲットの Frameworks build phase: B02A712F2F7C06B2001CD565
    fw_pattern = rf'({APP_FW_BUILD_PHASE_ID} /\* Frameworks \*/ = \{{\s+isa = PBXFrameworksBuildPhase;.*?files = \()'
    auth_line  = f'\t\t\t\t{AUTH_BF_ID} /* FirebaseAuth in Frameworks */,'
    store_line = f'\t\t\t\t{STORE_BF_ID} /* FirebaseFirestore in Frameworks */,'
    def fw_replacer(m):
        return m.group(1) + "\n" + auth_line + "\n" + store_line
    new_content2 = re.sub(fw_pattern, fw_replacer, content, flags=re.DOTALL)
    n = 0 if new_content2 == content else 1
    content = new_content2
    if n == 0:
        print("  ⚠️  PBXFrameworksBuildPhase が見つかりません")
    else:
        print("  ✅  PBXFrameworksBuildPhase に Firebase フレームワークを追加")

    # ─── HaguruApp ターゲットの packageProductDependencies に追加 ───
    pkg_dep_pattern = rf'({APP_TARGET_ID} /\* HaguruApp \*/ = \{{.*?packageProductDependencies = \()'
    auth_dep_line  = f'\t\t\t\t{AUTH_DEP_ID} /* FirebaseAuth */,'
    store_dep_line = f'\t\t\t\t{STORE_DEP_ID} /* FirebaseFirestore */,'
    def pd_replacer(m):
        return m.group(1) + "\n" + auth_dep_line + "\n" + store_dep_line
    new_content3 = re.sub(pkg_dep_pattern, pd_replacer, content, flags=re.DOTALL)
    n = 0 if new_content3 == content else 1
    content = new_content3
    if n == 0:
        print("  ⚠️  packageProductDependencies が見つかりません")
    else:
        print("  ✅  packageProductDependencies に Firebase を追加")

    # ─── PBXProject に packages エントリを追加 ───
    # minimizedProjectReferenceProxies の後に追加
    proj_pattern = r'(minimizedProjectReferenceProxies = 1;)'
    pkg_entry = (
        f'\n\t\t\tpackages = (\n'
        f'\t\t\t\t{PKG_REF_ID} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */,\n'
        f'\t\t\t);'
    )
    def proj_replacer(m):
        return m.group(1) + pkg_entry
    new_content4 = re.sub(proj_pattern, proj_replacer, content)
    n = 0 if new_content4 == content else 1
    content = new_content4
    if n == 0:
        print("  ⚠️  PBXProject の packages エントリ追加に失敗")
    else:
        print("  ✅  PBXProject に Firebase package reference を追加")

    return content

# ───────────────────────────────────────────────────────────
# Main
# ───────────────────────────────────────────────────────────
def main():
    print("🔧 HaguruApp Xcode プロジェクト設定を更新中...")

    content = read_pbxproj()

    print("\n📝 CFBundleDisplayName / 通知設定を追加...")
    content = add_infoplist_keys(content)

    print("\n📦 Firebase SPM を追加...")
    content = add_firebase_spm(content)

    write_pbxproj(content)
    print("\n✅ project.pbxproj を更新しました")

if __name__ == "__main__":
    main()
