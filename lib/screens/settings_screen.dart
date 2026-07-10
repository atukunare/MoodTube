import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/navigation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _versionLabel = info.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionLabel = '0.3.3');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          PremiumHeader(
              title: text.settings,
              subtitle: text.settingsSubtitle,
              accent: DesignTokens.graphite),
          const SizedBox(height: 18),
          // Interactive settings first; static info blocks live below them.
          SettingFieldShell(
            label: text.language,
            helper: text.languageHelp,
            child: DropdownButtonFormField<String>(
              key: ValueKey(state.languageCode),
              initialValue: state.languageCode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.ink),
              dropdownColor: DesignTokens.cream,
              items: languageOptions
                  .map((option) => DropdownMenuItem(
                        value: option.code,
                        child: Text(option.label(text)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) state.setLanguageCode(value);
              },
            ),
          ),
          const SizedBox(height: 18),
          SettingFieldShell(
            label: text.theme,
            helper: text.themeHelp,
            child: DropdownButtonFormField<ThemeMode>(
              key: ValueKey(state.themeMode),
              initialValue: state.themeMode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.ink),
              dropdownColor: DesignTokens.cream,
              items: [
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text(text.themeSystem)),
                DropdownMenuItem(
                    value: ThemeMode.light, child: Text(text.themeLight)),
                DropdownMenuItem(
                    value: ThemeMode.dark, child: Text(text.themeDark)),
              ],
              onChanged: (value) {
                if (value != null) state.setThemeMode(value);
              },
            ),
          ),
          const SizedBox(height: 18),
          SettingFieldShell(
            label: text.resetPlayErrorLabel,
            helper: text.resetPlayErrorHelp,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${text.blockedVideosCount}: ${state.blacklistedVideoIds.length}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.ink,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: state.blacklistedVideoIds.isEmpty
                      ? null
                      : () async {
                          await state.clearBlacklist();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(text.resetPlayErrorSuccess)),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(text.resetButtonText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SettingsBlock(
            title: text.appDescriptionTitle,
            body: text.appDescriptionBody,
          ),
          SettingsBlock(
            title: text.policyTitle,
            body: text.policyBody,
          ),
          const SizedBox(height: 4),
          if (_versionLabel.isNotEmpty)
            Text(text.appVersionLabel(_versionLabel),
                style: TextStyle(
                    color: DesignTokens.sage, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SettingFieldShell extends StatelessWidget {
  const SettingFieldShell({
    super.key,
    required this.label,
    required this.helper,
    required this.child,
  });

  final String label;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: auroraPanelDecoration(color: DesignTokens.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.sage)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
          const SizedBox(height: 8),
          Text(helper,
              style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.muted)),
        ],
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  const SettingsBlock({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: auroraPanelDecoration(
          color: DesignTokens.panelAlt, shadow: DesignTokens.smallShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.ink)),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.muted)),
        ],
      ),
    );
  }
}
