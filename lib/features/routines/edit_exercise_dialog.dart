import 'package:flutter/material.dart';

import '../../core/enums/exercise_type.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

class EditExerciseDialog extends StatefulWidget {
  final Exercise ejercicio;

  const EditExerciseDialog({Key? key, required this.ejercicio}) : super(key: key);

  @override
  State<EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<EditExerciseDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late ExerciseType _selectedType;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.ejercicio.nombre);
    _descripcionController = TextEditingController(text: widget.ejercicio.descripcion ?? '');
    _selectedType = widget.ejercicio.tipo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Ejercicio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          DropdownButton<ExerciseType>(
            value: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            items: ExerciseType.values.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo.name),
              );
            }).toList(),
          ),
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ExerciseService().updateExercise(
              widget.ejercicio.id,
              _nombreController.text,
              _selectedType,
              _descripcionController.text,
            );
            Navigator.pop(context, true); // Devuelve true indicando que hubo cambio
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
