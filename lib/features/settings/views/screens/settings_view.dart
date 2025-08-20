import 'package:regene/common_libs.dart';
import 'package:regene/core/services/auth_service.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:regene/data/models/health_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regene/core/widgets/chat_input.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/data/repositories/health_repository.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/core/widgets/padded_divider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final TextEditingController _chatController = TextEditingController();
  bool _isSaveMode = false;
  List<ChatMessageDTO> _chatHistory = [];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _handleChatSubmit(ChatMessageDTO chatMessage) {
    if (chatMessage.message?.isNotEmpty == true) {
      setState(() {
        _chatHistory.add(chatMessage);
      });

      // Simulate AI response for now
      _simulateAIResponse(chatMessage.message!);
    }
  }

  void _simulateAIResponse(String userMessage) {
    String aiResponse = _generateAIResponse(userMessage);

    final aiMessage = ChatMessageDTO(
      userId: 'ai',
      createdAt: DateTime.now(),
      clientLocalTimestamp: DateTime.now(),
      sessionId: 'settings_session',
      message: aiResponse,
      isUser: false,
      chatOffset: 0,
    );

    setState(() {
      _chatHistory.add(aiMessage);
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('한국말') || lowerMessage.contains('korean')) {
      return '네, 앞으로 한국어로 대화하겠습니다. 한국어 설정이 저장되었습니다.';
    } else if (lowerMessage.contains('사근사근') ||
        lowerMessage.contains('친근') ||
        lowerMessage.contains('친근하게')) {
      return '알겠어요! 앞으로 더 친근하고 따뜻한 말투로 대화하겠습니다. 😊';
    } else if (lowerMessage.contains('흡연') ||
        lowerMessage.contains('담배') ||
        lowerMessage.contains('smoking')) {
      return '흡연 이력 정보를 저장했습니다. 이 정보는 건강 인사이트에 반영됩니다.';
    } else if (lowerMessage.contains('도움') || lowerMessage.contains('help')) {
      return '다음과 같은 설정을 변경할 수 있습니다:\n\n' +
          '• 언어 설정: "한국말로 계속말해줘"\n' +
          '• 말투 설정: "나한테 사근사근하게 말해줘"\n' +
          '• 건강 이력: "15년간 흡연했어요, 15세부터 시작했고 지금은 금연중이에요"\n' +
          '• 기타 개인화 설정들';
    } else {
      return '설정을 변경하고 싶으시다면 말씀해 주세요. 언어, 말투, 건강 이력 등을 설정할 수 있습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          _buildHeader(context, ref),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSectionHeader(context, 'Account'),
                  _buildSettingItem(
                    context,
                    'Sign Out',
                    Icons.exit_to_app,
                    () async {
                      await authService.signOut();
                      if (context.mounted) {
                        context.go(RouteNames.home);
                      }
                    },
                    isDestructive: true,
                  ),
                  _buildSettingItem(
                    context,
                    'Reset Health Data',
                    Icons.medical_services_outlined,
                    () {
                      _showResetHealthDataDialog(context);
                    },
                    isDestructive: true,
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // AI Settings section
                  _buildSectionHeader(context, 'AI Settings'),
                  _buildSettingItem(
                    context,
                    'Language Preference',
                    Icons.language,
                    () {},
                    trailing: Text(
                      _getCurrentLanguage(),
                      style: $styles.text.bodySmall.copyWith(
                        color: $styles.colors.accent1,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    'Communication Style',
                    Icons.psychology,
                    () {},
                    trailing: Text(
                      '친근함',
                      style: $styles.text.bodySmall.copyWith(
                        color: $styles.colors.accent1,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    'Health Context',
                    Icons.medical_information,
                    () {},
                    trailing: Text(
                      '완료됨',
                      style: $styles.text.bodySmall.copyWith(
                        color: $styles.colors.accent1,
                      ),
                    ),
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Health Context section
                  _buildSectionHeader(context, 'Health Context'),
                  _buildHealthContextItems(context),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // Memorized Data section
                  _buildSectionHeader(context, 'Memorized Context'),
                  _buildMemorizedDataItems(context),

                  PaddedDivider.medium(color: $styles.colors.caption),
                  // Appearance section
                  _buildSectionHeader(context, 'Appearance'),
                  _buildSettingItem(
                    context,
                    'Dark Mode',
                    Icons.dark_mode,
                    () {},
                    trailing: Switch(
                      value: false,
                      onChanged: (_) {},
                      activeColor: $styles.colors.accent1,
                    ),
                  ),

                  PaddedDivider.medium(color: $styles.colors.caption),

                  // About section
                  _buildSectionHeader(context, 'About'),
                  _buildSettingItem(
                    context,
                    'App Version',
                    Icons.info,
                    () {},
                    trailing: Text('1.0.0',
                        style: $styles.text.bodySmall.copyWith(
                          color: $styles.colors.caption,
                        )),
                  ),
                  _buildSettingItem(
                    context,
                    'Terms of Service',
                    Icons.description,
                    () {},
                  ),
                  _buildSettingItem(
                    context,
                    'Privacy Policy',
                    Icons.policy,
                    () {},
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
              border: Border(
                top: BorderSide(color: $styles.colors.accent1, width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chat history preview
                if (_chatHistory.isNotEmpty)
                  Container(
                    height: 120,
                    padding: EdgeInsets.all($styles.insets.sm),
                    child: ListView.builder(
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final message = _chatHistory[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: $styles.insets.xs),
                          padding: EdgeInsets.symmetric(
                            horizontal: $styles.insets.sm,
                            vertical: $styles.insets.xs,
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? $styles.colors.accent1
                                : $styles.colors.accent2,
                            borderRadius:
                                BorderRadius.circular($styles.corners.sm),
                          ),
                          child: Text(
                            message.message ?? '',
                            style: $styles.text.bodySmall.copyWith(
                              color: $styles.colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),

                // Chat input
                ChatInput(
                  shouldSaveAsContext: _isSaveMode,
                  onSaveModeToggle: () =>
                      setState(() => _isSaveMode = !_isSaveMode),
                  onSubmit: _handleChatSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB($styles.insets.md, mq.padding.top,
          $styles.insets.md, $styles.insets.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircularIconButton(
                icon: Icons.arrow_back,
                size: 48,
                iconColor: $styles.colors.black,
                onTap: () => context.go(RouteNames.home),
              ),
              Text('Settings', style: $styles.text.h3),
              SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthContextItems(BuildContext context) {
    return FutureBuilder<HealthMetrics>(
      future: healthRepository.getExistingHealthMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text(
              '건강 데이터를 불러올 수 없습니다.',
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          );
        }

        final healthMetrics = snapshot.data!;
        final userInputData = healthMetrics.userInputData;

        return Column(
          children: [
            if (userInputData.gender != null)
              _buildSettingItem(
                context,
                '성별',
                Icons.person,
                () {},
                trailing: Text(
                  userInputData.gender == 'male' ? '남성' : '여성',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                  ),
                ),
              ),
            if (userInputData.height != null)
              _buildSettingItem(
                context,
                '키',
                Icons.height,
                () {},
                trailing: Text(
                  '${userInputData.height!.toInt()}cm',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                  ),
                ),
              ),
            if (userInputData.weight != null)
              _buildSettingItem(
                context,
                '체중',
                Icons.monitor_weight,
                () {},
                trailing: Text(
                  '${userInputData.weight!.toInt()}kg',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                  ),
                ),
              ),
            if (userInputData.bodyType != null)
              _buildSettingItem(
                context,
                '체형',
                Icons.accessibility_new,
                () {},
                trailing: Text(
                  userInputData.bodyType!,
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                  ),
                ),
              ),
            if (userInputData.dateOfBirth != null)
              _buildSettingItem(
                context,
                '생년월일',
                Icons.cake,
                () {},
                trailing: Text(
                  '${userInputData.dateOfBirth!.year}년 ${userInputData.dateOfBirth!.month}월 ${userInputData.dateOfBirth!.day}일',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.accent1,
                  ),
                ),
              ),
          ],
        );
      },
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: $styles.text.h3.copyWith(
        color: $styles.colors.accent1,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? $styles.colors.error : $styles.colors.accent1,
      ),
      title: Text(
        title,
        style: $styles.text.body.copyWith(
          color: isDestructive ? $styles.colors.error : $styles.colors.black,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: $styles.colors.caption,
          ),
      onTap: onTap,
      tileColor: $styles.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($styles.corners.sm),
      ),
    );
  }

  Widget _buildMemorizedDataItems(BuildContext context) {
    return FutureBuilder<HealthMetrics>(
      future: healthRepository.getExistingHealthMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text(
              '기억된 데이터를 불러올 수 없습니다.',
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          );
        }

        final healthMetrics = snapshot.data!;
        final userInputData = healthMetrics.userInputData;
        final memorizedData = userInputData.memorizedData;

        if (memorizedData == null || memorizedData.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Text(
              '아직 기억된 데이터가 없습니다. 아래 채팅을 통해 설정해보세요.',
              style: $styles.text.bodySmall.copyWith(
                color: $styles.colors.caption,
              ),
            ),
          );
        }

        return Column(
          children: memorizedData.entries.map<Widget>((entry) {
            final key = entry.key;
            final value = entry.value;

            if (value is List && value.isNotEmpty) {
              return ExpansionTile(
                leading: Icon(
                  Icons.info,
                  color: $styles.colors.accent1,
                ),
                title: Text(
                  _formatDisplayName(key),
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.black,
                  ),
                ),
                subtitle: Text(
                  '${value.length}개 항목',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.caption,
                  ),
                ),
                children: [
                  ...value
                      .map<Widget>(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            left: $styles.insets.lg,
                            right: $styles.insets.md,
                            bottom: $styles.insets.sm,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: $styles.colors.accent1,
                              ),
                              SizedBox(width: $styles.insets.sm),
                              Expanded(
                                child: Text(
                                  item.toString(),
                                  style: $styles.text.bodySmall.copyWith(
                                    color: $styles.colors.body,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              );
            } else if (value is String && value.isNotEmpty) {
              return ListTile(
                leading: Icon(
                  Icons.info,
                  color: $styles.colors.accent1,
                ),
                title: Text(
                  _formatDisplayName(key),
                  style: $styles.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  value,
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.body,
                  ),
                ),
              );
            } else if (value is Map && value.isNotEmpty) {
              return ExpansionTile(
                leading: Icon(
                  Icons.info,
                  color: $styles.colors.accent1,
                ),
                title: Text(
                  _formatDisplayName(key),
                  style: $styles.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${value.length}개 항목',
                  style: $styles.text.bodySmall.copyWith(
                    color: $styles.colors.caption,
                  ),
                ),
                children: [
                  ...value.entries
                      .map<Widget>(
                        (subEntry) => Padding(
                          padding: EdgeInsets.only(
                            left: $styles.insets.lg,
                            right: $styles.insets.md,
                            bottom: $styles.insets.sm,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: $styles.colors.accent1,
                              ),
                              SizedBox(width: $styles.insets.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDisplayName(subEntry.key),
                                      style: $styles.text.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: $styles.colors.accent1,
                                      ),
                                    ),
                                    Text(
                                      subEntry.value.toString(),
                                      style: $styles.text.bodySmall.copyWith(
                                        color: $styles.colors.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              );
            }

            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  String _formatDisplayName(String key) {
    // Convert snake_case to readable text
    return key
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ')
        .trim();
  }
}
