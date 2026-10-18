import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';
import 'package:klik/data/mock_data.dart';
import 'package:klik/features/chat/chat_screen.dart';
import 'package:klik/models/chat_message.dart';

void main() {
  testWidgets('chat sends non-empty messages and ignores empty sends', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.text('Nadia, 27'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Kembali ke daftar chat'), findsOneWidget);
    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    final messageCount = appState.messagesByProfile['profile-1'].length as int;

    await tester.enterText(find.byKey(const Key('chat-composer')), 'Hai!');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.text('Hai!'), findsOneWidget);
    expect(appState.messagesByProfile['profile-1'].length, messageCount + 1);
    expect(appState.messagesByProfile['profile-1'].last.isMine, isTrue);

    await tester.enterText(find.byKey(const Key('chat-composer')), '   ');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(appState.messagesByProfile['profile-1'].length, messageCount + 1);
  });

  testWidgets('composer remains above the visible keyboard', (tester) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nadia, 27'));
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

  testWidgets('send auto-scroll jumps immediately with reduced motion', (
    tester,
  ) async {
    final messages = [
      for (var index = 0; index < 20; index++)
        ChatMessage(
          text: 'Older message $index',
          isMine: index.isOdd,
          timeLabel: '08:${index.toString().padLeft(2, '0')}',
        ),
      ...mockMessagesByProfile['profile-1']!,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ChatScreen(
                profiles: mockProfiles,
                conversationId: 'profile-1',
                messagesByProfile: {'profile-1': messages},
                onOpenConversation: (_) {},
                onBack: () {},
                onSendMessage: (profileId, text) => setState(
                  () => messages.add(
                    ChatMessage(
                      text: text,
                      isMine: true,
                      timeLabel: 'Sekarang',
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 2,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  label: 'Temukan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  label: 'Likes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final latest = find.text('Wah, kapan-kapan ngopi bareng yuk!');
    expect(latest, findsOneWidget);
    final latestRect = tester.getRect(latest);
    final initialListRect = tester.getRect(find.byType(ListView));
    expect(latestRect.top, greaterThanOrEqualTo(initialListRect.top));
    expect(latestRect.bottom, lessThanOrEqualTo(initialListRect.bottom));

    final scrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.text('Older message 0'), findsOneWidget);
    expect(
      MediaQuery.disableAnimationsOf(
        tester.element(find.byKey(const Key('chat-composer'))),
      ),
      isTrue,
    );

    await tester.enterText(
      find.byKey(const Key('chat-composer')),
      'Reduced-motion message',
    );
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    final sent = find.text('Reduced-motion message');
    expect(sent, findsOneWidget);
    final sentRect = tester.getRect(sent);
    final listRect = tester.getRect(find.byType(ListView));
    expect(sentRect.top, greaterThanOrEqualTo(listRect.top));
    expect(sentRect.bottom, lessThanOrEqualTo(listRect.bottom));
  });

  testWidgets('conversation back returns to list and tab navigation works', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.text('Nadia, 27'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Kembali ke daftar chat'));
    await tester.pumpAndSettle();

    expect(find.text('Percakapan'), findsOneWidget);
    expect(find.text('Nabila, 25'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Pencinta kopi, musik, dan cerita baru.'), findsOneWidget);
  });

  testWidgets('Nadia chat matches reference inside the Chat tab', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Nadia, 27'), findsOneWidget);
    await tester.tap(find.text('Nadia, 27'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    final dynamic appState = tester.state<State<StatefulWidget>>(
      find.byType(KliKApp),
    );
    expect(appState.selectedConversationId, 'profile-1');
    expect(appState.activeTabIndex, 2);
    expect(find.text('KLiK'), findsNothing);
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text(', 27'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Wah, kapan-kapan ngopi bareng yuk!'), findsOneWidget);
    expect(find.text('09:17'), findsOneWidget);
    final latestMessageRect = tester.getRect(
      find.text('Wah, kapan-kapan ngopi bareng yuk!'),
    );
    final listRect = tester.getRect(find.byType(ListView));
    expect(latestMessageRect.top, greaterThanOrEqualTo(listRect.top));
    expect(latestMessageRect.bottom, lessThanOrEqualTo(listRect.bottom));

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Hai! Senang bisa kenalan 😊'), findsOneWidget);
    expect(find.text('Hai Nadia! Aku juga senang 😊'), findsOneWidget);
    expect(find.text('09:12'), findsOneWidget);
    expect(find.text('09:13'), findsOneWidget);
    expect(find.byTooltip('Panggil Nadia'), findsOneWidget);
    expect(find.byTooltip('Opsi chat'), findsOneWidget);
    expect(find.byTooltip('Tambahkan lampiran'), findsOneWidget);
    expect(find.byTooltip('Pilih emoji'), findsOneWidget);
    expect(find.byTooltip('Kirim pesan'), findsOneWidget);
    expect(find.byIcon(Icons.done_all), findsWidgets);
    final avatar = find
        .byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Foto Nadia',
        )
        .first;
    expect(tester.getSemantics(avatar).getSemanticsData().label, 'Foto Nadia');

    await tester.tap(find.byTooltip('Tambahkan lampiran'));
    await tester.pumpAndSettle();
    expect(find.text('Kamera'), findsOneWidget);
    await tester.tap(find.text('Kamera'));
    await tester.pumpAndSettle();
    expect(find.text('Lampiran demo belum tersedia.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Pilih emoji'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('😊'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chat-composer')))
          .controller!
          .text,
      '😊',
    );

    await tester.tap(find.byTooltip('Kembali ke daftar chat'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('KLiK'), findsNothing);
    expect(find.text('Percakapan'), findsOneWidget);
    expect(find.text('Nadia, 27'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Profil shows the current Alya demo profile', (tester) async {
    expect(
      mockProfiles.map((profile) => profile.id),
      isNot(contains(mockCurrentProfile.id)),
    );
    expect(mockCurrentProfile.name, 'Alya');
    expect(mockCurrentProfile.age, 26);
    expect(mockCurrentProfile.city, 'Jakarta');

    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Alya, 26'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
  });

  testWidgets('liked profiles open a conversation and Like has empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Likes'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada profil yang kamu sukai.'), findsOneWidget);

    await tester.tap(find.text('Temukan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discover-pass')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Likes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();

    expect(find.text('Nabila'), findsOneWidget);
    expect(find.text(', 25'), findsOneWidget);
    expect(find.byTooltip('Kirim pesan'), findsOneWidget);
  });
}
