import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/navigation.dart';

class MoodTubeApp extends StatelessWidget {
  const MoodTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<MoodTubeState, (ThemeMode, Locale?)>(
      selector: (context, state) => (state.themeMode, state.appLocale),
      builder: (context, data, _) {
        final (themeMode, appLocale) = data;
        // Resolve effective brightness from the theme mode, following the
        // device when set to system. Drives the brightness-aware DesignTokens.
        final platformBrightness =
            MediaQuery.maybeOf(context)?.platformBrightness ??
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final brightness = switch (themeMode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => platformBrightness,
        };
        DesignTokens.brightness = brightness;
        return MaterialApp(
          title: 'MoodTube',
          debugShowCheckedModeBanner: false,
          locale: appLocale,
          supportedLocales: const [Locale('en'), Locale('ko'), Locale('zh')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale?.languageCode == 'ko') return const Locale('ko');
            if (locale?.languageCode == 'zh') return const Locale('zh');
            return const Locale('en');
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: DesignTokens.mint,
              brightness: brightness,
            ).copyWith(
              surface: DesignTokens.panel,
              surfaceContainerHighest: DesignTokens.panelAlt,
              primary: DesignTokens.violet,
              secondary: DesignTokens.rose,
              onSurface: DesignTokens.ink,
              onPrimary: Colors.white,
            ),
            fontFamily: 'Noto Sans',
            fontFamilyFallback: const [
              'Pretendard',
              'Apple SD Gothic Neo',
              'Noto Sans SC',
              'PingFang SC',
              'Noto Sans CJK SC',
              'Noto Sans CJK KR',
              'Noto Sans KR',
              'Roboto',
              'sans-serif',
            ],
            scaffoldBackgroundColor: DesignTokens.background,
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: DesignTokens.ink,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: DesignTokens.ink),
            ),
            cardTheme: CardThemeData(
              color: DesignTokens.panel,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: DesignTokens.cardBorder),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: DesignTokens.panelAlt,
              selectedColor: DesignTokens.violet.withValues(alpha: 0.16),
              labelStyle: TextStyle(
                  color: DesignTokens.sage,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              side: BorderSide(color: DesignTokens.cardBorder),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(999))),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: DesignTokens.sage,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: DesignTokens.violet.withValues(alpha: 0.16),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  color: states.contains(WidgetState.selected)
                      ? DesignTokens.ink
                      : DesignTokens.muted,
                  fontSize: 12,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? DesignTokens.ink
                      : DesignTokens.muted,
                  size: 24,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: DesignTokens.panel,
              labelStyle: TextStyle(color: DesignTokens.muted),
              helperStyle: TextStyle(color: DesignTokens.muted),
              prefixIconColor: DesignTokens.violet,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: DesignTokens.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: DesignTokens.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: DesignTokens.violet, width: 1.5),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.ink,
                backgroundColor: DesignTokens.panelAlt,
                side: BorderSide(color: DesignTokens.cardBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
            ),
          ),
          home: const ShellScreen(),
        );
      },
    );
  }
}
