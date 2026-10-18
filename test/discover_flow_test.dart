import 'dart:math' as math;

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

  testWidgets('profile text scrim keeps 4.5:1 contrast on bright photos', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    final titleFinder = find.text('Salsabila, 22');
    final title = tester.widget<Text>(titleFinder);
    final foreground = title.style!.color!;
    final card = tester.getRect(
      find.ancestor(of: titleFinder, matching: find.byType(Card)),
    );
    final titlePosition =
        (tester.getRect(titleFinder).center.dy - card.top) / card.height;
    final gradient = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.gradient)
        .whereType<LinearGradient>()
        .first;
    final stops = gradient.stops!;
    final gradientPosition =
        ((titlePosition - stops.first) / (stops.last - stops.first)).clamp(
          0.0,
          1.0,
        );
    final gradientOverlay = Color.lerp(
      gradient.colors.first,
      gradient.colors.last,
      gradientPosition,
    )!;
    final gradientBackground = _composite(gradientOverlay, Colors.white);
    final scrimFinder = find.byKey(const Key('profile-text-scrim'));
    final scrim = scrimFinder.evaluate().isEmpty
        ? Colors.transparent
        : (tester.widget<DecoratedBox>(scrimFinder).decoration as BoxDecoration)
              .color!;
    final effectiveBackground = _composite(scrim, gradientBackground);

    expect(
      _contrastRatio(foreground, effectiveBackground),
      greaterThanOrEqualTo(4.5),
      reason: 'White profile copy must contrast with a worst-case white photo.',
    );
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

Color _composite(Color foreground, Color background) {
  final alpha = foreground.a;
  return Color.fromARGB(
    255,
    ((foreground.r * alpha + background.r * (1 - alpha)) * 255).round(),
    ((foreground.g * alpha + background.g * (1 - alpha)) * 255).round(),
    ((foreground.b * alpha + background.b * (1 - alpha)) * 255).round(),
  );
}

double _contrastRatio(Color first, Color second) {
  final luminances = [_luminance(first), _luminance(second)]..sort();
  return (luminances.last + 0.05) / (luminances.first + 0.05);
}

double _luminance(Color color) {
  double linearize(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}
