import 'package:flutter/material.dart';

class KliKBrand extends StatelessWidget {
  const KliKBrand({super.key, this.logoSize = 34});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'KLiK',
              style: TextStyle(
                color: colors.primary,
                fontSize: logoSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.favorite,
              key: const Key('klik-brand-heart'),
              color: colors.primary,
              size: logoSize * 0.38,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Temukan koneksi yang sefrekuensi',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
