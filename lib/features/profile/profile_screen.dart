import 'package:flutter/material.dart';

import '../../models/dating_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil demo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              profile.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              semanticLabel: 'Foto profil ${profile.name}',
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: double.infinity,
                height: 280,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.person,
                    size: 88,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.name}, ${profile.age}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(profile.city),
          const SizedBox(height: 12),
          Text(profile.bio),
          const SizedBox(height: 20),
          Text('Minat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in profile.interests)
                Chip(label: Text(interest)),
            ],
          ),
        ],
      ),
    ),
  );
}
