// lib/core/utils/auth_flow_utils.dart
import 'package:bodai/common_libs.dart';
import 'package:bodai/core/routes/route_names.dart';
import 'package:bodai/core/services/user_service.dart';

Future<void> socialSignInAndFinalize(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() signInMethod,
) async {
  await signInMethod();
  await finalizeAfterOAuth(context, ref);
}

Future<void> finalizeAfterOAuth(BuildContext context, WidgetRef ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final userService = ref.read(userServiceProvider);

  try {
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      final email = user.email ?? '';
      final meta = user.userMetadata ?? {};
      final name = (meta['name'] ??
              meta['full_name'] ??
              meta['preferred_username'] ??
              (email.isNotEmpty ? email.split('@').first : ''))
          .toString();

      await userService.createProfile(
        userId: user.id,
        email: email,
        name: name,
      );
      await userService.createEmptyUserHealthMetrics(user.id);

      if (context.mounted) context.go(RouteNames.onboarding);
    } else {
      if (context.mounted) context.go(RouteNames.home);
    }
  } catch (_) {
    if (context.mounted) context.go(RouteNames.onboarding);
  }
}
