import 'package:regene/common_libs.dart';
import 'package:regene/core/services/app_lifecycle.dart';
import 'package:regene/core/services/app_logic.dart';
import 'package:regene/core/services/deep_link_logic.dart';
import 'package:regene/core/services/user_service.dart';
import 'package:regene/l10n/l10n.dart';
import 'package:regene/core/config/env.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Env.load();

  registerSingletons();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await appLogic.bootstrap();

  runApp(ProviderScope(child: Regene()));
}

class Regene extends ConsumerStatefulWidget {
  const Regene({super.key});

  @override
  ConsumerState<Regene> createState() => _RegeneState();
}

class _RegeneState extends ConsumerState<Regene> {
  late final LifecycleLogic _lifecycle;

  @override
  void initState() {
    super.initState();
    GetIt.I.get<DeepLinkLogic>().init(context);
    _lifecycle = LifecycleLogic(ref.read(userServiceProvider), ref);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    GetIt.I.get<DeepLinkLogic>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
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
