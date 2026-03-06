@echo off
echo ============================================================
echo   Ci(TM) Metering - Vacuum Bags SARL  [Build Script]
echo   vacuumbags.com.lb
echo   Powered by CCG  ^|  ccg.support
echo ============================================================
echo.

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found in PATH.
    echo         Please install Flutter: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo [1/4] Getting dependencies...
flutter pub get
if errorlevel 1 goto :error

echo.
echo [2/4] Running code generation (Hive / Riverpod)...
dart run build_runner build --delete-conflicting-outputs
if errorlevel 1 goto :error

echo.
echo [3/4] Building APK (release)...
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
if errorlevel 1 goto :error

echo.
echo [4/4] Done!
echo.
echo ============================================================
echo   APK ready at:
echo   build\app\outputs\flutter-apk\app-release.apk
echo ============================================================
echo.
echo   Install on device:
echo   adb install build\app\outputs\flutter-apk\app-release.apk
echo.
pause
goto :end

:error
echo.
echo [ERROR] Build failed. Check output above.
pause
exit /b 1

:end
