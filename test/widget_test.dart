import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';

void main() {
  testWidgets('Discover shell shows reference brand and persistent tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('KLiK'), findsOneWidget);
    expect(find.text('Temukan koneksi yang sefrekuensi'), findsOneWidget);
    expect(find.byKey(const Key('klik-brand-heart')), findsOneWidget);
    expect(find.text('Temukan'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Alya, 26'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Discover layout fits a 390x844 viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KliKApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
