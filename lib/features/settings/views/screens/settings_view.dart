import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ate_project/core/services/auth_service.dart';
import 'package:ate_project/core/theme/app_theme.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

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
