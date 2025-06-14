import 'package:flutter/material.dart';

/// Campo de texto estilizado para contraseñas con botón de visibilidad
class PasswordField extends StatelessWidget {
  // Controlador del texto del campo
  final TextEditingController _passController;
  // Texto de la etiqueta del campo
  final String message;
  // Tema actual para colores y estilos
  final ThemeData actualTheme;
  // Callback para alternar visibilidad del texto
  final VoidCallback onToggleObscure;
  // Indica si el texto está oculto (true) o visible (false)
  final bool _obscureRepeat;

  const PasswordField({
    super.key,
    required TextEditingController passController,
    required this.message,
    required this.actualTheme,
    required this.onToggleObscure,
    required bool obscureRepeat,
  }) : _passController = passController,
      _obscureRepeat = obscureRepeat;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fondo y bordes redondeados
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _passController, // Controlador del input
        obscureText: _obscureRepeat, // Oculta el texto si es true
        decoration: InputDecoration(
          labelText: message, // Etiqueta del campo
          floatingLabelStyle: TextStyle(
            color:
                actualTheme
                    .colorScheme
                    .secondary, // Color de la etiqueta flotante
          ),
          border: InputBorder.none, // Sin borde por defecto
          prefixIcon: const Icon(Icons.lock), // Icono de candado al inicio
          suffixIcon: IconButton(
            // Icono de ojo para alternar visibilidad
            icon: Icon(
              _obscureRepeat ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onToggleObscure, // Cambia estado de ocultar/mostrar
          ),
        ),
      ),
    );
  }
}
