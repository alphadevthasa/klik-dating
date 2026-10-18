import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../data/mock_data.dart';
import '../../models/dating_profile.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({
    super.key,
    required this.profile,
    required this.onSendMessage,
    required this.onContinue,
  });

  final DatingProfile profile;
  final VoidCallback onSendMessage;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProfilePhoto(profile: mockCurrentProfile),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.favorite,
                            color: colors.primary,
                            size: 32,
                          ),
                        ),
                        _ProfilePhoto(profile: profile),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      key: const Key('match-animation'),
                      width: 220,
                      height: 200,
                      child: reduceMotion
                          ? Icon(
                              Icons.favorite,
                              color: colors.primary,
                              size: 112,
                            )
                          : Lottie.asset(
                              'assets/animations/match.json',
                              repeat: false,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamu dan ${profile.name} saling suka!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai obrolan seru dan kenali satu sama lain.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSendMessage,
                child: const Text('Kirim pesan'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onContinue,
                child: const Text('Lanjut lihat profil lain'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.profile});

  final DatingProfile profile;

  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 88,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    ),
    child: ClipOval(
      child: Image.network(
        profile.imageUrl,
        fit: BoxFit.cover,
        semanticLabel: 'Foto ${profile.name}',
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: Theme.of(context).colorScheme.secondary,
          child: Center(
            child: Text(
              profile.name.substring(0, 1),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    ),
  );
}
