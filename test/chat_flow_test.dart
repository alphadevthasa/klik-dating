import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';

void main() {
  testWidgets('chat sends non-empty messages and ignores empty sends', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Nabila, 25'), findsOneWidget);
    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Kembali ke daftar chat'), findsOneWidget);
    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    final messageCount = appState.messagesByProfile['profile-2'].length as int;

    await tester.enterText(find.byKey(const Key('chat-composer')), 'Hai!');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.text('Hai!'), findsOneWidget);
    expect(appState.messagesByProfile['profile-2'].length, messageCount + 1);
    expect(appState.messagesByProfile['profile-2'].last.isMine, isTrue);

    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(appState.messagesByProfile['profile-2'].length, messageCount + 1);
  });

  testWidgets('composer remains above the visible keyboard', (tester) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.showKeyboard(find.byKey(const Key('chat-composer')));
    await tester.pumpAndSettle();

    expect(tester.view.viewInsets.bottom, 300);
    final keyboardTop =
        (tester.view.physicalSize.height - tester.view.viewInsets.bottom) /
        tester.view.devicePixelRatio;
    expect(
      tester.getRect(find.byKey(const Key('chat-composer'))).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getRect(find.byKey(const Key('chat-send'))).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
  });

  testWidgets('conversation back returns to list and tab navigation works', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Nabila, 25'), findsOneWidget);
    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Kembali ke daftar chat'));
    await tester.pumpAndSettle();

    expect(find.text('Percakapan'), findsOneWidget);
    expect(find.text('Nabila, 25'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Pencinta kopi, musik, dan cerita baru.'), findsOneWidget);
  });

  testWidgets('conversation detail hides shell and back restores it', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('KLiK'), findsNothing);

    await tester.tap(find.byTooltip('Kembali ke daftar chat'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('KLiK'), findsOneWidget);
    expect(find.text('Percakapan'), findsOneWidget);
  });

  testWidgets(
    'Profil uses a demo self-profile distinct from Discover profiles',
    (tester) async {
      expect(
        mockProfiles.map((profile) => profile.name),
        isNot(contains('Nadia')),
      );
      expect(
        mockProfiles.map((profile) => profile.id),
        isNot(contains(mockCurrentProfile.id)),
      );

      await tester.pumpWidget(const KliKApp());
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Nadia, 24'), findsOneWidget);
      expect(find.text('Salsabila, 22'), findsNothing);
    },
  );

  testWidgets('liked profiles open a conversation and Like has empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Like'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada profil yang kamu sukai.'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Like'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salsabila, 22'));
    await tester.pumpAndSettle();

    expect(find.text('Salsabila'), findsOneWidget);
    expect(find.byTooltip('Kirim pesan'), findsOneWidget);
  });
}
