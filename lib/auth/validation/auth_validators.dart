class AuthValidators {
  // Comprueba formato de email y no vacío.
  static String? emailValidator(String? emailIntroducido) {
    if (emailIntroducido == null || emailIntroducido.isEmpty) return 'El email es obligatorio';
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!re.hasMatch(emailIntroducido.trim())) return 'Introduce un email válido';
    return null;
  }

  // Verifica que la contraseña exista y mida ≥6.
  static String? passwordValidator(String? claveIntroducida) {
    if (claveIntroducida == null || claveIntroducida.isEmpty) return 'La contraseña es obligatoria';
    if (claveIntroducida.length < 6) return 'Mínimo 6 caracteres';

    // Al menos un dígito
    if (!RegExp(r'\d').hasMatch(claveIntroducida)) return 'Debe contener al menos un número';
    
    // Al menos un carácter especial
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(claveIntroducida)) return 'Debe contener al menos un carácter especial';
    return null;
  }

  // Asegura que ambas contraseñas coincidan.
  static String? confirmPasswordValidator(String? password2Validator, String originalPassword) {
    if (password2Validator != originalPassword) return 'Las contraseñas no coinciden';
    return null;
  }
}
