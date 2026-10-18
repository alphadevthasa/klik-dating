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
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Like'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Raka, 28'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
