import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/screens/home_screen.dart';
import 'package:moodtube/screens/player_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';

Future<void> showMoodDialSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const MoodDialSheet(),
  );
}

class MoodDialSheet extends StatefulWidget {
  const MoodDialSheet({super.key});

  @override
  State<MoodDialSheet> createState() => _MoodDialSheetState();
}

class _MoodDialSheetState extends State<MoodDialSheet> {
  bool isStarting = false;
  MoodPreset? selected;

  @override
  Widget build(BuildContext context) {
    const dialMoods = dialMoodPresets;
    final selectedMood = dialMoods.any((m) => m.id == selected?.id)
        ? selected!
        : dialMoods[dialMoods.length ~/ 2];
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.sheet,
        border: Border(top: BorderSide(color: DesignTokens.cardBorder)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 30, offset: Offset(0, -8))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: DesignTokens.muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 16),
              AuroraMoodDial(
                moods: dialMoods,
                selectedMood: selectedMood,
                onMoodSelected: (mood) => setState(() => selected = mood),
                onPrimaryAction: () => _play(selectedMood),
                isPrimaryBusy: isStarting,
                showHeader: true,
                showFooter: false,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _play(MoodPreset mood) async {
    if (isStarting) return;
    setState(() => isStarting = true);
    try {
      final state = context.read<MoodTubeState>();
      final results = await state.searchMoodAndRemember(mood);
      if (!mounted || results.isEmpty) return;
      final item = results.first;
      state.startPlayback(item, queue: results);
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.push(MaterialPageRoute(
          builder: (_) => PlayerScreen(item: item, queue: results)));
    } finally {
      if (mounted) setState(() => isStarting = false);
    }
  }
}

class AuroraMoodDial extends StatefulWidget {
  static const Size canvasSize = Size(340, 226);
  static const double cy = 0.78; // dial center, fraction of canvas height
  static const double rx = 134; // node ellipse radius x
  static const double ry = 146; // node ellipse radius y

  const AuroraMoodDial({
    super.key,
    required this.moods,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.onPrimaryAction,
    this.onBrowse,
    this.isPrimaryBusy = false,
    this.showHeader = true,
    this.showFooter = true,
  });

  final List<MoodPreset> moods;
  final MoodPreset selectedMood;
  final ValueChanged<MoodPreset> onMoodSelected;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onBrowse;
  final bool isPrimaryBusy;
  final bool showHeader;
  final bool showFooter;

  @override
  State<AuroraMoodDial> createState() => _AuroraMoodDialState();
}

class _AuroraMoodDialState extends State<AuroraMoodDial> {
  MoodPreset? _localSelectedMood;

  @override
  void initState() {
    super.initState();
    _localSelectedMood = widget.selectedMood;
  }

