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
  static const goal = '/goal-page';
  static const editUser = 'edit-user';
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
const String kavatarEntrenadorPersonal1 = 'assets/images/entrenador_personal.jpg';
const String kavatarEntrenadorPersonal2 = 'assets/images/entrenador_personal_2.jpg';
const String kavatarEntrenadoraPersonal1 = 'assets/images/entrenadora_personal.jpg';
const String kavatarEntrenadoraPersonal2 = 'assets/images/entrenadora_personal_2.jpg';
