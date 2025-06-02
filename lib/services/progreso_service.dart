import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/progreso_model.dart';

class ProgresoService {
  final SupabaseClient supabase;

  ProgresoService(this.supabase);

  Future<ProgresoModel?> fetchProgresoById(int idProgreso) async {
    final response =
        await supabase
            .from('progreso')
            .select()
            .eq('id', idProgreso)
            .maybeSingle();

    if (response == null) return null;

    return ProgresoModel.fromJson(response);
  }

  Future<ProgresoModel> createProgreso({
    required double objetivoPeso,
    required double pesoInicial,
  }) async {
    final response =
        await supabase
            .from('progreso')
            .insert({
              'objetivo_peso': objetivoPeso,
              'peso_inicial': pesoInicial,
              'fecha_comienzo': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }

  Future<ProgresoModel> updateProgreso(ProgresoModel progreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({
              'objetivo_peso': progreso.objetivoPeso,
              'peso_inicial': progreso.pesoInicial,
              'peso_actual': progreso.pesoActual,
              'fecha_objetivo': progreso.fechaObjetivo?.toIso8601String(),
            })
            .eq('id', progreso.id)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }
}