  @override
  void didUpdateWidget(covariant AuroraMoodDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMood.id != widget.selectedMood.id) {
      _localSelectedMood = widget.selectedMood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final currentMood = _localSelectedMood ?? widget.selectedMood;
    final selectedIndex =
        max(0, widget.moods.indexWhere((mood) => mood.id == currentMood.id));
    final progress = widget.moods.length <= 1
        ? 0.0
        : selectedIndex / (widget.moods.length - 1);
    final moodLabel = text.moodName(currentMood.id);
    return Column(
      children: [
        if (widget.showHeader) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text.dialTitle,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: DesignTokens.ink),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text.dialSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: DesignTokens.muted),
          ),
          const SizedBox(height: 12),
        ],
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: AuroraMoodDial.canvasSize.width,
              height: AuroraMoodDial.canvasSize.height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (d) => _selectFromOffset(d.localPosition),
                    onPanEnd: (d) => _finalizeSelection(),
                    onTapDown: (d) => _selectFromOffset(d.localPosition),
                    onTapUp: (d) => _finalizeSelection(),
                    // Animate the gauge arc + knob toward the selected node so
                    // the dial feels mechanical instead of teleporting.
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progress),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, _) => CustomPaint(
                        size: AuroraMoodDial.canvasSize,
                        painter: _AuroraDialPainter(
                          progress: animatedProgress,
                          isDark: DesignTokens.isDark,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AuroraMoodDial.canvasSize.width / 2 - 29,
                    top: AuroraMoodDial.canvasSize.height * AuroraMoodDial.cy -
                        29,
                    child: _CenterPlay(
                        busy: widget.isPrimaryBusy,
                        onTap: widget.onPrimaryAction),
                  ),
                  ...List.generate(widget.moods.length, (index) {
                    final mood = widget.moods[index];
                    final angle = _angleForIndex(index);
                    final cx = AuroraMoodDial.canvasSize.width / 2 +
                        cos(angle) * AuroraMoodDial.rx;
                    final cy =
                        AuroraMoodDial.canvasSize.height * AuroraMoodDial.cy +
                            sin(angle) * AuroraMoodDial.ry;
                    return Positioned(
                      left: cx - 34,
                      top: cy - 26,
                      child: _MoodDialNode(
                        mood: mood,
                        label: text.moodName(mood.id),
                        selected: mood.id == currentMood.id,
                        onTap: () {
                          setState(() {
                            _localSelectedMood = mood;
                          });
                          widget.onMoodSelected(mood);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        if (widget.showFooter) ...[
          const SizedBox(height: 6),
          Text(
            text.moodVibes(moodLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: DesignTokens.ink),
          ),
          if (widget.onBrowse != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: widget.onBrowse,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text.findPlaylists,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.muted)),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: DesignTokens.muted),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  double _angleForIndex(int index) {
    if (widget.moods.length <= 1) return 1.5 * pi;
    return pi + (pi * index / (widget.moods.length - 1));
  }

  void _selectFromOffset(Offset offset) {
    final center = Offset(AuroraMoodDial.canvasSize.width / 2,
        AuroraMoodDial.canvasSize.height * AuroraMoodDial.cy);
    final rawAngle = atan2(offset.dy - center.dy, offset.dx - center.dx);
    final angle = rawAngle < 0 ? rawAngle + (2 * pi) : rawAngle;
    final normalized = ((angle - pi) / pi).clamp(0.0, 1.0);
    final index = (normalized * (widget.moods.length - 1))
        .round()
        .clamp(0, widget.moods.length - 1);
    final targetMood = widget.moods[index];
    if (targetMood.id != _localSelectedMood?.id) {
      HapticFeedback.selectionClick();
      setState(() {
        _localSelectedMood = targetMood;
      });
    }
  }

  void _finalizeSelection() {
    if (_localSelectedMood != null) {
      widget.onMoodSelected(_localSelectedMood!);
    }
  }
}

class _CenterPlay extends StatelessWidget {
  const _CenterPlay({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap();
            },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: DesignTokens.spectrum,
          ),
          border: Border.all(color: DesignTokens.background, width: 3),
          boxShadow: DesignTokens.glowShadow,
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white))
            : const Icon(Icons.play_arrow_rounded,
                size: 30, color: Colors.white),
      ),
    );
  }
}

class _MoodDialNode extends StatelessWidget {
  const _MoodDialNode(
      {required this.mood,
      required this.label,
      required this.selected,
      required this.onTap});

