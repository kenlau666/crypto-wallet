import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {

  static ThemeData getTheme({bool isDarkMode = false}) {
    return isDarkMode ? FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: Color(0xff09bdc9),
        primaryContainer: Color(0x0006528b),
        secondary: Color(0xffac3306),
        secondaryContainer: Color(0xffffdbcf),
        tertiary: Color(0xff006875),
        tertiaryContainer: Color(0xff95f0ff),
        appBarColor: Color(0x00101113),
        error: Color(0xffb00020),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      // To use the playground font, add GoogleFonts package and uncomment
      fontFamily: GoogleFonts
          .poppins()
          .fontFamily,
    ) :
    FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primaryContainer: Color(0xff09bdc9),
        primary: Color(0xff09bdc9),
        secondary: Color(0xffffb59d),
        secondaryContainer: Color(0xff872100),
        tertiary: Color(0xff86d2e1),
        tertiaryContainer: Color(0xff004e59),
        appBarColor: Color(0xff872100),
        error: Color(0xffcf6679),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useM2StyleDividerInM3: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      // To use the Playground font, add GoogleFonts package and uncomment
      fontFamily: GoogleFonts
          .poppins()
          .fontFamily,
    );
  }}

// inputDecorationTheme: InputDecorationTheme(
//
// )
// }
//   daxTheme._();
//   const static ThemeData _schemeLight = FlexThemeData.light(
//   colors: const FlexSchemeColor(
//     primary: Color(0xff09bdc9),
//     primaryContainer: Color(0xffd0e4ff),
//     secondary: Color(0xffac3306),
//     secondaryContainer: Color(0xffffdbcf),
//     tertiary: Color(0xff006875),
//     tertiaryContainer: Color(0xff95f0ff),
//     appBarColor: Color(0xffffdbcf),
//     error: Color(0xffb00020),
//   ),
//   surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
//   blendLevel: 7,
//   subThemesData: const FlexSubThemesData(
//     blendOnLevel: 10,
//     blendOnColors: false,
//     useM2StyleDividerInM3: true,
//   ),
//   visualDensity: FlexColorScheme.comfortablePlatformDensity,
//   useMaterial3: true,
//   swapLegacyOnMaterial3: true,
//   // To use the playground font, add GoogleFonts package and uncomment
//   fontFamily: GoogleFonts
//       .poppins()
//       .fontFamily,
// );
//
// final ThemeData _schemeDark = FlexThemeData.dark(
//   colors: const FlexSchemeColor(
//     primary: Color(0xff09bdc9),
//     primaryContainer: Color(0xff00325b),
//     secondary: Color(0xffffb59d),
//     secondaryContainer: Color(0xff872100),
//     tertiary: Color(0xff86d2e1),
//     tertiaryContainer: Color(0xff004e59),
//     appBarColor: Color(0xff872100),
//     error: Color(0xffcf6679),
//   ),
//   surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
//   blendLevel: 13,
//   subThemesData: const FlexSubThemesData(
//     blendOnLevel: 20,
//     useM2StyleDividerInM3: true,
//   ),
//   visualDensity: FlexColorScheme.comfortablePlatformDensity,
//   useMaterial3: true,
//   swapLegacyOnMaterial3: true,
//   // To use the Playground font, add GoogleFonts package and uncomment
//   fontFamily: GoogleFonts
//       .poppins()
//       .fontFamily,
// );}