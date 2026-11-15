import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ats_ppb_4342501055/main.dart';

Future<void> _loadRealFonts() async {
  final robotoLoader = FontLoader('Roboto');
  final arialBytes = File(r'C:\Windows\Fonts\arial.ttf').readAsBytesSync();
  robotoLoader.addFont(
    Future.value(ByteData.sublistView(Uint8List.fromList(arialBytes))),
  );
  final arialBold = File(r'C:\Windows\Fonts\arialbd.ttf');
  if (arialBold.existsSync()) {
    robotoLoader.addFont(
      Future.value(
        ByteData.sublistView(Uint8List.fromList(arialBold.readAsBytesSync())),
      ),
    );
  }
  await robotoLoader.load();

  final monoLoader = FontLoader('monospace');
  final consola = File(r'C:\Windows\Fonts\consola.ttf');
  final monoBytes = consola.existsSync() ? consola.readAsBytesSync() : arialBytes;
  monoLoader.addFont(
    Future.value(ByteData.sublistView(Uint8List.fromList(monoBytes))),
  );
  await monoLoader.load();

  for (final family in ['Ahem', 'FlutterTest', 'sans-serif']) {
    final loader = FontLoader(family);
    loader.addFont(
      Future.value(ByteData.sublistView(Uint8List.fromList(arialBytes))),
    );
    if (arialBold.existsSync()) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(Uint8List.fromList(arialBold.readAsBytesSync())),
        ),
      );
    }
    await loader.load();
  }

  final iconLoader = FontLoader('MaterialIcons');
  final iconBytes = File(
    r'C:\Users\Fajri\.jdks\jbr-21.0.11\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
  ).readAsBytesSync();
  iconLoader.addFont(
    Future.value(ByteData.sublistView(Uint8List.fromList(iconBytes))),
  );
  await iconLoader.load();
}

Future<void> _saveScreenshot(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String fileName,
) async {
  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final outDir = Directory('screenshots');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }
    final file = File('${outDir.path}/$fileName');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('Capture screenshots of all screens', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(_loadRealFonts);

    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundaryKey, child: const MainApp()),
    );
    await tester.pump(const Duration(milliseconds: 800));

    // 1. Splash Screen
    await _saveScreenshot(tester, boundaryKey, '01_splash_screen.png');

    // 2. Login Screen
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '02_login_screen.png');

    // 3. Dashboard Screen
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '03_dashboard_screen.png');

    // 4. Connected AI APIs List
    await tester.tap(find.text('Routers'));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '04_connected_apis_screen.png');

    // 5. API Detail Screen
    await tester.tap(find.text('OpenAI Primary'));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '05_api_detail_screen.png');

    // Go back & open Configure AI Route
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 6. Configure AI Route Screen
    await _saveScreenshot(tester, boundaryKey, '06_configure_route_screen.png');

    // 7. Configure AI Route Validation Error State
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Route'));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '07_configure_route_error.png');

    // 8. Settings Screen
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await _saveScreenshot(tester, boundaryKey, '08_settings_screen.png');
  });
}
