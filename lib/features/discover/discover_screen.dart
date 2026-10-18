import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';

import '../../models/dating_profile.dart';
import '../../widgets/klik_brand.dart';

class ProfileFilter {
  const ProfileFilter({required this.ageRange, required this.maxDistanceKm});

  final RangeValues ageRange;
  final double maxDistanceKm;
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.profiles,
    this.onProfile,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    required this.onFilter,
  });

  final List<DatingProfile> profiles;
  final VoidCallback? onProfile;
  final ValueChanged<DatingProfile> onPass;
  final ValueChanged<DatingProfile> onLike;
  final ValueChanged<DatingProfile> onSuperLike;
  final ValueChanged<ProfileFilter> onFilter;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController _controller = CardSwiperController();
  Timer? _likeFeedbackTimer;
  int _profileIndex = 0;
  int _stackVersion = 0;
  int _likeAnimationVersion = 0;
  bool _showLikeFeedback = false;
  ProfileFilter _filter = const ProfileFilter(
    ageRange: RangeValues(18, 40),
    maxDistanceKm: 50,
  );

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.profiles, oldWidget.profiles)) {
      _profileIndex = 0;
      _stackVersion++;
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final callback = switch (direction) {
      CardSwiperDirection.left => widget.onPass,
      CardSwiperDirection.right => widget.onLike,
      CardSwiperDirection.top => widget.onSuperLike,
      _ => null,
    };
    if (callback == null) return false;

    final profile = widget.profiles[previousIndex];
    if (direction == CardSwiperDirection.right && !profile.mutualMatch) {
      _playLikeFeedback(MediaQuery.disableAnimationsOf(context));
    }
    callback(profile);
    if (currentIndex != null) {
      setState(() => _profileIndex = currentIndex);
    }
    return true;
  }

  void _onEnd() {
    setState(() => _profileIndex = widget.profiles.length);
  }

  void _playLikeFeedback(bool reduceMotion) {
    _likeFeedbackTimer?.cancel();
    setState(() {
      _showLikeFeedback = true;
      _likeAnimationVersion++;
    });
    if (reduceMotion) {
      _likeFeedbackTimer = Timer(
        const Duration(milliseconds: 600),
        _hideLikeFeedback,
      );
    }
  }

  void _onLikeAnimationLoaded(LottieComposition composition) {
    final version = _likeAnimationVersion;
    _likeFeedbackTimer?.cancel();
    _likeFeedbackTimer = Timer(composition.duration, () {
      if (!mounted || version != _likeAnimationVersion) return;
      _hideLikeFeedback();
    });
  }

  void _hideLikeFeedback() {
    _likeFeedbackTimer?.cancel();
    if (mounted && _showLikeFeedback) {
      setState(() => _showLikeFeedback = false);
    }
  }

  void _restart() {
    const defaultFilter = ProfileFilter(
      ageRange: RangeValues(18, 40),
      maxDistanceKm: 50,
    );
    setState(() {
      _filter = defaultFilter;
      _profileIndex = 0;
      _stackVersion++;
    });
    widget.onFilter(defaultFilter);
  }

  @override
  void dispose() {
    _likeFeedbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
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
      _stackVersion++;
    });
    widget.onFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileIndex < widget.profiles.length
        ? widget.profiles[_profileIndex]
        : null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const KliKBrand(logoSize: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      key: const Key('discover-profile'),
                      tooltip: 'Buka profil',
                      onPressed: widget.onProfile,
                      icon: const Icon(Icons.person_outline),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: const Key('discover-filter'),
                      tooltip: 'Atur filter',
                      onPressed: _showFilter,
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (profile == null)
                    _EmptyDiscoverState(onRestart: _restart)
                  else
                    CardSwiper(
                      key: ValueKey(_stackVersion),
                      controller: _controller,
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 240),
                      cardsCount: widget.profiles.length,
                      initialIndex: _profileIndex,
                      numberOfCardsDisplayed: 1,
                      isLoop: false,
                      allowedSwipeDirection: const AllowedSwipeDirection.only(
                        left: true,
                        right: true,
                        up: true,
                      ),
                      onSwipe: _onSwipe,
                      onEnd: _onEnd,
                      cardBuilder: (context, index, horizontal, vertical) =>
                          ProfileCard(
                            profile: widget.profiles[index],
                            profileNumber: index + 1,
                            profileCount: widget.profiles.length,
                            onPass: () =>
                                _controller.swipe(CardSwiperDirection.left),
                            onLike: () =>
                                _controller.swipe(CardSwiperDirection.right),
                            onSuperLike: () =>
                                _controller.swipe(CardSwiperDirection.top),
                          ),
                    ),
                  if (_showLikeFeedback)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          key: const Key('like-feedback'),
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: reduceMotion
                                ? Icon(
                                    Icons.favorite,
                                    key: const Key('like-static-feedback'),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 104,
                                  )
                                : KeyedSubtree(
                                    key: ValueKey(_likeAnimationVersion),
                                    child: Lottie.asset(
                                      'assets/animations/like_burst.json',
                                      key: const Key('like-animation'),
                                      repeat: false,
                                      onLoaded: _onLikeAnimationLoaded,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
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
    required this.profileNumber,
    required this.profileCount,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
  });

  final DatingProfile profile;
  final int profileNumber;
  final int profileCount;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  profile.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto ${profile.name}',
                  loadingBuilder: (context, child, progress) => progress == null
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
                      stops: [0.38, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: DecoratedBox(
                    key: const Key('discover-profile-count'),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        '$profileNumber / $profileCount',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${profile.name}, ${profile.age}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.verified,
                                key: const Key('profile-verified-badge'),
                                color: colors.primary,
                                size: 19,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.city,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                ' · ${profile.distanceKm.round()} km dari kamu',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: [
                              for (final interest in profile.interests)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    child: Text(
                                      interest,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const Key('discover-pass'),
              tooltip: 'Lewati',
              onPressed: onPass,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(64),
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close_rounded, size: 28),
            ),
            const SizedBox(width: 20),
            IconButton.filledTonal(
              key: const Key('discover-super-like'),
              tooltip: 'Super like',
              onPressed: onSuperLike,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(64),
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.star_rounded, size: 28),
            ),
            const SizedBox(width: 20),
            IconButton.filled(
              key: const Key('discover-like'),
              tooltip: 'Suka',
              onPressed: onLike,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(72),
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.favorite_rounded, size: 30),
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
