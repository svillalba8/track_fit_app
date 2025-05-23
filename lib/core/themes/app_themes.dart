import 'package:flutter/material.dart';
import 'package:track_fit_app/core/themes/theme_extensions.dart';
import 'logo_type.dart';

class AppThemes {
  static ThemeData themeForLogo(LogoType logo) {
    switch (logo) {
      case LogoType.blancoMorado:
        // Colores del logo blancoMorado
        const Color indigoDark = Color(0xFF272454); // #272454
        const Color indigoDarker = Color(0xFF292759); // #292759
        const Color lavenderGray = Color(0xFF4F48AD); // #AFAEBF
        const Color offWhite = Color(0xFFF2F2F2); // #F2F2F2
        const Color purpleGray = Color(0xFF4A496E); // #545373
        const Color purpleBirght = Color(0xFF586EEC); // #545373

        final baseBlancoMorado = ThemeData(
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

        return baseBlancoMorado.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const ChatBackground(
              assetPath: 'assets/backgrounds/fondo_pant_blanco_morado_2.png',
            ),
          ],
        );

      case LogoType.blancoNegro:
        // Colores del logo blancoNegro
        const Color blackBg = Color(0xFF151412); // #151412
        const Color blackSoft = Color(0xFF202020);
        const Color offWhite = Color(0xFFF2F0EB); // #F2F0EB
        // const Color grayAccent = Color(0xFF73726F); // #73726F
        const Color darkSurface = Color(0xFF403F3D); // #403F3D

        final baseBlancoNegro = ThemeData(
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
            primaryFixed: blackSoft,
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

        return baseBlancoNegro.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const ChatBackground(
              assetPath: 'assets/backgrounds/fondo_pant_blanco_negro.png',
            ),
          ],
        );

      case LogoType.cremaAzulMarino:
        // Colores del logo cremaAzulMarino
        const Color cream = Color(0xFFD9B79A); // #D9B79A
        const Color tealDark = Color(0xFF022932); // #022932
        const Color teal = Color(0xFF0C3B40); // #0C3B40
        const Color tealbright = Color(0xFF105C64);
        const Color sand = Color(0xFFF5E7DA); // #F2CEAE
        const Color bronze = Color(0xFF8D6E52); // #A68568

        final baseCremaAzulMarino = ThemeData(
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
            onSecondary: sand, // Cambiado para el chat
            tertiary: bronze,
            onTertiary: tealbright,
            primaryFixed: teal,
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

        return baseCremaAzulMarino.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const ChatBackground(
              assetPath: 'assets/backgrounds/fondo_pant_crema_azul_marino.png',
            ),
          ],
        );

      case LogoType.cremaRosa:
        // Colores del logo cremaRosa
        const Color creamCr = Color(0xFFF2E8C9); // #F2E8C9 (fondo claro crema)
        const Color pinkLight = Color(0xFFD99A9F); // #D99A9F
        const Color pink = Color(0xFFE07092); // #D98299
        const Color fuchsia = Color(0xFFC55474); // #C55474
        // const Color roseBeige = Color(0xFFD9B6A9);    // #D9B6A9

        final baseCremaRosa = ThemeData(
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
            onTertiary: pink,
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

        return baseCremaRosa.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const ChatBackground(
              assetPath: 'assets/backgrounds/fondo_pant_crema_rosa.png',
            ),
          ],
        );

      case LogoType.rosaNegro:
        // Colores del logo rosaNegro
        const Color roseBg = Color(0xFFF2D0E9); // #F2D0E9
        // const Color roseBgBright = Color.fromARGB(255, 248, 222, 241); // #F2D0E9
        // const Color roseMuted = Color(0xFFD9BAD1);    // #D9BAD1
        // const Color mauve = Color(0xFFA692A0); // #A692A0
        const Color lightPinkCharcoal = Color(0xFF837781); // #594F57
        const Color lightPinkDark = Color(0xFF312C30);
        const Color black = Color(0xFF252425); // #252425

        final baseNegroRosa = ThemeData(
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
            primaryFixed: lightPinkDark,
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

        return baseNegroRosa.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            const ChatBackground(
              assetPath: 'assets/backgrounds/fondo_pant_negro_rosa.png',
            ),
          ],
        );

      case LogoType.blancoSinFondo:
        throw UnimplementedError();
      case LogoType.blancoSinFondoSinletras:
        throw UnimplementedError();
    }
  }
}
