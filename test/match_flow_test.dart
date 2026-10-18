import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';
import 'package:klik/features/match/match_screen.dart';
import 'package:lottie/lottie.dart';

const _matchCopy = 'Mulai obrolan dan kenali satu sama lain lebih dekat.';

void main() {
  testWidgets('liking Nadia shows match and opens her Chat conversation', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();

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
    expect(find.text('Mulai percakapanmu di sini.'), findsOneWidget);
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
