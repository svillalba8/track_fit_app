import 'package:track_fit_app/core/constants.dart';

enum LogoType {
  blancoMorado,
  blancoNegro,
  cremaAzulMarino,
  cremaRosa,
  rosaNegro,
  blancoSinFondo, // SOLO VISUAL (No para los temas)
  blancoSinFondoSinletras, // SOLO VISUAL (No para los temas)
}

extension LogoDisplay on LogoType {
  String get displayName {
    switch (this) {
      case LogoType.blancoMorado:
        return 'Blanco y Morado';
      case LogoType.blancoNegro:
        return 'Blanco y Negro';
      case LogoType.cremaAzulMarino:
        return 'Crema y Azul Marino';
      case LogoType.cremaRosa:
        return 'Crema y Rosa';
      case LogoType.rosaNegro:
        return 'Rosa y Negro';
      default:
        return name;
    }
  }
}

extension LogoAsset on LogoType {
  String get assetPath {
    switch (this) {
      case LogoType.blancoMorado:
        return kLogoTrackFitBlancoMorado;
      case LogoType.blancoNegro:
        return kLogoTrackFitBlancoNegro;
      case LogoType.cremaAzulMarino:
        return kLogoTrackFitCremaAzulMarino;
      case LogoType.cremaRosa:
        return kLogoTrackFitCremaRosa;
      case LogoType.rosaNegro:
        return kLogoTrackFitRosaNegro;
      case LogoType.blancoSinFondo:
        return kLogoTrackFitBlancoSinFondo;
      case LogoType.blancoSinFondoSinletras:
        return kLogoTrackFitBlancoSinFondoSinLetras;
    }
  }

  bool get isTheme {
    switch (this) {
      case LogoType.blancoSinFondo:
      case LogoType.blancoSinFondoSinletras:
        return false;
      default:
        return true;
    }
  }
}
