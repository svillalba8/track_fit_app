// RUTAS PANTALLAS DE LA APLICACIÓN
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const routines = '/routines';
  static const trainer = '/trainer';
  static const profile = '/profile';
  static const goal = '/profile/edit-goal';
  static const settings = '/profile/settings';
  static const editUser = '/profile/settings/edit-user';
  static const themeSelector = '/profile/settings/theme';
}

// ICONOS / LOGO APLICACION
const String kLogoTrackFitBlancoMorado =
    'assets/logos/TrackFit_blanco_morado.png';
const String kLogoTrackFitBlancoNegro =
    'assets/logos/TrackFit_blanco_negro.png';
const String kLogoTrackFitCremaAzulMarino =
    'assets/logos/TrackFit_crema_azulmarino.png';
const String kLogoTrackFitCremaRosa = 'assets/logos/TrackFit_crema_rosa.png';
const String kLogoTrackFitRosaNegro = 'assets/logos/TrackFit_rosa_negro.png';
const String kLogoTrackFitBlancoSinFondo =
    'assets/logos/TrackFit_blanco_sin_fondo.png';
const String kLogoTrackFitBlancoSinFondoSinLetras =
    'assets/logos/TrackFit_blanco_sin_fondo_sin_letra.png';

// RANGOS MINIMOS Y MAXIMOS PARA AUTH
const double kPesoMinimo = 42;
const double kPesoMaximo = 200;
const double kAlturaMinima = 145;
const double kAlturaMaxima = 220;
const int kCaracteresMaximosDescripcion = 150;

/// Géneros de usuario (Para introducción a base de datos RECORDAR en mayusculas)
const String kGeneroHombre = 'Hombre';
const String kGeneroMujer = 'Mujer';
const String kGeneroHombreMayus = 'HOMBRE'; // EN BBDD -> 'HOMBRE'
const String kGeneroMujerMayus = 'MUJER'; // EN BBDD -> 'MUJER'

// IMAGENES / AVATARES DEL ENTRENADOR PERSONAL
const String kAvatarEntrenadorPersonal = 'assets/images/avatar_lift.png';
