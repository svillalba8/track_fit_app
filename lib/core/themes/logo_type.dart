import 'package:track_fit_app/core/constants.dart';

enum LogoType {
  blancoMorado,
  blancoNegro,
  cremaAzulMarino,
  cremaRosa,
  rosaNegro
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
    }
  }
}
