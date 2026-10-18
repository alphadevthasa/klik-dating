import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';
import 'package:klik/features/match/match_screen.dart';
import 'package:lottie/lottie.dart';

const _navy = Color(0xFF202B3D);
const _matchCopy = 'Mulai obrolan dan kenali satu sama lain lebih dekat.';

void main() {
  testWidgets('liking Nadia shows match and opens her Chat conversation', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();

    expect(find.text('KLiK'), findsOneWidget);
    expect(find.text('Temukan koneksi yang klik'), findsOneWidget);
    expect(tester.widget<Text>(find.text('KLiK')).style?.color, _navy);
    expect(
      tester.widget<Icon>(find.byKey(const Key('klik-brand-heart'))).color,
      _navy,
    );
    expect(
      tester.getRect(find.text('Temukan koneksi yang klik')).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const Key('match-animation'))).top,
      ),
    );
    expect(find.text('Kalian cocok!'), findsOneWidget);
    expect(find.text(_matchCopy), findsOneWidget);
    expect(find.byKey(const Key('match-animation')), findsOneWidget);
    final matchLottie = tester.widget<LottieBuilder>(
      find.byKey(const Key('match-lottie')),
    );
    expect(matchLottie.repeat, isFalse);
    expect(find.text('Kirim pesan'), findsOneWidget);
    expect(find.text('Lanjut lihat profil lain'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final alyaPhoto = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Foto Alya',
    );
    final nadiaPhoto = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Foto Nadia',
    );
    expect(alyaPhoto, findsOneWidget);
    expect(nadiaPhoto, findsOneWidget);
    expect(
      tester.getRect(alyaPhoto).overlaps(tester.getRect(nadiaPhoto)),
      isTrue,
    );

    final matchScaffold = tester.widget<Scaffold>(
      find
          .ancestor(
            of: find.byType(MatchScreen),
            matching: find.byType(Scaffold),
          )
          .first,
    );
    expect(matchScaffold.backgroundColor, const Color(0xFFF6E4E5));

    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    expect(appState.likedProfileIds, contains('profile-1'));

    await tester.tap(find.text('Kirim pesan'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat-composer')), findsOneWidget);
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('Wah, kapan-kapan ngopi bareng yuk!'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('reduced motion keeps match copy and both actions available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MatchScreen(
            profile: mockProfiles.first,
            currentProfile: mockCurrentProfile,
            onSendMessage: () {},
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Kalian cocok!'), findsOneWidget);
    expect(find.text(_matchCopy), findsOneWidget);
    expect(find.text('Kirim pesan'), findsOneWidget);
    expect(find.text('Lanjut lihat profil lain'), findsOneWidget);
    expect(find.byKey(const Key('match-static-heart')), findsOneWidget);
    expect(find.byKey(const Key('match-lottie')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.semanticLabel == 'Foto Alya',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.semanticLabel == 'Foto Nadia',
      ),
      findsOneWidget,
    );
  });

  testWidgets('landscape match layout keeps photos clear of visible actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchScreen(
            profile: mockProfiles.first,
            currentProfile: mockCurrentProfile,
            onSendMessage: () {},
            onContinue: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final alyaPhoto = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Foto Alya',
    );
    final nadiaPhoto = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Foto Nadia',
    );
    final titleTop = tester.getTopLeft(find.text('Kalian cocok!')).dy;
    expect(tester.getRect(alyaPhoto).bottom, lessThanOrEqualTo(titleTop));
    expect(tester.getRect(nadiaPhoto).bottom, lessThanOrEqualTo(titleTop));

    for (final label in ['Kirim pesan', 'Lanjut lihat profil lain']) {
      final action = find.text(label);
      await tester.ensureVisible(action);
      expect(action, findsOneWidget);
      expect(tester.getRect(action).top, greaterThanOrEqualTo(0));
      expect(
        tester.getRect(action).bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );
    }
  });

  testWidgets('continue returns to Discover after a mutual match', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut lihat profil lain'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('match-animation')), findsNothing);
    expect(find.text('Nabila, 25'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
