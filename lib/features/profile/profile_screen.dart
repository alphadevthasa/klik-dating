import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dating_profile.dart';
import '../../widgets/klik_brand.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.onSelectPhoto,
  });

  final DatingProfile profile;
  final ValueChanged<DatingProfile> onSaveProfile;
  final ValueChanged<String> onSelectPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  key: const Key('profile-filter'),
                  tooltip: 'Filter profil',
                  onPressed: () =>
                      _showMessage(context, 'Filter profil belum tersedia.'),
                  icon: const Icon(Icons.tune),
                ),
                IconButton(
                  key: const Key('profile-notifications'),
                  tooltip: 'Notifikasi profil',
                  onPressed: () =>
                      _showMessage(context, 'Belum ada notifikasi baru.'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: SizedBox.square(
                dimension: 188,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary, width: 3),
                      ),
                      child: ClipOval(
                        key: const Key('profile-photo-clip'),
                        child: Image.network(
                          profile.imageUrl,
                          key: const Key('profile-photo-image'),
                          width: 178,
                          height: 178,
                          fit: BoxFit.cover,
                          semanticLabel: 'Foto profil ${profile.name}',
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: colors.secondary,
                                child: Center(
                                  child: Text(
                                    profile.name.substring(0, 1),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: IconButton.filled(
                        tooltip: 'Ubah foto profil',
                        onPressed: () => _choosePhoto(context),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          minimumSize: const Size.square(48),
                          shape: const CircleBorder(
                            side: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.verified_rounded,
                  key: const Key('profile-verified-badge'),
                  color: colors.primary,
                  size: 19,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: colors.primary,
                ),
                const SizedBox(width: 3),
                Text(profile.city),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.bio,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.82),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Minat',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              children: [
                for (final interest in profile.interests)
                  Chip(label: Text(interest)),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              key: const Key('profile-completion'),
              elevation: 0,
              color: colors.secondary.withValues(alpha: 0.75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kelengkapan profil',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '80%',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(value: 0.8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const Key('profile-edit'),
                onPressed: () => _editProfile(context),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Edit profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final updatedProfile = await showModalBottomSheet<DatingProfile>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditProfileSheet(profile: profile),
    );
    if (updatedProfile != null) onSaveProfile(updatedProfile);
  }

  Future<void> _choosePhoto(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Pilih foto demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: mockProfiles.length,
                  itemBuilder: (context, index) {
                    final option = mockProfiles[index];
                    return ListTile(
                      leading: ClipOval(
                        child: Image.network(
                          option.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          semanticLabel: 'Foto ${option.name}',
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: Theme.of(context).colorScheme.secondary,
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.person_outline),
                                ),
                              ),
                        ),
                      ),
                      title: Text('${option.name}, ${option.age}'),
                      onTap: () {
                        Navigator.pop(context);
                        onSelectPhoto(option.imageUrl);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final DatingProfile profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _age = TextEditingController(text: widget.profile.age.toString());
  late final _city = TextEditingController(text: widget.profile.city);
  late final _bio = TextEditingController(text: widget.profile.bio);
  late final _interests = TextEditingController(
    text: widget.profile.interests.join(', '),
  );

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _city.dispose();
    _bio.dispose();
    _interests.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final interests = _interests.text
        .split(',')
        .map((interest) => interest.trim())
        .where((interest) => interest.isNotEmpty)
        .toList();
    Navigator.pop(
      context,
      widget.profile.copyWith(
        name: _name.text.trim(),
        age: int.parse(_age.text),
        city: _city.text.trim(),
        bio: _bio.text.trim(),
        interests: interests,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit profil',
                key: const Key('profile-edit-title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('profile-edit-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama harus diisi'
                    : null,
              ),
              TextFormField(
                key: const Key('profile-edit-age'),
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Usia'),
                validator: (value) {
                  final age = int.tryParse(value ?? '');
                  return age == null || age < 18 || age > 100
                      ? 'Usia harus 18–100 tahun'
                      : null;
                },
              ),
              TextFormField(
                key: const Key('profile-edit-city'),
                controller: _city,
                decoration: const InputDecoration(labelText: 'Kota'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Kota harus diisi'
                    : null,
              ),
              TextFormField(
                key: const Key('profile-edit-bio'),
                controller: _bio,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Tentang saya'),
              ),
              TextFormField(
                key: const Key('profile-edit-interests'),
                controller: _interests,
                decoration: const InputDecoration(
                  labelText: 'Minat (pisahkan dengan koma)',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                key: const Key('profile-edit-save'),
                onPressed: _save,
                child: const Text('Simpan perubahan'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
