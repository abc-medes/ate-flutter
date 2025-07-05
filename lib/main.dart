import 'package:regene/common_libs.dart';
import 'package:regene/core/services/app_logic.dart';
import 'package:regene/core/services/deep_link_logic.dart';
import 'package:regene/l10n/l10n.dart';
import 'package:regene/core/config/env.dart';
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

  runApp(ProviderScope(child: regene()));
}

class regene extends ConsumerStatefulWidget {
  const regene({super.key});

  @override
  ConsumerState<regene> createState() => _regeneState();
}

class _regeneState extends ConsumerState<regene> {
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
