// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// class AppColors {
//   // Primary Colors (ICE CREAM - Deep Green)
//   static const primary =
//       Color(0xFF05804C); // deep vintage green (ICE CREAM text)
//   static const primaryLight =
//       Color(0xFF90C3A4); // minty green (ice cream character)
//   static const primaryDark = Color(0xFF2B5A3D); // darkened version for contrast

//   // Secondary Colors (BORCELLE - Coral Red)
//   static const secondary = Color(0xFFFF5757); // coral red (BORCELLE text)
//   static const secondaryLight = Color(0xFFFFA29E); // lighter coral
//   static const secondaryDark = Color(0xFFB44B44); // dark coral/red

//   // Tertiary Colors (optional accent colors retained or can be themed later)
//   static const tertiary = Color(0xFF1976D2);
//   static const tertiaryLight = Color(0xFF63A4FF);
//   static const tertiaryDark = Color(0xFF004BA0);

//   // Additional UI colors
//   static const bodySimulator = Color(0xFF1976D2);
//   static const healthLogs = Color(0xFF388E3C);
//   static const activity = Color(0xFFFF9800);
//   static const nutrition = Color(0xFFE91E63);
//   static const sleep = Color(0xFF673AB7);
//   static const mood = Color(0xFFFFEB3B);

//   // Neutral Colors
//   static const background =
//       Color(0xFFFDF8e7); // creamy vanilla background like the image
//   static const surface = Color(0xFFFFFFFF);
//   static const textPrimary = Color(0xFF212121);
//   static const textSecondary = Color(0xFF757575);
//   static const textTertiary = Color(0xFF9E9E9E);
//   static const divider = Color(0xFFBDBDBD);

//   // Feedback Colors
//   static const success = Color(0xFF4CAF50);
//   static const error = Color(0xFFE57373);
//   static const warning = Color(0xFFFFB74D);
//   static const info = Color(0xFF64B5F6);
// }

// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       scaffoldBackgroundColor: AppColors.background,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.background,
//       ),
//       brightness: Brightness.light,
//       colorScheme: const ColorScheme.light(
//         primary: AppColors.primary,
//         primaryContainer: AppColors.primaryLight,
//         onPrimaryContainer: AppColors.primaryDark,
//         secondary: AppColors.secondary,
//         secondaryContainer: AppColors.secondaryLight,
//         onSecondaryContainer: AppColors.secondaryDark,
//         tertiary: AppColors.tertiary,
//         tertiaryContainer: AppColors.tertiaryLight,
//         onTertiaryContainer: AppColors.tertiaryDark,
//         surface: AppColors.surface,
//         background: AppColors.background,
//         error: AppColors.error,
//       ),

//       // Typography
//       textTheme: const TextTheme(
//         headlineMedium: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primary,
//         ),
//         headlineSmall: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primary,
//         ),
//         displayLarge: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         displaySmall: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimary,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 18,
//           color: AppColors.textPrimary,
//           fontWeight: FontWeight.w600,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 16,
//           color: AppColors.textSecondary,
//         ),
//         labelLarge: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primary,
//         ),
//         labelSmall: TextStyle(
//           fontSize: 14,
//           color: AppColors.error,
//         ),
//       ),

//       // Input Fields
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.surface,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         hintStyle: TextStyle(
//           color: AppColors.textSecondary.withOpacity(0.7),
//         ),
//       ),

//       // Buttons
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           minimumSize: const Size(double.infinity, 48),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//       ),

//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           textStyle: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),

//       // Divider
//       dividerTheme: const DividerThemeData(
//         color: AppColors.divider,
//         thickness: 1,
//         space: 1,
//       ),
//     );
//   }

//   static ThemeData get darkTheme {
//     return lightTheme.copyWith(
//       brightness: Brightness.dark,
//       colorScheme: const ColorScheme.dark(
//         primary: AppColors.primaryLight,
//         primaryContainer: AppColors.primary,
//         onPrimaryContainer: AppColors.primaryLight,
//         secondary: AppColors.secondaryLight,
//         secondaryContainer: AppColors.secondary,
//         onSecondaryContainer: AppColors.secondaryLight,
//         tertiary: AppColors.tertiaryLight,
//         tertiaryContainer: AppColors.tertiary,
//         onTertiaryContainer: AppColors.tertiaryLight,
//         surface: Color(0xFF1E1E1E),
//         background: Color(0xFF121212),
//         error: AppColors.error,
//       ),
//     );
//   }
// }
