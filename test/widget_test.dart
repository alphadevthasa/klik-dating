import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';

void usePhoneViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('Discover shell shows reference brand and persistent tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('KLiK'), findsOneWidget);
    expect(find.text('Temukan koneksi yang sefrekuensi'), findsOneWidget);
    expect(find.byKey(const Key('klik-brand-heart')), findsOneWidget);
    expect(find.text('Temukan'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Alya, 26'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Discover layout fits a 390x844 viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KliKApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Likes shows blurred incoming profiles in a locked two-column grid',
    (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(const KliKApp());
      await tester.tap(find.text('Likes'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('likes-heading')), findsOneWidget);
      expect(find.byTooltip('Atur filter'), findsOneWidget);
      expect(find.text('Orang yang tertarik denganmu'), findsOneWidget);
      final grid = tester.widget<GridView>(
        find.byKey(const Key('incoming-likes-grid')),
      );
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        2,
      );
      expect(find.byType(ImageFiltered), findsNWidgets(4));
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));
      expect(find.text('27 · 12 km'), findsOneWidget);
      expect(find.text('25 · 9 km'), findsOneWidget);
      expect(find.text('Lihat siapa yang menyukaimu'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('Likes lock and CTA open local information sheet', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Likes'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('incoming-like-lock-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('incoming-like-lock-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('likes-info-sheet')), findsOneWidget);
    expect(find.text('Informasi Likes'), findsOneWidget);
    expect(find.text('Halaman Likes ini hanya contoh.'), findsOneWidget);
    expect(find.text('Tidak ada pembayaran atau langganan.'), findsOneWidget);
    expect(find.text('Berlangganan'), findsNothing);

    await tester.tap(find.byKey(const Key('likes-info-close')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('likes-unlock')));
    await tester.tap(find.byKey(const Key('likes-unlock')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('likes-info-sheet')), findsOneWidget);
  });

  testWidgets(
    'Profil shows Alya profile, verification, interests, and progress',
    (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(const KliKApp());
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('KLiK'), findsOneWidget);
      expect(find.byTooltip('Filter profil'), findsOneWidget);
      expect(find.byTooltip('Notifikasi profil'), findsOneWidget);
      expect(find.byKey(const Key('profile-photo-clip')), findsOneWidget);
      expect(find.byTooltip('Ubah foto profil'), findsOneWidget);
      expect(find.text('Alya, 26'), findsOneWidget);
      expect(find.byKey(const Key('profile-verified-badge')), findsOneWidget);
      expect(find.text('Jakarta'), findsOneWidget);
      expect(
        find.text('Pencinta kopi, musik, dan cerita baru.'),
        findsOneWidget,
      );
      expect(find.text('Kopi'), findsOneWidget);
      expect(find.text('Kelengkapan profil'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.byKey(const Key('profile-edit')), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('Profil edit sheet updates current profile fields', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile-edit')));
    expect(find.byKey(const Key('profile-edit')), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-edit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-edit-title')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('profile-edit-name')), 'Maya');
    await tester.enterText(find.byKey(const Key('profile-edit-age')), '28');
    await tester.enterText(
      find.byKey(const Key('profile-edit-city')),
      'Bandung',
    );
    await tester.enterText(
      find.byKey(const Key('profile-edit-bio')),
      'Suka berlari dan membaca.',
    );
    await tester.enterText(
      find.byKey(const Key('profile-edit-interests')),
      'Lari, Membaca',
    );
    await tester.ensureVisible(find.byKey(const Key('profile-edit-save')));
    await tester.tap(find.byKey(const Key('profile-edit-save')));
    await tester.pumpAndSettle();

    expect(find.text('Maya, 28'), findsOneWidget);
    expect(find.text('Bandung'), findsOneWidget);
    expect(find.text('Suka berlari dan membaca.'), findsOneWidget);
    expect(find.text('Lari'), findsOneWidget);
    expect(find.text('Membaca'), findsOneWidget);
  });

  testWidgets('Selected demo photo reaches profile and Match screen', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const KliKApp());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Ubah foto profil'));
    expect(find.byTooltip('Ubah foto profil'), findsOneWidget);
    await tester.tap(find.byTooltip('Ubah foto profil'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih foto demo'), findsOneWidget);
    await tester.tap(find.text('Nabila, 25'));
    await tester.pumpAndSettle();

    final profilePhoto = tester.widget<Image>(
      find.byKey(const Key('profile-photo-image')),
    );
    expect(
      (profilePhoto.image as NetworkImage).url,
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
    );

    await tester.tap(find.text('Temukan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discover-like')));
    await tester.pumpAndSettle();

    final matchPhoto = tester.widget<Image>(
      find.byKey(const Key('match-current-profile-photo')),
    );
    expect(
      (matchPhoto.image as NetworkImage).url,
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
    );
    expect(find.byType(NavigationBar), findsNothing);
  });
}
