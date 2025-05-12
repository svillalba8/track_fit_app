import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../models/usuario.dart';
import '../use_cases/cerrar_sesion_usecase.dart';
import '../use_cases/get_current_user_usecase.dart';
import '../use_cases/login_usecase.dart';
import '../use_cases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CerrarSesionUseCase _cerrarSesionUseCase;

  AuthBloc(
      this._registerUseCase,
      this._loginUseCase,
      this._getCurrentUserUseCase,
      this._cerrarSesionUseCase,
      ) : super(AuthInitial()) {
    on<OnRegisterEvent>(_onRegister);
    on<OnLoginEvent>(_onLogin);
    on<OnCheckUserLoginEvent>(_onCheckUserLogin);
    on<OnCerrarSesionEvent>(_onCerrarSesion);
    on<OnNavigateToRegisterEvent>((event, emit) => emit(AuthRegister()));
    on<OnNavigateToLoginEvent>((event, emit) => emit(AuthInitial()));
  }

  Future<void> _onRegister(OnRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _registerUseCase(
      email: event.email,
      password: event.password,
      name: event.name,
      surnames: event.surnames,
      age: event.age,
      weight: event.weight,
      height: event.height,
      gender: event.gender,
      userName: event.userName,
      status: event.status,
      description: event.description,
    );

    result.fold(
          (failure) => emit(AuthError(failure: failure)),
          (_) => emit(AuthSuccessRegister()),
    );
  }

  Future<void> _onLogin(OnLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _loginUseCase(event.email, event.password);

    result.fold(
          (f) {
        emit(AuthError(failure: f));
      },
          (u) {
        emit(AuthSuccessLogin(user: u));
      },
    );


  }

  Future<void> _onCheckUserLogin(OnCheckUserLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final usuario = await _getCurrentUserUseCase();
      if (usuario != null) {
        emit(AuthSuccessLogin(user: usuario));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(failure: ServerFailure()));
    }
  }

  Future<void> _onCerrarSesion(OnCerrarSesionEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _cerrarSesionUseCase();

    result.fold<void>(
          (failure) => emit(AuthError(failure: failure)),
          (_) => emit(AuthInitial()),
    );
  }

}
