import 'package:flutter/material.dart';

class KliKBrand extends StatelessWidget {
  const KliKBrand({
    super.key,
    this.logoSize = 34,
    this.alignment = Alignment.center,
    this.color,
    this.showTagline = true,
  });

  final double logoSize;
  final AlignmentGeometry alignment;
  final Color? color;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = color ?? colors.primary;
    final resolvedAlignment = alignment.resolve(Directionality.of(context));

    return Align(
      alignment: resolvedAlignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: resolvedAlignment.x < 0
            ? CrossAxisAlignment.start
            : resolvedAlignment.x > 0
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'KLiK',
                style: TextStyle(
                  color: brandColor,
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
                color: brandColor,
                size: logoSize * 0.38,
              ),
            ],
          ),
          if (showTagline) ...[
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
        ],
      ),
    );
  }
}
