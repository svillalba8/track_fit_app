import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RootListener extends StatefulWidget {
  final Widget child;
  const RootListener({required this.child, Key? key}) : super(key: key);
  @override
  _RootListenerState createState() => _RootListenerState();
}

class _RootListenerState extends State<RootListener> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (event == AuthChangeEvent.signedOut) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
