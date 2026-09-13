
## flutter doctor -v 실행 결과

[✓] Flutter (Channel stable, 3.47.4, on macOS 26.6.2 25G83 darwin-arm64, locale ko-KR) [354ms]
    • Flutter version 3.47.4 on channel stable at /Users/gene/development/flutter/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 9584c6713b (3 days ago), 2026-09-10 15:25:10 -0700
    • Engine revision 06a2e2a110
    • Dart version 3.13.3
    • DevTools version 2.60.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios,
      cli-animations, enable-native-assets, enable-record-use, enable-swift-package-manager, omit-legacy-version-file,
      enable-lldb-debugging, enable-uiscene-migration

[✗] Android toolchain - develop for Android devices [319ms]
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/to/macos-android-setup for detailed instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.


[✓] Xcode - develop for iOS and macOS (Xcode 26.6) [709ms]
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 17F113
    • CocoaPods version 1.17.0

[✓] Chrome - develop for the web [4ms]
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Connected device (3 available) [6.2s]
    • iPhone 17 (mobile) • DCF72864-55FC-4CF8-A902-FF5DF7BA03D9 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-26-5
      (simulator)
    • macOS (desktop)    • macos                                • darwin-arm64   • macOS 26.6.2 25G83 darwin-arm64
    • Chrome (web)       • chrome                               • web-javascript • Google Chrome 152.0.7977.84

[✓] Network resources [737ms]
    • All expected network resources are available.


### 오류: CocoaPods not installed

`flutter doctor -v` 실행 결과, Xcode 항목에서 아래와 같은 경고가 발생했다.

```
[!] Xcode - develop for iOS and macOS (Xcode 26.6)
    ! CocoaPods not installed.
        CocoaPods is a package manager for iOS or macOS platform code.
        Without CocoaPods, plugins will not work on iOS or macOS.
```

CocoaPods가 설치되어 있지 않아 iOS/macOS 플랫폼에서 플러그인이 정상 동작하지 않는 상태였다.

### 해결 과정

1. `pod --version` 실행 시 `command not found: pod` 오류로 미설치 상태 확인
2. Flutter 공식 문서 안내에 따라 `sudo gem install cocoapods` 대신, 시스템 Ruby와의 충돌을 피하기 위해 Homebrew를 이용해 설치

   ```bash
   brew install cocoapods
   ```
3. 설치 완료 후 `pod --version` 실행 → `1.17.0` 정상 출력 확인
4. `flutter doctor -v` 재실행 → Xcode 항목이 `[!]`에서 `[✓]`로 변경된 것을 확인하여 해결 완료

