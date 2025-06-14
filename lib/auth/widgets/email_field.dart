import 'package:flutter/material.dart';

/// Campo de texto estilizado para introducir el email
class EmailField extends StatelessWidget {
  // Controlador para el texto del campo
  final TextEditingController _emailController;
  // Tema actual para colores y estilos
  final ThemeData actualTheme;

  const EmailField({
    super.key,
    required TextEditingController emailController,
    required this.actualTheme,
  }) : _emailController = emailController;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Contenedor con fondo y bordes redondeados
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary, // Color de fondo del campo
        borderRadius: BorderRadius.circular(8), // Bordes redondeados
      ),
      child: TextField(
        controller: _emailController, // Controlador del texto
        keyboardType:
            TextInputType.emailAddress, // Teclado específico para email
        decoration: InputDecoration(
          labelText: 'Email', // Etiqueta flotante
          floatingLabelStyle: TextStyle(
            color:
                actualTheme
                    .colorScheme
                    .secondary, // Color de la etiqueta al flotar
          ),
          border: InputBorder.none, // Sin borde nativo
          prefixIcon: const Icon(Icons.email), // Icono al inicio del campo
        ),
      ),
    );
  }
}
