import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'models/chat_message.dart';
import 'models/dating_profile.dart';
import 'features/chat/chat_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/likes/likes_screen.dart';
import 'features/match/match_screen.dart';
import 'features/profile/profile_screen.dart';

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
  final Set<String> likedProfileIds = {};
  DatingProfile currentProfile = mockCurrentProfile;
  ProfileFilter profileFilter = const ProfileFilter(
    ageRange: RangeValues(18, 40),
    maxDistanceKm: 50,
  );
  String? selectedConversationId;
  final Map<String, List<ChatMessage>> messagesByProfile = {
    for (final entry in mockMessagesByProfile.entries)
      entry.key: List.of(entry.value),
  };

  @override
  Widget build(BuildContext context) {
    final discoverProfiles = mockProfiles
        .where(
          (profile) =>
              profile.age >= profileFilter.ageRange.start &&
              profile.age <= profileFilter.ageRange.end &&
              profile.distanceKm <= profileFilter.maxDistanceKm,
        )
        .toList();
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
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: _blush,
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: Builder(
        builder: (navigatorContext) => Scaffold(
          body: IndexedStack(
            index: activeTabIndex,
            children: [
              DiscoverScreen(
                profiles: discoverProfiles,
                onProfile: () => setState(() => activeTabIndex = 3),
                onPass: (_) {},
                onLike: (profile) => _recordLike(navigatorContext, profile),
                onSuperLike: (profile) =>
                    _recordLike(navigatorContext, profile),
                onFilter: (filter) => setState(() => profileFilter = filter),
              ),
              LikesScreen(incomingLikes: mockIncomingLikes),
              ChatScreen(
                profiles: mockProfiles,
                conversationId: selectedConversationId,
                messagesByProfile: messagesByProfile,
                onOpenConversation: _openConversation,
                onBack: () => setState(() => selectedConversationId = null),
                onSendMessage: _sendMessage,
              ),
              ProfileScreen(
                profile: currentProfile,
                onSaveProfile: _saveCurrentProfile,
                onSelectPhoto: _selectCurrentProfilePhoto,
              ),
            ],
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
                label: 'Temukan',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Likes',
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
      ),
    );
  }

  void _recordLike(BuildContext navigatorContext, DatingProfile profile) {
    setState(() => likedProfileIds.add(profile.id));
    if (!profile.mutualMatch) return;

    Navigator.of(navigatorContext).push<void>(
      MaterialPageRoute<void>(
        builder: (routeContext) => Scaffold(
          backgroundColor: _blush,
          body: MatchScreen(
            profile: profile,
            currentProfile: currentProfile,
            onSendMessage: () {
              Navigator.of(routeContext).pop();
              _openConversation(profile.id);
            },
            onContinue: () => Navigator.of(routeContext).pop(),
          ),
        ),
      ),
    );
  }

  void _openConversation(String profileId) {
    setState(() {
      selectedConversationId = profileId;
      activeTabIndex = 2;
    });
  }

  void _saveCurrentProfile(DatingProfile profile) {
    setState(() => currentProfile = profile);
  }

  void _selectCurrentProfilePhoto(String imageUrl) {
    setState(
      () => currentProfile = currentProfile.copyWith(imageUrl: imageUrl),
    );
  }

  void _sendMessage(String profileId, String text) {
    final message = text.trim();
    if (message.isEmpty) return;

    setState(() {
      messagesByProfile
          .putIfAbsent(profileId, () => [])
          .add(ChatMessage(text: message, isMine: true, timeLabel: 'Sekarang'));
    });
  }
}
