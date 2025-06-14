import 'package:flutter/material.dart';

import '../models/exercise_model.dart';

/// Servicio que encapsula el ejercicio seleccionado junto con los controladores
/// de texto para series, repeticiones y duración.
/// Se utiliza para mantener el estado de entrada de parámetros cuando el usuario
/// añade o edita un ejercicio en una rutina.
class EjercicioSeleccionadoService {
  /// Ejercicio que se ha seleccionado para configurar.
  final Exercise ejercicio;

  /// Controlador para el número de series.
  final TextEditingController seriesController = TextEditingController();

  /// Controlador para el número de repeticiones.
  final TextEditingController repeticionesController = TextEditingController();

  /// Controlador para la duración en segundos.
  final TextEditingController duracionController = TextEditingController();

  /// Constructor que recibe el [ejercicio] seleccionado.
  /// Inicializa los controladores de texto vacíos para que el usuario
  /// introduzca series, repeticiones y duración.
  EjercicioSeleccionadoService(this.ejercicio);
}
