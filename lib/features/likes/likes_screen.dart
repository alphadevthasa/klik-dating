import 'package:flutter/material.dart';

import '../../models/dating_profile.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({
    super.key,
    required this.profiles,
    required this.onOpenConversation,
  });

  final List<DatingProfile> profiles;
  final ValueChanged<String> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada profil yang kamu sukai.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Like', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final profile in profiles)
            ListTile(
              leading: _ProfileAvatar(profile: profile),
              title: Text('${profile.name}, ${profile.age}'),
              subtitle: Text(profile.city),
              trailing: const Icon(Icons.chat_bubble_outline),
              onTap: () => onOpenConversation(profile.id),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.network(
      profile.imageUrl,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      semanticLabel: 'Foto ${profile.name}',
      errorBuilder: (context, error, stackTrace) =>
          CircleAvatar(child: Text(profile.name.substring(0, 1))),
    ),
  );
}
