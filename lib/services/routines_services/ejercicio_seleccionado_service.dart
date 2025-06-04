import 'package:flutter/material.dart';
import '../../models/routines_models/exercise_model.dart';

class EjercicioSeleccionadoService {
  final Exercise ejercicio;
  final TextEditingController seriesController = TextEditingController();
  final TextEditingController repeticionesController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();

  EjercicioSeleccionadoService(this.ejercicio);
}
