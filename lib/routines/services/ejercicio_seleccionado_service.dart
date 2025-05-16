import 'package:flutter/cupertino.dart';

import '../models/exercise.dart';

class EjercicioSeleccionadoService {
  final Exercise ejercicio;
  final TextEditingController seriesController = TextEditingController();
  final TextEditingController repeticionesController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();

  EjercicioSeleccionadoService(this.ejercicio);
}
