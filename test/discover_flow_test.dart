import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';

void main() {
  testWidgets('pass button advances to the next profile', (tester) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('Salsabila, 22'), findsOneWidget);
    await tester.tap(find.byKey(const Key('discover-pass')));
    await tester.pumpAndSettle();

    expect(find.text('Nabila, 25'), findsOneWidget);
  });

  testWidgets('swiping right records a like and advances', (tester) async {
    await tester.pumpWidget(const KliKApp());

    await tester.drag(find.text('Salsabila, 22'), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Nabila, 25'), findsOneWidget);
    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    expect(appState.likedProfileIds, contains('profile-1'));
  });

  testWidgets('filter keeps only profiles matching age and distance', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.byKey(const Key('discover-filter')));
    await tester.pumpAndSettle();

    await _dragSliderThumb(
      tester,
      find.byType(RangeSlider),
      from: 40,
      to: 28,
      min: 18,
      max: 40,
    );
    await _dragSliderThumb(
      tester,
      find.byType(RangeSlider),
      from: 18,
      to: 26,
      min: 18,
      max: 40,
    );
    await _dragSliderThumb(
      tester,
      find.byType(Slider),
      from: 50,
      to: 10,
      min: 1,
      max: 50,
    );
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Alya, 27'), findsOneWidget);
    expect(find.text('Salsabila, 22'), findsNothing);
    expect(find.text('Nabila, 25'), findsNothing);
    expect(find.text('Kirana, 29'), findsNothing);
  });

  testWidgets('exhausted profiles can be restarted', (tester) async {
    await tester.pumpWidget(const KliKApp());

    for (var index = 0; index < 4; index++) {
      await tester.tap(find.byKey(const Key('discover-pass')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Untuk saat ini, belum ada profil baru.'), findsOneWidget);
    await tester.tap(find.text('Mulai lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Salsabila, 22'), findsOneWidget);
  });
}

Future<void> _dragSliderThumb(
  WidgetTester tester,
  Finder slider, {
  required double from,
  required double to,
  required double min,
  required double max,
}) async {
  final rect = tester.getRect(slider);
  double xFor(double value) =>
      rect.left + 12 + (rect.width - 24) * (value - min) / (max - min);

  final startX = xFor(from);

  await tester.dragFrom(
    Offset(startX, rect.center.dy),
    Offset(xFor(to) - startX, 0),
  );
  await tester.pumpAndSettle();
}
