import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/utils/app_logic.dart';
import 'package:ate_project/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ate_project/core/config/env.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();

  registerSingletons();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await appLogic.bootstrap();

  runApp(ProviderScope(child: MomntApp()));
}

class MomntApp extends ConsumerWidget {
  const MomntApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final locale = watchX((SettingsLogic s) => s.currentLocale);
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: $styles.text.body.fontFamily, useMaterial3: true),
      color: $styles.colors.black,
      locale: Locale('en'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
    );
  }
}

void registerSingletons() {
  GetIt.I.registerSingleton<AppLogic>(AppLogic());
  GetIt.I.registerSingleton<LocaleLogic>(LocaleLogic());
  GetIt.I.registerSingleton<SettingsLogic>(SettingsLogic());
}

// AppLogic get appLogic => GetIt.I.get<AppLogic>();
AppLogic get appLogic => GetIt.I.get<AppLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();

AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => AppScaffold.style;
