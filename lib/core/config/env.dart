import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get wsBaseUrl => dotenv.env['WS_BASE_URL'] ?? '';

  static Future<void> load() async {
    const isProd = bool.fromEnvironment('PROD', defaultValue: false);

    final envFile = isProd ? '.env_prod' : '.env';

    await dotenv.load(fileName: envFile);
  }
}
