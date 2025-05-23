import 'package:flutter/material.dart';
import 'logo_type.dart';

class AppThemes {
  static ThemeData themeForLogo(LogoType logo) {
    switch (logo) {
      case LogoType.blancoMorado:
        // Colores del logo blancoMorado
        const Color indigoDark = Color(0xFF272454); // #272454
        const Color indigoDarker = Color(0xFF292759); // #292759
        const Color lavenderGray = Color(0xFF5B53C5); // #AFAEBF
        const Color offWhite = Color(0xFFF2F2F2); // #F2F2F2
        const Color purpleGray = Color(0xFF4A496E) ; // #545373
        const Color purpleBirght = Color(0xFF5065E0) ; // #545373

        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: indigoDark,
          scaffoldBackgroundColor: indigoDark,
          appBarTheme: const AppBarTheme(
            backgroundColor: indigoDark,
            iconTheme: IconThemeData(color: offWhite),
            titleTextStyle: TextStyle(color: offWhite),
          ),
          colorScheme: const ColorScheme.dark(
            primary: indigoDark,
            onPrimary: offWhite,
            secondary: offWhite,
            onSecondary: offWhite,
            tertiary: purpleGray,
            onTertiary: purpleBirght,
            primaryFixed: lavenderGray,
            surface: indigoDarker,
            onSurface: offWhite,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: Typography.whiteMountainView.apply(
            bodyColor: offWhite,
            displayColor: offWhite,
          ),
        );

      case LogoType.blancoNegro:
        // Colores del logo blancoNegro
        const Color blackBg = Color(0xFF151412); // #151412
        const Color offWhite = Color(0xFFF2F0EB); // #F2F0EB
        // const Color grayAccent = Color(0xFF73726F); // #73726F
        const Color darkSurface = Color(0xFF403F3D); // #403F3D

        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: blackBg,
          scaffoldBackgroundColor: blackBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: blackBg,
            iconTheme: IconThemeData(color: offWhite),
            titleTextStyle: TextStyle(color: offWhite),
          ),
          colorScheme: const ColorScheme.dark(
            primary: blackBg,
            onPrimary: offWhite,
            secondary: offWhite,
            onSecondary: offWhite,
            tertiary: darkSurface,
            onTertiary: darkSurface,
            primaryFixed: blackBg,
            surface: darkSurface,
            onSurface: offWhite,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: Typography.whiteMountainView.apply(
            bodyColor: offWhite,
            displayColor: offWhite,
          ),
        );

      case LogoType.cremaAzulMarino:
        // Colores del logo cremaAzulMarino
        const Color cream = Color(0xFFD9B79A); // #D9B79A
        const Color tealDark = Color(0xFF022932); // #022932
        const Color teal = Color(0xFF0C3B40); // #0C3B40
        const Color tealbright = Color.fromARGB(255, 12, 64, 70);
        // const Color sand = Color(0xFFF2CEAE); // #F2CEAE
        const Color bronze = Color.fromARGB(255, 141, 110, 82); // #A68568

        return ThemeData(
          brightness: Brightness.light,
          primaryColor: tealDark,
          scaffoldBackgroundColor: cream, // Elegir entre tealDark o cream
          appBarTheme: const AppBarTheme(
            backgroundColor: tealDark,
            iconTheme: IconThemeData(color: cream),
            titleTextStyle: TextStyle(color: cream),
          ),
          colorScheme: const ColorScheme.light(
            primary: tealDark,
            onPrimary: cream,
            secondary: cream,
            onSecondary: cream,
            tertiary: bronze,
            onTertiary: tealbright,
            primaryFixed: tealDark,
            surface: teal,
            onSurface: cream,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: Typography.blackMountainView.apply(
            bodyColor: cream,
            displayColor: tealDark,
          ),
        );

      case LogoType.cremaRosa:
        // Colores del logo cremaRosa
        const Color creamCr = Color(0xFFF2E8C9); // #F2E8C9 (fondo claro crema)
        const Color pinkLight = Color(0xFFD99A9F); // #D99A9F
        // const Color pink = Color(0xFFD98299); // #D98299
        const Color fuchsia = Color(0xFFC55474); // #C55474
        // const Color roseBeige = Color(0xFFD9B6A9);    // #D9B6A9

        return ThemeData(
          brightness: Brightness.light,
          primaryColor: pinkLight,
          scaffoldBackgroundColor: pinkLight,
          appBarTheme: const AppBarTheme(
            backgroundColor: pinkLight,
            iconTheme: IconThemeData(color: creamCr),
            titleTextStyle: TextStyle(color: creamCr),
          ),
          colorScheme: const ColorScheme.light(
            primary: fuchsia,
            onPrimary: creamCr,
            secondary: creamCr,
            onSecondary: creamCr,
            tertiary: pinkLight,
            onTertiary: pinkLight,
            primaryFixed: fuchsia,
            surface: fuchsia,
            onSurface: creamCr,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: Typography.blackMountainView.apply(
            bodyColor: creamCr,
            displayColor: pinkLight,
          ),
        );

      case LogoType.rosaNegro:
        // Colores del logo rosaNegro
        const Color roseBg = Color(0xFFF2D0E9); // #F2D0E9
        // const Color roseBgBright = Color.fromARGB(255, 248, 222, 241); // #F2D0E9
        // const Color roseMuted = Color(0xFFD9BAD1);    // #D9BAD1
        // const Color mauve = Color(0xFFA692A0); // #A692A0
        const Color lightPinkCharcoal = Color.fromARGB(255, 131, 119, 129); // #594F57
        const Color black = Color(0xFF252425); // #252425

        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: roseBg,
          scaffoldBackgroundColor: black,
          appBarTheme: const AppBarTheme(
            backgroundColor: black,
            iconTheme: IconThemeData(color: roseBg),
            titleTextStyle: TextStyle(color: roseBg),
          ),
          colorScheme: const ColorScheme.dark(
            primary: black,
            onPrimary: lightPinkCharcoal,
            secondary: roseBg,
            onSecondary: lightPinkCharcoal,
            tertiary: lightPinkCharcoal,
            onTertiary: lightPinkCharcoal,
            primaryFixed: black,
            surface: black,
            onSurface: roseBg,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: Typography.whiteMountainView.apply(
            bodyColor: roseBg,
            displayColor: lightPinkCharcoal,
          ),
        );
      case LogoType.blancoSinFondo:
        throw UnimplementedError();
      case LogoType.blancoSinFondoSinletras:
        throw UnimplementedError();
    }
  }
}
