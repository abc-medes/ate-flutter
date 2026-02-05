import 'package:bodido/common_libs.dart';
import 'package:bodido/core/config/env.dart';
import 'package:bodido/core/services/app_logic.dart';
import 'package:bodido/core/services/health_permission_service.dart';
import 'package:bodido/l10n/app_localizations.dart';
import 'package:bodido/l10n/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Env.load();

  registerSingletons();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
      autoRefreshToken: true,
    ),
  );

  await Firebase.initializeApp();

  await appLogic.bootstrap();

  runApp(ProviderScope(child: Bodido()));
}

class Bodido extends ConsumerStatefulWidget {
  const Bodido({super.key});

  @override
  ConsumerState<Bodido> createState() => _BodidoState();
}

class _BodidoState extends ConsumerState<Bodido> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(lifecycleProvider);
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
  GetIt.I.registerSingleton<HealthPermissionService>(HealthPermissionService());
}

// AppLogic get appLogic => GetIt.I.get<AppLogic>();
AppLogic get appLogic => GetIt.I.get<AppLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();
HealthPermissionService get healthPermissionService =>
    GetIt.I.get<HealthPermissionService>();

AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => AppScaffold.style;
