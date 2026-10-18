import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../models/dating_profile.dart';
import '../../widgets/klik_brand.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key, required this.incomingLikes});

  final List<DatingProfile> incomingLikes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Row(
            children: [
              Expanded(
                child: KliKBrand(
                  logoSize: 30,
                  alignment: Alignment.centerLeft,
                  color: colors.primary,
                  showTagline: false,
                ),
              ),
              IconButton(
                key: const Key('likes-filter'),
                tooltip: 'Filter Likes',
                onPressed: () => _showDemoInfo(context),
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                key: const Key('likes-notifications'),
                tooltip: 'Notifikasi Likes',
                onPressed: () => _showDemoInfo(context),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Likes',
            key: const Key('likes-heading'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Orang yang tertarik denganmu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            key: const Key('incoming-likes-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: incomingLikes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 196,
            ),
            itemBuilder: (context, index) => _IncomingLikeTile(
              profile: incomingLikes[index],
              index: index,
              onTap: () => _showDemoInfo(context),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton(
              key: const Key('likes-unlock'),
              onPressed: () => _showDemoInfo(context),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Lihat siapa yang menyukaimu'),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _showDemoInfo(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              key: const Key('likes-info-sheet'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Likes demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Fitur ini hanya demo.'),
                const Text('Belum ada pembayaran atau langganan.'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('likes-info-close'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _IncomingLikeTile extends StatelessWidget {
  const _IncomingLikeTile({
    required this.profile,
    required this.index,
    required this.onTap,
  });

  final DatingProfile profile;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Image.network(
              profile.imageUrl,
              fit: BoxFit.cover,
              semanticLabel:
                  'Foto tersembunyi, ${profile.age} tahun, ${profile.distanceKm.round()} kilometer',
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: colors.secondary,
                child: Icon(Icons.person, size: 64, color: colors.primary),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          Center(
            child: IconButton.filledTonal(
              key: Key('incoming-like-lock-$index'),
              tooltip: 'Buka informasi Likes',
              onPressed: onTap,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.primary,
                minimumSize: const Size.square(52),
              ),
              icon: const Icon(Icons.lock_rounded),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 11,
            child: Text(
              '${profile.age} · ${profile.distanceKm.round()} km',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
