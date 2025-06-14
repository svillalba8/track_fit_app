import 'dart:async';

import 'package:flutter/foundation.dart';

/// Convierte un [Stream] en un [Listenable] para usar con GoRouter y otros widgets.
class StreamListenable extends ChangeNotifier {
  late final StreamSubscription _sub; // Subscription al stream

  /// Constructor:
  /// - Notifica inmediatamente a los listeners
  /// - Se suscribe al [stream], y cada vez que emite, llama a [notifyListeners]
  StreamListenable(Stream<dynamic> stream) {
    notifyListeners(); // Notificación inicial
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel(); // Cancela la suscripción al stream
    super.dispose();
  }
}
