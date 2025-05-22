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

  Future<ProgresoModel> createProgreso(double objetivoPeso) async {
    final response =
        await supabase
            .from('progreso')
            .insert({'objetivo_peso': objetivoPeso})
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }

  Future<ProgresoModel> updateProgreso(ProgresoModel progreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({'objetivo_peso': progreso.objetivoPeso})
            .eq('id', progreso.id)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }
}
