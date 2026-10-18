import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';
import 'package:klik/features/match/match_screen.dart';

void main() {
  testWidgets('mutual like opens match and message opens that conversation', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    for (final profile in mockProfiles) {
      expect(find.text('${profile.name}, ${profile.age}'), findsOneWidget);
      await tester.tap(find.byKey(const Key('discover-like')));
      await tester.pumpAndSettle();

      if (!profile.mutualMatch) {
        expect(find.byKey(const Key('match-animation')), findsNothing);
      }
    }

    expect(find.text('Kamu dan Alya saling suka!'), findsOneWidget);
    expect(find.byKey(const Key('match-animation')), findsOneWidget);

    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    expect(
      appState.likedProfileIds,
      containsAll(mockProfiles.map((profile) => profile.id)),
    );

    await tester.tap(find.text('Kirim pesan'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat-composer')), findsOneWidget);
    expect(find.text('Alya'), findsOneWidget);
    expect(find.text('Hai, senang bisa kenalan!'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('reduced motion keeps match copy and both actions available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MatchScreen(
            profile: mockProfiles.last,
            onSendMessage: () {},
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Kamu dan Alya saling suka!'), findsOneWidget);
    expect(find.text('Kirim pesan'), findsOneWidget);
    expect(find.text('Lanjut lihat profil lain'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('match-animation')),
        matching: find.byType(Icon),
      ),
      findsOneWidget,
    );
  });

  testWidgets('continue returns to Discover after a mutual match', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    for (final _ in mockProfiles) {
      await tester.tap(find.byKey(const Key('discover-like')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Lanjut lihat profil lain'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('match-animation')), findsNothing);
    expect(find.text('Untuk saat ini, belum ada profil baru.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
