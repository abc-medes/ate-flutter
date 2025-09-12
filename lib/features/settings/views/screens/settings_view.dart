import 'package:bodai/common_libs.dart';
import 'package:bodai/core/services/auth_service.dart';
import 'package:bodai/core/routes/route_names.dart';
import 'package:bodai/core/widgets/context_input.dart';
import 'package:bodai/features/settings/view_models/settings_view_model.dart';
import 'package:bodai/features/settings/views/widgets/health_context_section.dart';
import 'package:bodai/features/settings/views/widgets/momorized_context_section.dart';
import 'package:bodai/features/settings/views/widgets/section_header.dart';
import 'package:bodai/features/settings/views/widgets/setting_header.dart';
import 'package:bodai/features/settings/views/widgets/setting_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          const SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SectionHeader(title: 'Account'),
                  SettingItem(
                    title: 'Sign Out',
                    icon: Icons.exit_to_app,
                    onTap: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        context.go(RouteNames.home);
                      }
                    },
                    isDestructive: true,
                  ),
                  SettingItem(
                    title: 'Reset Health Data',
                    icon: Icons.medical_services_outlined,
                    onTap: () {
                      _showResetHealthDataDialog(context);
                    },
                    isDestructive: true,
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // AI Settings section
                  const SectionHeader(title: 'AI Settings'),
                  if (settingsState.aiSettings == null) ...[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: $styles.insets.sm),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else ...[
                    ...[
                      {
                        'title': 'Tone',
                        'icon': Icons.record_voice_over,
                        'value': settingsState.aiSettings!.tone
                      },
                      {
                        'title': 'Language',
                        'icon': Icons.language,
                        'value': settingsState.aiSettings!.language
                      },
                      {
                        'title': 'Formality',
                        'icon': Icons.school_outlined,
                        'value': settingsState.aiSettings!.formality
                      },
                      {
                        'title': 'Detail Level',
                        'icon': Icons.tune,
                        'value': settingsState.aiSettings!.detailLevel
                      },
                      {
                        'title': 'Emoji Usage',
                        'icon': Icons.emoji_emotions_outlined,
                        'value': settingsState.aiSettings!.emojiUsage
                      },
                      {
                        'title': 'Response Length',
                        'icon': Icons.text_fields,
                        'value': settingsState.aiSettings!.responseLength
                      },
                      {
                        'title': 'Goal Focus',
                        'icon': Icons.flag_outlined,
                        'value': settingsState.aiSettings!.goalFocus
                      },
                      {
                        'title': 'Summarize Style',
                        'icon': Icons.summarize_outlined,
                        'value': settingsState.aiSettings!.summarizeStyle
                      },
                    ]
                        .map((r) => SettingItem(
                              title: r['title'] as String,
                              icon: r['icon'] as IconData,
                              onTap: () {}, // TODO: open picker
                              trailing: Text(
                                r['value'] as String,
                                style: $styles.text.bodySmall
                                    .copyWith(color: $styles.colors.accent1),
                              ),
                            ))
                        .toList(),
                  ],

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Health Context section
                  const SectionHeader(title: 'Health Context'),
                  const HealthContextSection(),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Memorized Data section
                  const SectionHeader(title: 'Memorized Context'),
                  MemorizedContextSection(
                      memorizedData: settingsState.memorizedData),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Appearance section
                  const SectionHeader(title: 'Appearance'),
                  SettingItem(
                    title: 'Dark Mode',
                    icon: Icons.dark_mode,
                    onTap: () {},
                    trailing: Switch(
                      value: false,
                      onChanged: (_) {},
                      activeColor: $styles.colors.accent1,
                    ),
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // About section
                  const SectionHeader(title: 'About'),
                  SettingItem(
                    title: 'App Version',
                    icon: Icons.info,
                    onTap: () {},
                    trailing: Text('1.0.0',
                        style: $styles.text.bodySmall.copyWith(
                          color: $styles.colors.caption,
                        )),
                  ),
                  SettingItem(
                    title: 'Terms of Service',
                    icon: Icons.description,
                    onTap: () {},
                  ),
                  SettingItem(
                    title: 'Privacy Policy',
                    icon: Icons.policy,
                    onTap: () {},
                  ),

                  SizedBox(height: $styles.insets.xl),
                ],
              ),
            ),
          ),

          // Chat section for AI settings
          Container(
            decoration: BoxDecoration(
              color: $styles.colors.backgroundDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular($styles.insets.lg),
                topRight: Radius.circular($styles.insets.lg),
              ),
            ),
            child: ContextInput(
              title: 'Personalize your assistant',
              subtitle:
                  'Share details that help responses stay relevant long-term — preferences, health history, routines, or goals.',
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguage() {
    // Get current locale from device
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    switch (deviceLocale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      default:
        return 'English';
    }
  }

  void _showResetHealthDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Health Data', style: $styles.text.h3),
          content: Text(
            'This will reset all your health-related data including height, weight, conditions, and more. This action cannot be undone.',
            style: $styles.text.body.copyWith(
              color: $styles.colors.body,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                $styles.colors.accent1),
                          ),
                          SizedBox(width: $styles.insets.md),
                          Text("Resetting health data...",
                              style: $styles.text.body),
                        ],
                      ),
                    );
                  },
                );

                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('health_metrics');

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Health data reset successfully',
                          style: $styles.text.body.copyWith(
                            color: $styles.colors.white,
                          ),
                        ),
                        backgroundColor: $styles.colors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error resetting health data: $e',
                          style: $styles.text.body.copyWith(
                            color: $styles.colors.white,
                          ),
                        ),
                        backgroundColor: $styles.colors.error,
                      ),
                    );
                  }
                }
              },
              child: Text('RESET',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.error,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        );
      },
    );
  }
}
