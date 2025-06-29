import 'package:bodiapp/common_libs.dart';
import 'package:bodiapp/core/services/app_logic.dart';
import 'package:bodiapp/core/services/deep_link_logic.dart';
import 'package:bodiapp/l10n/l10n.dart';
import 'package:bodiapp/core/config/env.dart';
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

  runApp(ProviderScope(child: BodiApp()));
}

class BodiApp extends ConsumerStatefulWidget {
  const BodiApp({super.key});

  @override
  ConsumerState<BodiApp> createState() => _BodiAppState();
}

class _BodiAppState extends ConsumerState<BodiApp> {
  @override
  void initState() {
    super.initState();
    GetIt.I.get<DeepLinkLogic>().init(context);
  }

  @override
  void dispose() {
    GetIt.I.get<DeepLinkLogic>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
  GetIt.I.registerSingleton<DeepLinkLogic>(DeepLinkLogic());
}

// AppLogic get appLogic => GetIt.I.get<AppLogic>();
AppLogic get appLogic => GetIt.I.get<AppLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();

AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => AppScaffold.style;
