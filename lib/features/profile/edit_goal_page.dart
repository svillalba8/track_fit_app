import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/models/progreso_model.dart';

class EditGoalPage extends StatefulWidget {
  final ProgresoModel? progreso;

  const EditGoalPage({super.key, this.progreso});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  late TextEditingController objetivoController;

  @override
  void initState() {
    super.initState();
    objetivoController = TextEditingController(
      text: widget.progreso?.objetivoPeso.toString() ?? '',
    );
  }

  @override
  void dispose() {
    objetivoController.dispose();
    super.dispose();
  }

  void _save() {
    final objetivo = double.tryParse(objetivoController.text);
    if (objetivo == null) {
      showErrorSnackBar(context, 'Introduce un objetivo válido');
      return;
    }

    context.pop(objetivo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.progreso == null ? 'Comenzar objetivo' : 'Editar objetivo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Introduce tu objetivo de peso (kg)'),
            ProfileField(controller: objetivoController, label: 'Objetivo'),
            TextField(
              controller: objetivoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo',
                hintText: 'Ej. 70.0',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
