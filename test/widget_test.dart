import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ats_ppb_4342501055/main.dart';
import 'package:ats_ppb_4342501055/screens/configure_route_screen.dart';
import 'package:ats_ppb_4342501055/theme/router_theme.dart';

void main() {
  testWidgets('9Router Mobile UI Kit navigation smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    // 1. Splash Screen
    expect(find.text('AI Router'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // 2. Gateway Login Screen
    expect(find.text('LOGIN'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    // 3. Dashboard Screen
    expect(find.text('TOKENS USED'), findsOneWidget);
    expect(find.text('Active APIs'), findsOneWidget);

    // 4. Connected AI APIs List
    await tester.tap(find.text('Routers'));
    await tester.pumpAndSettle();
    expect(find.text('OpenAI Primary'), findsOneWidget);

    // 5. API Detail Screen (check Edit & Delete actions)
    await tester.tap(find.text('OpenAI Primary'));
    await tester.pumpAndSettle();
    expect(find.text('Token Utilization'), findsOneWidget);
    expect(find.text('Execution Trace'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);

    // Edit Route via AppBar icon
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit AI Route'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'OpenAI Updated');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update Route'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('OpenAI Updated'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('OpenAI Updated'), findsOneWidget);

    // Delete Route
    await tester.tap(find.text('OpenAI Updated'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Hapus Rute?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('OpenAI Updated'), findsNothing);

    // Dismiss delete confirmation SnackBar before tapping FAB
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    // 6. Configure AI Route Form
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Configure AI Route'), findsOneWidget);
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save Route');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Google Gemini 2.5 Pro'), findsOneWidget);
  });

  testWidgets('ConfigureRouteScreen shows dynamic validation & network errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildRouterTheme(),
        home: const ConfigureRouteScreen(),
      ),
    );

    // Clear Provider Name & set invalid URL
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '');
    await tester.enterText(fields.at(2), 'not-a-url');
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save Route');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(find.text('Provider Name wajib diisi'), findsOneWidget);
    expect(
      find.text('Format URL tidak valid (contoh: https://api.openai.com/v1)'),
      findsOneWidget,
    );
    expect(find.textContaining('Validasi Form Gagal'), findsNothing);

    // Fix fields, but simulate unreachable/offline host
    await tester.enterText(fields.at(0), 'Offline Test');
    await tester.enterText(fields.at(2), 'https://offline.example.com/v1');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Koneksi Terputus'), findsWidgets);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
