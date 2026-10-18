import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';
import 'package:klik/features/discover/discover_screen.dart';
import 'package:klik/models/dating_profile.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('first profile matches reference content and card controls', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('Nadia, 27'), findsOneWidget);
    expect(find.textContaining('Bandung'), findsOneWidget);
    expect(find.byKey(const Key('discover-profile-count')), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.byKey(const Key('profile-verified-badge')), findsOneWidget);
    for (final interest in ['Coffee', 'Books', 'Travel', 'Sunset']) {
      expect(find.text(interest), findsOneWidget);
    }
    for (final key in [
      'discover-pass',
      'discover-super-like',
      'discover-like',
    ]) {
      expect(
        tester.getSize(find.byKey(Key(key))).width,
        greaterThanOrEqualTo(60),
      );
    }
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('reduced motion removes CardSwiper swipe animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: DiscoverScreen(
              profiles: mockProfiles,
              onPass: (_) {},
              onLike: (_) {},
              onSuperLike: (_) {},
              onFilter: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<CardSwiper>(find.byType(CardSwiper)).duration,
      Duration.zero,
    );
  });

  testWidgets('non-match right swipe plays the local like burst', (
    tester,
  ) async {
    await _pumpDiscover(
      tester,
      profiles: mockProfiles.skip(1).toList(),
      onPass: (_) {},
      onLike: (_) {},
      onSuperLike: (_) {},
    );

    await tester.drag(find.text('Nabila, 25'), const Offset(300, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byKey(const Key('like-feedback')), findsOneWidget);
    final animation = find.byKey(const Key('like-animation'));
    expect(animation, findsOneWidget);
    expect(tester.widget(animation), isA<LottieBuilder>());
  });

  testWidgets('reduced motion shows static heart instead of Lottie', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: DiscoverScreen(
              profiles: [mockProfiles[1]],
              onPass: (_) {},
              onLike: (_) {},
              onSuperLike: (_) {},
              onFilter: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pump();

    expect(find.byKey(const Key('like-static-feedback')), findsOneWidget);
    expect(find.byKey(const Key('like-animation')), findsNothing);
  });

  testWidgets('pass button advances to the next profile', (tester) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.byType(CardSwiper), findsOneWidget);
    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.byKey(const Key('discover-pass')));
    await tester.pumpAndSettle();

    expect(find.text('Nabila, 25'), findsOneWidget);
  });

  testWidgets('swiping right records a like and advances', (tester) async {
    await tester.pumpWidget(const KliKApp());

    await tester.tap(find.byKey(const Key('discover-pass')));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Nabila, 25'), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Kirana, 29'), findsOneWidget);
    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    expect(appState.likedProfileIds, contains('profile-2'));
  });

  testWidgets('swiping left passes the current profile', (tester) async {
    final passedProfiles = <DatingProfile>[];
    await _pumpDiscover(
      tester,
      onPass: passedProfiles.add,
      onLike: (_) {},
      onSuperLike: (_) {},
    );

    await tester.drag(find.text('Nadia, 27'), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(passedProfiles.map((profile) => profile.id), ['profile-1']);
    expect(find.text('Nabila, 25'), findsOneWidget);
  });

  testWidgets('star button triggers a super-like swipe', (tester) async {
    final superLikedProfiles = <DatingProfile>[];
    await _pumpDiscover(
      tester,
      onPass: (_) {},
      onLike: (_) {},
      onSuperLike: superLikedProfiles.add,
    );

    await tester.tap(find.byKey(const Key('discover-super-like')));
    await tester.pumpAndSettle();

    expect(superLikedProfiles.map((profile) => profile.id), ['profile-1']);
    expect(find.text('Nabila, 25'), findsOneWidget);
  });

  testWidgets('swiping up triggers a super-like', (tester) async {
    final superLikedProfiles = <DatingProfile>[];
    await _pumpDiscover(
      tester,
      onPass: (_) {},
      onLike: (_) {},
      onSuperLike: superLikedProfiles.add,
    );

    await tester.drag(find.text('Nadia, 27'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(superLikedProfiles.map((profile) => profile.id), ['profile-1']);
    expect(find.text('Nabila, 25'), findsOneWidget);
  });

  testWidgets('profile text scrim keeps 4.5:1 contrast on bright photos', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    final titleFinder = find.text('Nadia, 27');
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

  testWidgets('profile image failure shows the fallback icon', (tester) async {
    const brokenProfile = DatingProfile(
      id: 'broken-image',
      name: 'Test',
      age: 24,
      city: 'Bandung',
      bio: 'Demo profile',
      imageUrl: 'https://invalid.example/profile.jpg',
      distanceKm: 2,
      interests: [],
      mutualMatch: false,
    );
    await _pumpDiscover(
      tester,
      profiles: const [brokenProfile],
      onPass: (_) {},
      onLike: (_) {},
      onSuperLike: (_) {},
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('filter keeps only profiles matching age and distance', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.byKey(const Key('discover-pass')));
    await tester.pumpAndSettle();
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
    expect(find.text('Nadia, 27'), findsNothing);
    expect(find.text('Nabila, 25'), findsNothing);
    expect(find.text('Kirana, 29'), findsNothing);
  });

  testWidgets('exhausted profiles can be restarted', (tester) async {
    await tester.pumpWidget(const KliKApp());

    for (var index = 0; index < mockProfiles.length; index++) {
      await tester.tap(find.byKey(const Key('discover-pass')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Untuk saat ini, belum ada profil baru.'), findsOneWidget);
    await tester.tap(find.text('Mulai lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Nadia, 27'), findsOneWidget);
  });

  testWidgets('restart clears filters and restores all profiles', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.byKey(const Key('discover-filter')));
    await tester.pumpAndSettle();
    await _dragSliderThumb(
      tester,
      find.byType(RangeSlider),
      from: 40,
      to: 18,
      min: 18,
      max: 40,
    );
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Untuk saat ini, belum ada profil baru.'), findsOneWidget);
    await tester.tap(find.text('Mulai lagi'));
    await tester.pumpAndSettle();

    final names = [
      'Nadia, 27',
      'Nabila, 25',
      'Kirana, 29',
      'Alya, 27',
      'Dinda, 32',
    ];
    for (var index = 0; index < names.length; index++) {
      expect(find.text(names[index]), findsOneWidget);
      if (index < names.length - 1) {
        await tester.tap(find.byKey(const Key('discover-pass')));
        await tester.pumpAndSettle();
      }
    }
  });
}

Future<void> _pumpDiscover(
  WidgetTester tester, {
  List<DatingProfile> profiles = mockProfiles,
  required ValueChanged<DatingProfile> onPass,
  required ValueChanged<DatingProfile> onLike,
  required ValueChanged<DatingProfile> onSuperLike,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: DiscoverScreen(
        profiles: profiles,
        onPass: onPass,
        onLike: onLike,
        onSuperLike: onSuperLike,
        onFilter: (_) {},
      ),
    ),
  ),
);

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