  final MoodPreset mood;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = atmosphereAccent(mood.id);
    final dia = selected ? 50.0 : 44.0;
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          width: 68,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: dia,
                height: dia,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? DesignTokens.panel
                      : DesignTokens.panel.withValues(alpha: 0.72),
                  border: Border.all(
                      color: selected
                          ? accent.withValues(alpha: 0.8)
                          : DesignTokens.cardBorder,
                      width: selected ? 2 : 1),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: accent.withValues(alpha: 0.34),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ]
                      : DesignTokens.smallShadow,
                ),
                child: Icon(MoodGlyph.iconForMood(mood.id),
                    color: accent, size: selected ? 24 : 21),
              ),
              const SizedBox(height: 5),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? DesignTokens.ink : DesignTokens.sage)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuroraDialPaintCache {
  _AuroraDialPaintCache({required this.dark});

  final bool dark;

  late final RadialGradient haloGradient = RadialGradient(
    center: const Alignment(0, -0.05),
    radius: 0.62,
    colors: [
      DesignTokens.violet.withValues(alpha: dark ? 0.22 : 0.16),
      DesignTokens.rose.withValues(alpha: dark ? 0.12 : 0.10),
      const Color(0x00000000),
    ],
    stops: const [0.0, 0.55, 1.0],
  );
  late final RadialGradient faceGradient = RadialGradient(
    center: const Alignment(0, -0.12),
    radius: 0.98,
    colors: dark
        ? const [Color(0x24ffffff), Color(0x0fffffff), Color(0x00ffffff)]
        : const [Color(0xffffffff), Color(0x99f6f5f2), Color(0x00f6f5f2)],
    stops: const [0.0, 0.6, 1.0],
  );
  late final SweepGradient gaugeBackgroundGradient = SweepGradient(
    startAngle: pi,
    endAngle: pi * 2,
    colors: dark
        ? const [Color(0x14ffffff), Color(0x3dffffff), Color(0x14ffffff)]
        : const [Color(0x26ffffff), Color(0x66ffffff), Color(0x26ffffff)],
  );
  late final SweepGradient gaugeFillGradient = const SweepGradient(
    startAngle: pi,
    endAngle: pi * 2,
    colors: DesignTokens.spectrum,
  );
  late final Paint haloPaint = Paint();
  late final Paint facePaint = Paint();
  late final Paint gaugeBackgroundPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18
    ..strokeCap = StrokeCap.round;
  late final Paint gaugeFillPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 11
    ..strokeCap = StrokeCap.round;
  late final Paint tickPaint = Paint()
    ..color =
        dark ? Colors.white.withValues(alpha: 0.35) : const Color(0x26000000)
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  late final Paint knobGlowPaint = Paint()
    ..color = DesignTokens.violet.withValues(alpha: 0.3)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  late final Paint knobPanelPaint = Paint()
    ..color = dark ? const Color(0xff15151e) : const Color(0xffffffff);
  late final Paint knobInnerPaint = Paint();
  late final RadialGradient knobInnerGradient = const RadialGradient(
    colors: [Colors.white, DesignTokens.violet],
  );

  Rect? _haloRect;
  Rect? _faceRect;
  Rect? _gaugeRect;
  Rect? _knobInnerRect;

  Paint halo(Rect rect) {
    if (_haloRect != rect) {
      _haloRect = rect;
      haloPaint.shader = haloGradient.createShader(rect);
    }
    return haloPaint;
  }

  Paint face(Rect rect) {
    if (_faceRect != rect) {
      _faceRect = rect;
      facePaint.shader = faceGradient.createShader(rect);
    }
    return facePaint;
  }

  Paint gaugeBackground(Rect rect) {
    if (_gaugeRect != rect) {
      _gaugeRect = rect;
      gaugeBackgroundPaint.shader = gaugeBackgroundGradient.createShader(rect);
      gaugeFillPaint.shader = gaugeFillGradient.createShader(rect);
    }
    return gaugeBackgroundPaint;
  }

  Paint gaugeFill(Rect rect) {
    gaugeBackground(rect);
    return gaugeFillPaint;
  }

  Paint knobInner(Rect rect) {
    if (_knobInnerRect != rect) {
      _knobInnerRect = rect;
      knobInnerPaint.shader = knobInnerGradient.createShader(rect);
    }
    return knobInnerPaint;
  }
}

class _AuroraDialPainter extends CustomPainter {
  const _AuroraDialPainter({required this.progress, required this.isDark});

  static final _lightPaintCache = _AuroraDialPaintCache(dark: false);
  static final _darkPaintCache = _AuroraDialPaintCache(dark: true);

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * AuroraMoodDial.cy);
    final p = progress.clamp(0.0, 1.0);
    const rx = AuroraMoodDial.rx; // node ellipse radius x
    const ry = AuroraMoodDial.ry; // node ellipse radius y
    final cache = isDark ? _darkPaintCache : _lightPaintCache;

    // 1) faint halo behind the whole dial (reference-style soft glow)
    final haloRect =
        Rect.fromCenter(center: center, width: rx * 2.7, height: ry * 2.7);
    canvas.drawRect(haloRect, cache.halo(haloRect));

    // 2) inner face disk — fades out toward the edges (incl. bottom)
    const faceR = rx * 0.74;
    final faceRect = Rect.fromCircle(center: center, radius: faceR);
    canvas.drawCircle(center, faceR, cache.face(faceRect));

    // 3) gauge arc on the NODE ellipse so it links icon-to-icon
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    canvas.drawArc(rect, pi, pi, false, cache.gaugeBackground(rect));
    canvas.drawArc(rect, pi, pi * p, false, cache.gaugeFill(rect));

    // 4) ticks inside the ellipse
    for (var i = 0; i <= 28; i++) {
      final a = pi + pi * i / 28;
      final inner =
          Offset(center.dx + cos(a) * rx * 0.6, center.dy + sin(a) * ry * 0.6);
      final outer = Offset(
          center.dx + cos(a) * rx * 0.73, center.dy + sin(a) * ry * 0.73);
      canvas.drawLine(inner, outer, cache.tickPaint);
    }

    // 5) knob riding the ellipse
    final ka = pi + pi * p;
    final kc = Offset(center.dx + cos(ka) * rx, center.dy + sin(ka) * ry);
    canvas.drawCircle(kc, 15, cache.knobGlowPaint);
    canvas.drawCircle(kc, 11, cache.knobPanelPaint);
    canvas.drawCircle(
        kc, 6, cache.knobInner(Rect.fromCircle(center: kc, radius: 7)));
  }

  @override
  bool shouldRepaint(covariant _AuroraDialPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
