import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOOD SPECTRUM design system.
// Identity: one signature gradient — calm blue → violet → rose → ember — that
// represents the emotional spectrum the app navigates. Surfaces are quiet
// (deep ink in dark, warm paper in light) with hairline borders; the spectrum
// is the only loud element, so it always reads as the brand.
// ─────────────────────────────────────────────────────────────────────────────
class DesignTokens {
  // Active brightness — set once per build from the resolved theme.
  static Brightness brightness = Brightness.light;
  static bool get isDark => brightness == Brightness.dark;

  static Color get background =>
      isDark ? const Color(0xff0a0a10) : const Color(0xfff6f5f2);
  static Color get backgroundDeep =>
      isDark ? const Color(0xff060609) : const Color(0xffedebe6);
  static Color get panel =>
      isDark ? const Color(0xff15151e) : const Color(0xffffffff);
  static Color get panelAlt =>
      isDark ? const Color(0xff1c1c28) : const Color(0xfffbfaf8);
  static Color get sheet =>
      isDark ? const Color(0xff101018) : const Color(0xffffffff);
  static Color get ink =>
      isDark ? const Color(0xfff2f1f6) : const Color(0xff17161c);
  static Color get sage =>
      isDark ? const Color(0xffb9b6c6) : const Color(0xff55525f);
  static Color get muted =>
      isDark ? const Color(0xff8b88a0) : const Color(0xff8b8894);
  static Color get line =>
      isDark ? const Color(0x16ffffff) : const Color(0x14000000);
  static Color get cardBorder =>
      isDark ? const Color(0x1effffff) : const Color(0x12000000);
  static Color get cream =>
      isDark ? const Color(0xff1c1c28) : const Color(0xffffffff);

  static const mint = Color(0xff36d399);
  static const peach = Color(0xffff8a56);
  static const cobalt = Color(0xff5b8cff);
  static const violet = Color(0xff8b5cf6);
  static const graphite = Color(0xff262a3d);
  static const rose = Color(0xffff5e8a);
  static const auraBlue = Color(0xff5b8cff);
  static const darkLine = Color(0x18171926);

  // Brand spectrum — the one gradient used for the dial, primary actions and
  // brand accents. Order is emotional: calm → dreamy → tender → energetic.
  static const spectrum = [
    Color(0xff5b8cff),
    Color(0xff8b5cf6),
    Color(0xffff5e8a),
    Color(0xffff8a56),
  ];

  static const spectrumGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: spectrum,
  );

  static const moodPalette = [
    Color(0xffff5e8a),
    Color(0xff5b8cff),
    Color(0xff8b5cf6),
    Color(0xffff8a56),
    Color(0xff36d399),
    Color(0xffe05ab8),
    Color(0xff7e8bb5),
    Color(0xffffc24d),
  ];

  // Quiet elevation: hairline borders carry the structure, shadows only hint.
  static List<BoxShadow> get softShadow => isDark
      ? const [
          BoxShadow(
              color: Color(0x52000000), blurRadius: 24, offset: Offset(0, 10)),
        ]
      : const [
          BoxShadow(
              color: Color(0x14201a33), blurRadius: 24, offset: Offset(0, 10)),
        ];

  static List<BoxShadow> get smallShadow => isDark
      ? const [
          BoxShadow(
              color: Color(0x3d000000), blurRadius: 12, offset: Offset(0, 4)),
        ]
      : const [
          BoxShadow(
              color: Color(0x10201a33), blurRadius: 12, offset: Offset(0, 4)),
        ];

  static List<BoxShadow> get cardShadow => isDark
      ? const [
          BoxShadow(
              color: Color(0x47000000), blurRadius: 18, offset: Offset(0, 8)),
        ]
      : const [
          BoxShadow(
              color: Color(0x12201a33), blurRadius: 18, offset: Offset(0, 8)),
        ];

  static List<BoxShadow> get glowShadow => const [
        BoxShadow(
            color: Color(0x558b5cf6), blurRadius: 24, offset: Offset(0, 10)),
        BoxShadow(
            color: Color(0x33ff5e8a), blurRadius: 28, offset: Offset(0, 4)),
      ];

  static Color moodColor(int index) => moodPalette[index % moodPalette.length];
}

