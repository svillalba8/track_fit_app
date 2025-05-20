import 'dart:async';
import 'package:flutter/foundation.dart';

/// Convierte un [Stream] en un [Listenable].
class StreamListenable extends ChangeNotifier {
  late final StreamSubscription _sub;

  StreamListenable(Stream<dynamic> stream) {
    // Notifica inmediatamente
    notifyListeners();
    // Cada vez que el stream emita, vuelve a notificar
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
