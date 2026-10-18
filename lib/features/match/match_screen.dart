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

    return Stack(
      children: [
        const _MatchDecoration(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.18,
                      child: _MatchVisual(
                        profile: profile,
                        reduceMotion: reduceMotion,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Kalian cocok!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai obrolan dan kenali satu sama lain lebih dekat.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: onSendMessage,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Kirim pesan'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: onContinue,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.72),
                      foregroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Lanjut lihat profil lain'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchVisual extends StatelessWidget {
  const _MatchVisual({required this.profile, required this.reduceMotion});

  final DatingProfile profile;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final coral = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final photoSize = (constraints.maxWidth * 0.43).clamp(0.0, 136.0);
        final overlap = photoSize * 0.18;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(overlap, 0),
                  child: _ProfilePhoto(
                    profile: mockCurrentProfile,
                    size: photoSize,
                  ),
                ),
                Transform.translate(
                  offset: Offset(-overlap, 0),
                  child: _ProfilePhoto(profile: profile, size: photoSize),
                ),
              ],
            ),
            SizedBox(
              key: const Key('match-animation'),
              width: 92,
              height: 92,
              child: reduceMotion
                  ? Icon(
                      Icons.favorite_rounded,
                      key: const Key('match-static-heart'),
                      color: coral,
                      size: 58,
                    )
                  : Lottie.asset(
                      'assets/animations/match.json',
                      key: const Key('match-lottie'),
                      repeat: false,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MatchDecoration extends StatelessWidget {
  const _MatchDecoration();

  @override
  Widget build(BuildContext context) {
    final coral = Theme.of(context).colorScheme.primary.withValues(alpha: 0.22);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 82,
            left: 24,
            child: Transform.rotate(
              angle: -0.28,
              child: Icon(Icons.favorite_rounded, size: 27, color: coral),
            ),
          ),
          Positioned(
            top: 128,
            right: 30,
            child: Icon(Icons.wb_sunny_outlined, size: 36, color: coral),
          ),
          Positioned(
            bottom: 188,
            left: 35,
            child: Icon(Icons.wb_sunny_outlined, size: 25, color: coral),
          ),
          Positioned(
            bottom: 188,
            right: 24,
            child: Transform.rotate(
              angle: 0.24,
              child: Icon(
                Icons.favorite_border_rounded,
                size: 31,
                color: coral,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.profile, required this.size});

  final DatingProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
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
      ),
    ),
  );
}
