import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Verification tests for Android Adaptive Icon Configuration (API 26+)
/// These tests verify that adaptive icon XML resources are correctly configured
/// in mipmap-anydpi-v26 directory for Android 8.0+ devices.
void main() {
  group('Adaptive Icon Configuration Verification', () {
    final String androidResPath = 'android/app/src/main/res';

    group('Adaptive Icon XML Files', () {
      test('ic_launcher.xml exists in mipmap-anydpi-v26', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        expect(file.existsSync(), isTrue,
            reason: 'ic_launcher.xml must exist for adaptive icons on Android 8.0+');
      });

      test('ic_launcher_round.xml exists in mipmap-anydpi-v26', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher_round.xml');
        expect(file.existsSync(), isTrue,
            reason: 'ic_launcher_round.xml must exist for round adaptive icons');
      });

      test('ic_launcher.xml has correct adaptive-icon structure', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();

        expect(content.contains('<adaptive-icon'), isTrue,
            reason: 'Must have adaptive-icon root element');
        expect(content.contains('xmlns:android="http://schemas.android.com/apk/res/android"'), isTrue,
            reason: 'Must have Android namespace');
        expect(content.contains('<background'), isTrue,
            reason: 'Must have background element');
        expect(content.contains('<foreground'), isTrue,
            reason: 'Must have foreground element');
        expect(content.contains('@color/ic_launcher_background'), isTrue,
            reason: 'Background must reference ic_launcher_background color');
        expect(content.contains('@mipmap/ic_launcher_foreground'), isTrue,
            reason: 'Foreground must reference ic_launcher_foreground mipmap');
      });

      test('ic_launcher_round.xml has correct adaptive-icon structure', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher_round.xml');
        final content = file.readAsStringSync();

        expect(content.contains('<adaptive-icon'), isTrue,
            reason: 'Must have adaptive-icon root element');
        expect(content.contains('<background'), isTrue,
            reason: 'Must have background element');
        expect(content.contains('<foreground'), isTrue,
            reason: 'Must have foreground element');
        expect(content.contains('@color/ic_launcher_background'), isTrue,
            reason: 'Background must reference ic_launcher_background color');
        expect(content.contains('@mipmap/ic_launcher_foreground'), isTrue,
            reason: 'Foreground must reference ic_launcher_foreground mipmap');
      });
    });

    group('Foreground Assets at All Densities', () {
      final densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

      for (final density in densities) {
        test('ic_launcher_foreground.png exists in mipmap-$density', () {
          final file = File('$androidResPath/mipmap-$density/ic_launcher_foreground.png');
          expect(file.existsSync(), isTrue,
              reason: 'Foreground asset must exist at $density density');
        });
      }

      test('foreground assets exist at all 5 densities', () {
        int count = 0;
        for (final density in densities) {
          final file = File('$androidResPath/mipmap-$density/ic_launcher_foreground.png');
          if (file.existsSync()) count++;
        }
        expect(count, equals(5),
            reason: 'All 5 density foreground assets must be present');
      });
    });

    group('Background Resource Definition', () {
      test('ic_launcher_background.xml exists in values directory', () {
        final file = File('$androidResPath/values/ic_launcher_background.xml');
        expect(file.existsSync(), isTrue,
            reason: 'Background color resource file must exist');
      });

      test('ic_launcher_background color is properly defined', () {
        final file = File('$androidResPath/values/ic_launcher_background.xml');
        final content = file.readAsStringSync();

        expect(content.contains('<resources>'), isTrue,
            reason: 'Must have resources root element');
        expect(content.contains('<color name="ic_launcher_background"'), isTrue,
            reason: 'Must define ic_launcher_background color');
        expect(RegExp(r'#[0-9A-Fa-f]{6}').hasMatch(content), isTrue,
            reason: 'Must contain a valid hex color value');
      });

      test('colors.xml also defines ic_launcher_background for redundancy', () {
        final file = File('$androidResPath/values/colors.xml');
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          expect(content.contains('ic_launcher_background'), isTrue,
              reason: 'colors.xml should also define ic_launcher_background');
        }
      });
    });

    group('Standard Launcher Icons at All Densities', () {
      final densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

      for (final density in densities) {
        test('ic_launcher.png exists in mipmap-$density', () {
          final file = File('$androidResPath/mipmap-$density/ic_launcher.png');
          expect(file.existsSync(), isTrue,
              reason: 'Standard launcher icon must exist at $density density');
        });

        test('ic_launcher_round.png exists in mipmap-$density', () {
          final file = File('$androidResPath/mipmap-$density/ic_launcher_round.png');
          expect(file.existsSync(), isTrue,
              reason: 'Round launcher icon must exist at $density density');
        });
      }
    });

    group('AndroidManifest Icon References', () {
      test('AndroidManifest.xml references correct icon resources', () {
        final file = File('android/app/src/main/AndroidManifest.xml');
        final content = file.readAsStringSync();

        expect(content.contains('android:icon="@mipmap/ic_launcher"'), isTrue,
            reason: 'Must reference ic_launcher for standard icon');
        expect(content.contains('android:roundIcon="@mipmap/ic_launcher_round"'), isTrue,
            reason: 'Must reference ic_launcher_round for round icon');
      });
    });
  });
}
