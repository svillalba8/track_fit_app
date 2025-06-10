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
    required DateTime? fechaObjetivo,
  }) async {
    final nowIso = DateTime.now().toIso8601String();

    final progResponse =
        await supabase
            .from('progreso')
            .insert({
              'objetivo_peso': objetivoPeso,
              'peso_inicial': pesoInicial,
              'fecha_comienzo': nowIso,
              'fecha_objetivo': fechaObjetivo?.toIso8601String(),
            })
            .select()
            .single();

    final nuevoProgreso = ProgresoModel.fromJson(progResponse);

    final authUser = supabase.auth.currentUser;
    if (authUser != null) {
      await supabase
          .from('usuarios')
          .update({'id_progreso': nuevoProgreso.id})
          .eq('auth_user_id', authUser.id);
    }

    return nuevoProgreso;
  }

  Future<ProgresoModel> updateProgreso(ProgresoModel progreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({
              'objetivo_peso': progreso.objetivoPeso,
              'peso_inicial': progreso.pesoInicial,
              'fecha_objetivo': progreso.fechaObjetivo?.toIso8601String(),
            })
            .eq('id', progreso.id)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }

  Future<ProgresoModel> cancelarObjetivo(int idProgreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({'objetivo_peso': null, 'fecha_objetivo': null})
            .eq('id', idProgreso)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }
}
