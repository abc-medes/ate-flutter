import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/theme/app_theme.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),

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
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.signOut();
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
                        title: const Text('Reset Health Data'),
                        content: const Text(
                          'This will reset all your health-related data including height, weight, conditions, and more. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    content: Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 20),
                                        Text("Resetting health data..."),
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
                                    const SnackBar(
                                      content: Text(
                                          'Health data reset successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error resetting health data: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('RESET',
                                style: TextStyle(color: Colors.red)),
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

            const Divider(),

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
              ),
            ),

            const Divider(),

            // About section
            _buildSectionHeader(context, 'About'),
            _buildSettingItem(
              context,
              'App Version',
              Icons.info,
              () {},
              trailing:
                  const Text('1.0.0', style: TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
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
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
