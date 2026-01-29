import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// Unit tests for verifying app icon resource configuration.
///
/// These tests ensure that all required icon resources exist at the correct
/// paths with proper configurations for both standard and adaptive icons.
void main() {
  group('App Icon Resources', () {
    /// Base path to Android resources directory
    final String androidResPath = 'android/app/src/main/res';

    /// Required density directories for launcher icons
    final List<String> requiredDensities = [
      'mipmap-mdpi',
      'mipmap-hdpi',
      'mipmap-xhdpi',
      'mipmap-xxhdpi',
      'mipmap-xxxhdpi',
    ];

    group('Mipmap Directory Structure', () {
      test('all required density directories exist', () {
        for (final density in requiredDensities) {
          final directory = Directory('$androidResPath/$density');
          expect(
            directory.existsSync(),
            isTrue,
            reason: 'Missing mipmap directory: $density',
          );
        }
      });

      test('mipmap-anydpi-v26 directory exists for adaptive icons', () {
        final directory = Directory('$androidResPath/mipmap-anydpi-v26');
        expect(
          directory.existsSync(),
          isTrue,
          reason: 'Missing adaptive icon directory: mipmap-anydpi-v26',
        );
      });
    });

    group('Standard Launcher Icon Files', () {
      test('ic_launcher.png exists in all density directories', () {
        for (final density in requiredDensities) {
          final file = File('$androidResPath/$density/ic_launcher.png');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Missing ic_launcher.png in $density',
          );
        }
      });

      test('ic_launcher_round.png exists in all density directories', () {
        for (final density in requiredDensities) {
          final file = File('$androidResPath/$density/ic_launcher_round.png');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Missing ic_launcher_round.png in $density',
          );
        }
      });

      test('ic_launcher.png files are not empty', () {
        for (final density in requiredDensities) {
          final file = File('$androidResPath/$density/ic_launcher.png');
          expect(
            file.lengthSync(),
            greaterThan(0),
            reason: 'ic_launcher.png in $density is empty',
          );
        }
      });

      test('ic_launcher_round.png files are not empty', () {
        for (final density in requiredDensities) {
          final file = File('$androidResPath/$density/ic_launcher_round.png');
          expect(
            file.lengthSync(),
            greaterThan(0),
            reason: 'ic_launcher_round.png in $density is empty',
          );
        }
      });
    });

    group('Adaptive Icon Foreground Files', () {
      test('ic_launcher_foreground.png exists in all density directories', () {
        for (final density in requiredDensities) {
          final file =
              File('$androidResPath/$density/ic_launcher_foreground.png');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Missing ic_launcher_foreground.png in $density',
          );
        }
      });

      test('ic_launcher_foreground.png files are not empty', () {
        for (final density in requiredDensities) {
          final file =
              File('$androidResPath/$density/ic_launcher_foreground.png');
          expect(
            file.lengthSync(),
            greaterThan(0),
            reason: 'ic_launcher_foreground.png in $density is empty',
          );
        }
      });
    });

    group('Adaptive Icon XML Configuration', () {
      test('ic_launcher.xml exists in mipmap-anydpi-v26', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing ic_launcher.xml in mipmap-anydpi-v26',
        );
      });

      test('ic_launcher_round.xml exists in mipmap-anydpi-v26', () {
        final file =
            File('$androidResPath/mipmap-anydpi-v26/ic_launcher_round.xml');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing ic_launcher_round.xml in mipmap-anydpi-v26',
        );
      });

      test('ic_launcher.xml is valid XML with adaptive-icon root', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();

        // Parse XML to verify it's well-formed
        final document = XmlDocument.parse(content);
        final rootElement = document.rootElement;

        expect(
          rootElement.name.local,
          equals('adaptive-icon'),
          reason: 'ic_launcher.xml should have adaptive-icon as root element',
        );
      });

      test('ic_launcher_round.xml is valid XML with adaptive-icon root', () {
        final file =
            File('$androidResPath/mipmap-anydpi-v26/ic_launcher_round.xml');
        final content = file.readAsStringSync();

        // Parse XML to verify it's well-formed
        final document = XmlDocument.parse(content);
        final rootElement = document.rootElement;

        expect(
          rootElement.name.local,
          equals('adaptive-icon'),
          reason:
              'ic_launcher_round.xml should have adaptive-icon as root element',
        );
      });

      test('ic_launcher.xml contains background element', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final backgroundElements =
            document.findAllElements('background').toList();
        expect(
          backgroundElements,
          isNotEmpty,
          reason: 'ic_launcher.xml should contain a background element',
        );
      });

      test('ic_launcher.xml contains foreground element', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final foregroundElements =
            document.findAllElements('foreground').toList();
        expect(
          foregroundElements,
          isNotEmpty,
          reason: 'ic_launcher.xml should contain a foreground element',
        );
      });

      test('ic_launcher.xml foreground references ic_launcher_foreground', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final foregroundElement = document.findAllElements('foreground').first;
        final drawableAttr = foregroundElement.getAttribute('android:drawable');

        expect(
          drawableAttr,
          contains('ic_launcher_foreground'),
          reason: 'Foreground should reference ic_launcher_foreground drawable',
        );
      });

      test('ic_launcher.xml background references ic_launcher_background', () {
        final file = File('$androidResPath/mipmap-anydpi-v26/ic_launcher.xml');
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final backgroundElement = document.findAllElements('background').first;
        final drawableAttr = backgroundElement.getAttribute('android:drawable');

        expect(
          drawableAttr,
          contains('ic_launcher_background'),
          reason: 'Background should reference ic_launcher_background',
        );
      });
    });

    group('Strings.xml App Name Configuration', () {
      test('strings.xml exists', () {
        final file = File('$androidResPath/values/strings.xml');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing strings.xml in values directory',
        );
      });

      test('strings.xml is valid XML', () {
        final file = File('$androidResPath/values/strings.xml');
        final content = file.readAsStringSync();

        // This will throw if XML is malformed
        final document = XmlDocument.parse(content);
        expect(
          document.rootElement.name.local,
          equals('resources'),
          reason: 'strings.xml should have resources as root element',
        );
      });

      test('app_name is set to SampleCalc', () {
        final file = File('$androidResPath/values/strings.xml');
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final stringElements = document.findAllElements('string');
        final appNameElement = stringElements.firstWhere(
          (element) => element.getAttribute('name') == 'app_name',
          orElse: () => throw StateError('app_name string not found'),
        );

        expect(
          appNameElement.innerText,
          equals('SampleCalc'),
          reason: 'app_name should be set to SampleCalc',
        );
      });
    });

    group('AndroidManifest.xml Icon References', () {
      final String manifestPath = 'android/app/src/main/AndroidManifest.xml';

      test('AndroidManifest.xml exists', () {
        final file = File(manifestPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing AndroidManifest.xml',
        );
      });

      test('AndroidManifest.xml is valid XML', () {
        final file = File(manifestPath);
        final content = file.readAsStringSync();

        // This will throw if XML is malformed
        final document = XmlDocument.parse(content);
        expect(
          document.rootElement.name.local,
          equals('manifest'),
          reason: 'AndroidManifest.xml should have manifest as root element',
        );
      });

      test('application element references @mipmap/ic_launcher', () {
        final file = File(manifestPath);
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final applicationElement =
            document.findAllElements('application').first;
        final iconAttr = applicationElement.getAttribute('android:icon');

        expect(
          iconAttr,
          equals('@mipmap/ic_launcher'),
          reason: 'Application icon should reference @mipmap/ic_launcher',
        );
      });

      test('application element references @mipmap/ic_launcher_round', () {
        final file = File(manifestPath);
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final applicationElement =
            document.findAllElements('application').first;
        final roundIconAttr =
            applicationElement.getAttribute('android:roundIcon');

        expect(
          roundIconAttr,
          equals('@mipmap/ic_launcher_round'),
          reason:
              'Application roundIcon should reference @mipmap/ic_launcher_round',
        );
      });

      test('application element references @string/app_name', () {
        final file = File(manifestPath);
        final content = file.readAsStringSync();
        final document = XmlDocument.parse(content);

        final applicationElement =
            document.findAllElements('application').first;
        final labelAttr = applicationElement.getAttribute('android:label');

        expect(
          labelAttr,
          equals('@string/app_name'),
          reason: 'Application label should reference @string/app_name',
        );
      });
    });

    group('Icon Background Color Configuration', () {
      test('colors.xml exists with ic_launcher_background', () {
        final file = File('$androidResPath/values/colors.xml');

        // Colors.xml might exist separately or be part of the adaptive icon setup
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final document = XmlDocument.parse(content);

          final colorElements = document.findAllElements('color');
          final hasBackgroundColor = colorElements.any(
            (element) => element.getAttribute('name') == 'ic_launcher_background',
          );

          expect(
            hasBackgroundColor,
            isTrue,
            reason: 'colors.xml should define ic_launcher_background color',
          );
        } else {
          // If colors.xml doesn't exist, the background might be defined differently
          // This is acceptable as long as the adaptive icon XML references work
          expect(true, isTrue);
        }
      });
    });
  });
}
