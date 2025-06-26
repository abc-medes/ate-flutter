import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/utils/color_utils.dart';

class AppColors {
  // TODO: for temporary use, will be removed later------------------------------------------------
  // Primary Colors (ICE CREAM - Deep Green)
  static const primary =
      Color(0xFF05804C); // deep vintage green (ICE CREAM text)
  static const primaryLight =
      Color(0xFF90C3A4); // minty green (ice cream character)
  static const primaryDark = Color(0xFF2B5A3D); // darkened version for contrast

  // Secondary Colors (BORCELLE - Coral Red)
  static const secondary = Color(0xFFFF5757); // coral red (BORCELLE text)
  static const secondaryLight = Color(0xFFFFA29E); // lighter coral
  static const secondaryDark = Color(0xFFB44B44); // dark coral/red

  // Tertiary Colors (optional accent colors retained or can be themed later)
  static const tertiary = Color(0xFF1976D2);
  static const tertiaryLight = Color(0xFF63A4FF);
  static const tertiaryDark = Color(0xFF004BA0);

  // Additional UI colors
  static const bodySimulator = Color(0xFF1976D2);
  static const healthLogs = Color(0xFF388E3C);
  static const activity = Color(0xFFFF9800);
  static const nutrition = Color(0xFFE91E63);
  static const sleep = Color(0xFF673AB7);
  static const mood = Color(0xFFFFEB3B);

  // Neutral Colors
  // static const background =
  //     Color(0xFFFDF8e7); // creamy vanilla background like the image
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFF9E9E9E);
  static const divider = Color(0xFFBDBDBD);

  // Feedback Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
  static const warning = Color(0xFFFFB74D);
  static const info = Color(0xFF64B5F6);
  // TODO: for temporary use, will be removed later------------------------------------------------

  /// Common
  final Color accent1 = Color(0xFF05804C);
  final Color accent2 = Color(0xFFBEABA1);
  final Color accent3 = Color(0xFFC47642);
  final Color offWhite = Color(0xFFF8ECE5);
  final Color caption = const Color(0xFF7D7873);
  final Color body = const Color(0xFF514F4D);
  final Color greyStrong = const Color(0xFF272625);
  final Color greyMedium = const Color(0xFF9D9995);
  final Color white = Colors.white;
  // NOTE: If this color is changed, also change it in
  // - web/manifest.json
  // - web/index.html -
  final Color black = const Color(0xFF1E1B18);
  final Color background = const Color(0xFFFDF8e7);
  final Color backgroundDark = Color(0xFFF5E9C8);

  final bool isDark = false;

  Color shift(Color c, double d) =>
      ColorUtils.shiftHsl(c, d * (isDark ? -1 : 1));

  ThemeData toThemeData() {
    /// Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    TextTheme txtTheme =
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    Color txtColor = white;
    ColorScheme colorScheme = ColorScheme(
        // Map our custom theme to the Material ColorScheme
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accent1,
        primaryContainer: accent1,
        secondary: accent1,
        secondaryContainer: accent1,
        surface: offWhite,
        onSurface: txtColor,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red.shade400);

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    /// Also add on some extra properties that ColorScheme seems to miss
    var t =
        ThemeData.from(textTheme: txtTheme, colorScheme: colorScheme).copyWith(
      textSelectionTheme: TextSelectionThemeData(cursorColor: accent1),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
      ),
      highlightColor: accent1,
    );

    /// Return the themeData which MaterialApp can now use
    return t;
  }
}
