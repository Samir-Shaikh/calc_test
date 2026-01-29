#!/bin/bash
# Verification Script: App Name 'SampleCalc' Configuration
# =========================================================
# This script verifies that the app name is correctly configured
# in strings.xml and AndroidManifest.xml

set -e

echo "=== Verifying App Name Configuration ==="
echo ""

# Define expected values
EXPECTED_APP_NAME="SampleCalc"
STRINGS_XML="android/app/src/main/res/values/strings.xml"
MANIFEST_XML="android/app/src/main/AndroidManifest.xml"

# Check strings.xml
echo "1. Checking strings.xml..."
if grep -q "<string name=\"app_name\">$EXPECTED_APP_NAME</string>" "$STRINGS_XML"; then
    echo "   ✅ app_name is correctly set to '$EXPECTED_APP_NAME' in strings.xml"
else
    echo "   ❌ ERROR: app_name is NOT set to '$EXPECTED_APP_NAME' in strings.xml"
    exit 1
fi

# Check AndroidManifest.xml label reference
echo ""
echo "2. Checking AndroidManifest.xml label..."
if grep -q 'android:label="@string/app_name"' "$MANIFEST_XML"; then
    echo "   ✅ android:label correctly references @string/app_name"
else
    echo "   ❌ ERROR: android:label does not reference @string/app_name"
    exit 1
fi

# Check AndroidManifest.xml icon reference
echo ""
echo "3. Checking AndroidManifest.xml icon references..."
if grep -q 'android:icon="@mipmap/ic_launcher"' "$MANIFEST_XML"; then
    echo "   ✅ android:icon correctly references @mipmap/ic_launcher"
else
    echo "   ❌ ERROR: android:icon does not reference @mipmap/ic_launcher"
    exit 1
fi

if grep -q 'android:roundIcon="@mipmap/ic_launcher_round"' "$MANIFEST_XML"; then
    echo "   ✅ android:roundIcon correctly references @mipmap/ic_launcher_round"
else
    echo "   ❌ ERROR: android:roundIcon does not reference @mipmap/ic_launcher_round"
    exit 1
fi

# Build verification (optional - requires Flutter SDK)
echo ""
echo "4. Build and APK verification (requires Flutter SDK and Android SDK)..."
if command -v flutter &> /dev/null && [ -n "$ANDROID_HOME" ]; then
    echo "   Building debug APK..."
    flutter build apk --debug
    
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    if [ -f "$APK_PATH" ]; then
        echo "   Checking APK application label..."
        APP_LABEL=$(aapt dump badging "$APK_PATH" | grep 'application-label:' | head -1)
        if echo "$APP_LABEL" | grep -q "$EXPECTED_APP_NAME"; then
            echo "   ✅ APK application-label contains '$EXPECTED_APP_NAME'"
            echo "   $APP_LABEL"
        else
            echo "   ❌ ERROR: APK application-label does not contain '$EXPECTED_APP_NAME'"
            echo "   Found: $APP_LABEL"
            exit 1
        fi
    else
        echo "   ⚠️  APK not found at expected path"
    fi
else
    echo "   ⚠️  Skipping build verification (Flutter SDK or Android SDK not available)"
fi

echo ""
echo "=== All Static Verifications Passed ==="
echo "App name '$EXPECTED_APP_NAME' is correctly configured!"
