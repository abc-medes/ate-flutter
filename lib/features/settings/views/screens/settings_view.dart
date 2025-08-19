import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regene/core/services/auth_service.dart';
import 'package:regene/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regene/common_libs.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: $styles.text.h2.copyWith(
              color: $styles.colors.accent1,
            )),
        backgroundColor: $styles.colors.background,
      ),
      backgroundColor: $styles.colors.background,
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: $styles.insets.md),

            // Account section
            _buildSectionHeader(context, 'Account'),
            if (isAuthenticated) ...[
              _buildSettingItem(
                context,
                'Profile',
                Icons.person,
                () => context.push(RouteNames.profile),
              ),
              _buildSettingItem(
                context,
                'Notifications',
                Icons.notifications,
                () {},
              ),
              _buildSettingItem(
                context,
                'Privacy',
                Icons.lock,
                () {},
              ),
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
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            Text('Reset Health Data', style: $styles.text.h3),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                                final prefs =
                                    await SharedPreferences.getInstance();
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
                },
                isDestructive: true,
              ),
            ] else ...[
              _buildSettingItem(
                context,
                'Sign In',
                Icons.login,
                () => context.push(RouteNames.login),
              ),
            ],

            Divider(color: $styles.colors.caption),

            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            _buildSettingItem(
              context,
              'Dark Mode',
              Icons.dark_mode,
              () {},
              trailing: Switch(
                value: false, // Get this from a theme provider
                onChanged: (_) {},
                activeColor: $styles.colors.accent1,
              ),
            ),

            Divider(color: $styles.colors.caption),

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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: $styles.insets.md,
        top: $styles.insets.md,
        bottom: $styles.insets.sm,
      ),
      child: Text(
        title,
        style: $styles.text.h3.copyWith(
          color: $styles.colors.accent1,
          fontWeight: FontWeight.bold,
        ),
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
}
