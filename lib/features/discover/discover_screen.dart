import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/dating_profile.dart';

class ProfileFilter {
  const ProfileFilter({required this.ageRange, required this.maxDistanceKm});

  final RangeValues ageRange;
  final double maxDistanceKm;
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.profiles,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    required this.onFilter,
  });

  final List<DatingProfile> profiles;
  final ValueChanged<DatingProfile> onPass;
  final ValueChanged<DatingProfile> onLike;
  final ValueChanged<DatingProfile> onSuperLike;
  final ValueChanged<ProfileFilter> onFilter;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _profileIndex = 0;
  ProfileFilter _filter = const ProfileFilter(
    ageRange: RangeValues(18, 40),
    maxDistanceKm: 50,
  );

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.profiles, oldWidget.profiles)) {
      _profileIndex = 0;
    }
  }

  void _decide(DatingProfile profile, ValueChanged<DatingProfile> callback) {
    callback(profile);
    setState(() => _profileIndex++);
  }

  Future<void> _showFilter() async {
    final filter = await showModalBottomSheet<ProfileFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(initialFilter: _filter),
    );
    if (filter == null || !mounted) return;

    setState(() {
      _filter = filter;
      _profileIndex = 0;
    });
    widget.onFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileIndex < widget.profiles.length
        ? widget.profiles[_profileIndex]
        : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Temukan koneksi',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  key: const Key('discover-filter'),
                  tooltip: 'Atur filter',
                  onPressed: _showFilter,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: profile == null
                  ? _EmptyDiscoverState(
                      onRestart: () => setState(() => _profileIndex = 0),
                    )
                  : ProfileCard(
                      profile: profile,
                      onPass: () => _decide(profile, widget.onPass),
                      onLike: () => _decide(profile, widget.onLike),
                      onSuperLike: () => _decide(profile, widget.onSuperLike),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
  });

  final DatingProfile profile;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    var dragDistance = 0.0;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragStart: (_) => dragDistance = 0,
            onHorizontalDragUpdate: (details) =>
                dragDistance += details.delta.dx,
            onHorizontalDragEnd: (_) {
              if (dragDistance < -80) onPass();
              if (dragDistance > 80) onLike();
            },
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    profile.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const ColoredBox(
                            color: Color(0xFFF6E4E5),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: colors.secondary,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 88,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      key: const Key('profile-text-scrim'),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${profile.name}, ${profile.age}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.city} · ${profile.distanceKm} km dari kamu',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const Key('discover-pass'),
              tooltip: 'Lewati',
              onPressed: onPass,
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: 20),
            IconButton.filledTonal(
              key: const Key('discover-super-like'),
              tooltip: 'Super like',
              onPressed: onSuperLike,
              icon: const Icon(Icons.star),
            ),
            const SizedBox(width: 20),
            IconButton.filled(
              key: const Key('discover-like'),
              tooltip: 'Suka',
              onPressed: onLike,
              icon: const Icon(Icons.favorite),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyDiscoverState extends StatelessWidget {
  const _EmptyDiscoverState({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Untuk saat ini, belum ada profil baru.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRestart, child: const Text('Mulai lagi')),
        ],
      ),
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initialFilter});

  final ProfileFilter initialFilter;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _ageRange = widget.initialFilter.ageRange;
  late double _maxDistanceKm = widget.initialFilter.maxDistanceKm;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Atur preferensi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Rentang usia: ${_ageRange.start.round()}–${_ageRange.end.round()}',
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 40,
            divisions: 22,
            labels: RangeLabels(
              _ageRange.start.round().toString(),
              _ageRange.end.round().toString(),
            ),
            onChanged: (value) => setState(() => _ageRange = value),
          ),
          const SizedBox(height: 8),
          Text('Jarak maksimal: ${_maxDistanceKm.round()} km'),
          Slider(
            value: _maxDistanceKm,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_maxDistanceKm.round()} km',
            onChanged: (value) => setState(() => _maxDistanceKm = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    ProfileFilter(
                      ageRange: _ageRange,
                      maxDistanceKm: _maxDistanceKm,
                    ),
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
