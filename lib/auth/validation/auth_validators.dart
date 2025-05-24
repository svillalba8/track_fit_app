import 'package:track_fit_app/core/constants.dart';

class AuthValidators {
  // Comprueba formato de email y no vacío.
  static String? emailValidator(String? emailIntroducido) {
    if (emailIntroducido == null || emailIntroducido.isEmpty) {
      return 'El email es obligatorio';
    }
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!re.hasMatch(emailIntroducido.trim())) {
      return 'Introduce un email válido';
    }
    return null;
  }

  // Verifica que la contraseña exista y mida ≥6.
  static String? passwordValidator(String? passwordEntered) {
    if (passwordEntered == null || passwordEntered.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (passwordEntered.length < 6) return 'Mínimo 6 caracteres';

    // Al menos un dígito
    if (!RegExp(r'\d').hasMatch(passwordEntered)) {
      return 'Debe contener al menos un número';
    }

    // Al menos un carácter especial
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(passwordEntered)) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  // Asegura que ambas contraseñas coincidan.
  static String? confirmPasswordValidator(
    String? password2Entered,
    String originalPassword,
  ) {
    if (password2Entered != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Nombre de usuario: obligatorio, 6–15 chars, sólo letras, números y guión bajo
  static String? usernameValidator(String? nameEntered) {
    if (nameEntered == null || nameEntered.trim().isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    final name = nameEntered.trim();
    if (name.length < 6) return 'Mínimo 6 caracteres';
    if (name.length > 15) return 'Máximo 15 caracteres';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      return 'Sólo letras, números y _';
    }
    return null;
  }

  /// Nombre: obligatorio, sólo letras y espacios
  static String? nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$').hasMatch(v.trim())) {
      return 'Sólo se permiten letras y espacios';
    }
    return null;
  }

  /// Apellidos: obligatorio, sólo letras y espacios
  static String? lastnameValidator(String? surnameEntered) {
    if (surnameEntered == null || surnameEntered.trim().isEmpty) {
      return 'Los apellidos son obligatorios';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$').hasMatch(surnameEntered.trim())) {
      return 'Sólo se permiten letras y espacios';
    }
    return null;
  }

  /// Peso (kg): obligatorio, númerico.
  static String? weightValidator(String? weightEntered) {
    if (weightEntered == null || weightEntered.trim().isEmpty) {
      return 'El peso es obligatorio';
    }
    final weight = double.tryParse(weightEntered.trim());
    if (weight == null) return 'Introduce un peso válido';
    if (weight <= kPesoMinimo) return 'El peso debe ser mayor que $kPesoMinimo';
    if (weight > kPesoMaximo) {
      return 'Cuidado el peso no puede ser mayor de $kPesoMaximo';
    }
    return null;
  }

  /// Estatura (cm): obligatorio, numérico
  static String? heightValidator(String? heightEntered) {
    if (heightEntered == null || heightEntered.trim().isEmpty) {
      return 'La estatura es obligatoria';
    }
    final height = double.tryParse(heightEntered.trim());
    if (height == null) return 'Introduce una estatura válida';
    if (height <= kAlturaMinima) {
      return 'La estatura debe ser mayor que $kAlturaMinima';
    }
    if (height > kAlturaMaxima) {
      return 'Cuidado la altura no puede ser mayor de $kAlturaMaxima';
    }
    return null;
  }

  /// Género: obligatorio (constantes -> “Hombre” o “Mujer”)
  static String? genderValidator(String? selectedGender) {
    if (selectedGender == null || selectedGender.isEmpty) {
      return 'Selecciona un género';
    }
    return null;
  }

  /// Descripción: opcional, pero tope de 150 caracteres
  static String? descriptionValidator(String? descriptionEntered) {
    if (descriptionEntered != null &&
        descriptionEntered.trim().length > kCaracteresMaximosDescripcion) {
      return 'Máximo $kCaracteresMaximosDescripcion caracteres';
    }
    return null;
  }

  /// Fecha de nacimiento: obligatoria, no en el futuro, edad entre 13 y 120 años
  static String? birthDateValidator(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Selecciona tu fecha de nacimiento.';
    }
    final today = DateTime.now();
    if (birthDate.isAfter(today)) {
      return 'La fecha no puede ser en el futuro.';
    }
    final age =
        today.year -
        birthDate.year -
        ((today.month < birthDate.month ||
                (today.month == birthDate.month && today.day < birthDate.day))
            ? 1
            : 0);
    if (age < 13) {
      return 'Debes tener al menos 13 años.';
    }
    if (age > 120) {
      return 'Introduce una fecha válida.';
    }
    return null;
  }
}
