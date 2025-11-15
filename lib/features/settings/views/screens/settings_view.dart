import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/auth_service.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:bodido/core/widgets/context_input.dart';
import 'package:bodido/features/settings/view_models/settings_view_model.dart';
import 'package:bodido/features/settings/views/widgets/health_context_section.dart';
import 'package:bodido/features/settings/views/widgets/momorized_context_section.dart';
import 'package:bodido/features/settings/views/widgets/section_header.dart';
import 'package:bodido/features/settings/views/widgets/setting_header.dart';
import 'package:bodido/features/settings/views/widgets/setting_item.dart';
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
                  SectionHeader(title: $strings.settings_section_account),
                  SettingItem(
                    title: $strings.settings_sign_out,
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
                    title: $strings.settings_reset_health_data,
                    icon: Icons.medical_services_outlined,
                    onTap: () {
                      _showResetHealthDataDialog(context);
                    },
                    isDestructive: true,
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // AI Settings section
                  SectionHeader(title: $strings.settings_section_ai),
                  if (settingsState.aiSettings == null) ...[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: $styles.insets.sm),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else ...[
                    ...[
                      {
                        'title': $strings.ai_tone,
                        'icon': Icons.record_voice_over,
                        'value': settingsState.aiSettings!.tone
                      },
                      {
                        'title': $strings.ai_language,
                        'icon': Icons.language,
                        'value': settingsState.aiSettings!.language
                      },
                      {
                        'title': $strings.ai_formality,
                        'icon': Icons.school_outlined,
                        'value': settingsState.aiSettings!.formality
                      },
                      {
                        'title': $strings.ai_detail_level,
                        'icon': Icons.tune,
                        'value': settingsState.aiSettings!.detailLevel
                      },
                      {
                        'title': $strings.ai_emoji_usage,
                        'icon': Icons.emoji_emotions_outlined,
                        'value': settingsState.aiSettings!.emojiUsage
                      },
                      {
                        'title': $strings.ai_response_length,
                        'icon': Icons.text_fields,
                        'value': settingsState.aiSettings!.responseLength
                      },
                      {
                        'title': $strings.ai_goal_focus,
                        'icon': Icons.flag_outlined,
                        'value': settingsState.aiSettings!.goalFocus
                      },
                      {
                        'title': $strings.ai_summarize_style,
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
                  SectionHeader(title: $strings.settings_section_health_context),
                  const HealthContextSection(),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Memorized Data section
                  SectionHeader(title: $strings.settings_section_memorized),
                  MemorizedContextSection(
                      memorizedData: settingsState.memorizedData),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Appearance section
                  SectionHeader(title: $strings.settings_section_appearance),
                  SettingItem(
                    title: $strings.settings_dark_mode,
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
                  SectionHeader(title: $strings.settings_section_about),
                  SettingItem(
                    title: $strings.settings_app_version,
                    icon: Icons.info,
                    onTap: () {},
                    trailing: Text('1.0.0',
                        style: $styles.text.bodySmall.copyWith(
                          color: $styles.colors.caption,
                        )),
                  ),
                  SettingItem(
                    title: $strings.settings_terms,
                    icon: Icons.description,
                    onTap: () {},
                  ),
                  SettingItem(
                    title: $strings.settings_privacy,
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
              title: $strings.context_title,
              subtitle: $strings.context_subtitle,
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
          title: Text($strings.settings_reset_title, style: $styles.text.h3),
          content: Text(
            $strings.settings_reset_content,
            style: $styles.text.body.copyWith(
              color: $styles.colors.body,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text($strings.action_cancel.toUpperCase(),
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
                          Text($strings.settings_resetting,
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
                          $strings.settings_reset_success,
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
                          $strings.settings_reset_error(e.toString()),
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
              child: Text($strings.action_reset,
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