BoxDecoration softPanelDecoration({Color? color, List<BoxShadow>? shadow}) {
  return BoxDecoration(
    color: color ?? DesignTokens.panel,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: DesignTokens.cardBorder),
    boxShadow: shadow ?? DesignTokens.softShadow,
  );
}

BoxDecoration auroraPanelDecoration({Color? color, List<BoxShadow>? shadow}) {
  return BoxDecoration(
    color: color ?? DesignTokens.panel,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: DesignTokens.cardBorder),
    boxShadow: shadow ?? DesignTokens.softShadow,
  );
}

class SoftBackdrop extends StatelessWidget {
  const SoftBackdrop({super.key, this.tint});

  // Optional mood accent: the lower bloom slowly takes on this colour so the
  // selected mood visibly "tints" the screen. Defaults to the brand violet,
  // which matches the original backdrop.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final dark = DesignTokens.isDark;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [
                    Color(0xff0c0c14),
                    Color(0xff0a0a10),
                    Color(0xff0b0a12),
                    Color(0xff08080d),
                  ]
                : const [
                    Color(0xfff8f7f4),
                    Color(0xfff6f5f2),
                    Color(0xfff7f5f3),
                    Color(0xfff4f3ef),
                  ],
            stops: const [0.0, 0.4, 0.72, 1.0],
          ),
        ),
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: tint ?? DesignTokens.violet),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, animatedTint, _) => CustomPaint(
            painter: _AuroraBackdropPainter(
              dark: dark,
              tint: animatedTint ?? DesignTokens.violet,
            ),
          ),
        ),
      ),
    );
  }
}

// Dreamy "aurora" blooms (lavender / pink / sky-blue) with no grid. In dark
// mode they read as soft glows on a near-black backdrop. The lower bloom is
// tinted with the current mood accent (see SoftBackdrop.tint).
class _AuroraBackdropPainter extends CustomPainter {
  _AuroraBackdropPainter({required this.dark, required this.tint});

  final bool dark;
  final Color tint;

  void _bloom(Canvas canvas, Size size, Alignment center, double radius,
      List<Color> colors) {
    final paint = Paint()
      ..shader = RadialGradient(center: center, radius: radius, colors: colors)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..blendMode = BlendMode.plus;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Restrained spectrum glows: just enough colour at the top corners to
    // signal the brand, never loud enough to fight the content. The bottom
    // bloom carries the mood tint.
    if (dark) {
      _bloom(canvas, size, const Alignment(-0.95, -1.1), 0.85,
          const [Color(0x2e5b8cff), Color(0x148b5cf6), Color(0x00000000)]);
      _bloom(canvas, size, const Alignment(1.0, -0.9), 0.8,
          const [Color(0x24ff5e8a), Color(0x0f8b5cf6), Color(0x00000000)]);
      _bloom(canvas, size, const Alignment(0.2, 1.25), 0.9,
          [tint.withValues(alpha: 0.13), const Color(0x00000000)]);
      return;
    }
    _bloom(canvas, size, const Alignment(-0.95, -1.1), 0.85,
        const [Color(0x265b8cff), Color(0x108b5cf6), Color(0x00ffffff)]);
    _bloom(canvas, size, const Alignment(1.0, -0.9), 0.8,
        const [Color(0x1fff5e8a), Color(0x0c8b5cf6), Color(0x00ffffff)]);
    _bloom(canvas, size, const Alignment(0.2, 1.25), 0.9,
        [tint.withValues(alpha: 0.10), const Color(0x00ffffff)]);
  }

  @override
  bool shouldRepaint(covariant _AuroraBackdropPainter oldDelegate) =>
      oldDelegate.dark != dark || oldDelegate.tint != tint;
}

class SoftPage extends StatelessWidget {
  const SoftPage({super.key, required this.child, this.tint});

  final Widget child;

  // Optional mood accent forwarded to the backdrop glow.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Keyed by brightness so the aurora backdrop rebuilds (and repaints)
        // when switching between light and dark.
        Positioned.fill(
            child: SoftBackdrop(key: ValueKey(DesignTokens.isDark), tint: tint)),
        Positioned.fill(child: child),
      ],
    );
  }
}
