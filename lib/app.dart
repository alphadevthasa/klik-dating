import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'models/chat_message.dart';

class KliKApp extends StatefulWidget {
  const KliKApp({super.key});

  @override
  State<KliKApp> createState() => _KliKAppState();
}

class _KliKAppState extends State<KliKApp> {
  static const _coral = Color(0xFFC5485B);
  static const _blush = Color(0xFFF6E4E5);
  static const _cream = Color(0xFFFFF9F4);
  static const _navy = Color(0xFF202B3D);

  int activeTabIndex = 0;
  int currentProfileIndex = 0;
  final Set<String> likedProfileIds = {};
  String? selectedConversationId;
  final Map<String, List<ChatMessage>> messagesByProfile = {
    for (final entry in mockMessagesByProfile.entries)
      entry.key: List.of(entry.value),
  };

  static const _tabs = [
    _TabContent(
      icon: Icons.explore_outlined,
      title: 'Temukan koneksi baru',
      message: 'Cerita seru mungkin dimulai dari sini.',
    ),
    _TabContent(
      icon: Icons.favorite_border,
      title: 'Like pilihanmu',
      message: 'Profil yang kamu sukai akan muncul di sini.',
    ),
    _TabContent(
      icon: Icons.chat_bubble_outline,
      title: 'Ruang obrolanmu',
      message: 'Percakapan hangat dimulai dengan sapaan.',
    ),
    _TabContent(
      icon: Icons.person_outline,
      title: 'Kenalan lewat profilmu',
      message: 'Ceritakan sedikit tentang dirimu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _coral,
          brightness: Brightness.light,
        ).copyWith(
          primary: _coral,
          onPrimary: Colors.white,
          secondary: _blush,
          onSecondary: _navy,
          surface: _cream,
          onSurface: _navy,
        );

    return MaterialApp(
      title: 'KLiK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: _cream,
          foregroundColor: _navy,
          centerTitle: true,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: _blush,
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('KLiK')),
        body: IndexedStack(
          index: activeTabIndex,
          children: [for (final tab in _tabs) _PlaceholderTab(content: tab)],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: activeTabIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) => setState(() {
            activeTabIndex = index;
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Like',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _TabContent {
  const _TabContent({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.content});

  final _TabContent content;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            content.icon,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(content.message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
