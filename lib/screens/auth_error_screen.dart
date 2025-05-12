

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../errors/failures.dart';
import '../widgets/redirect_text_button.dart';

class AuthErrorScreen extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AuthErrorScreen({
    super.key,
    required this.failure,
    this.onRetry,
  });

  IconData _getErrorIcon() {
    if (failure is AuthFailure) {
      return Icons.lock_outline;
    } else if (failure is UserNotFoundFailure) {
      return Icons.person_outline;
    } else if (failure is NetworkFailure) {
      return Icons.wifi_off;
    } else {
      return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getErrorIcon(),
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                failure.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              RedirectTextButton(
                function:
                    () =>
                    context.read<AuthBloc>().add(OnNavigateToLoginEvent()),
                text: "Volver a intentarlo",
              ),
            ],
          ),
        ),
      );
  }
}
