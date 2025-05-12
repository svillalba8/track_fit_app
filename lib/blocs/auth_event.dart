part of 'auth_bloc.dart';

abstract class AuthEvent {}

class OnRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String surnames;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String userName;
  final String status;
  final String description;

  OnRegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.surnames,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.userName,
    required this.status,
    required this.description,
  });
}

class OnLoginEvent extends AuthEvent {
  final String email;
  final String password;

  OnLoginEvent({required this.email, required this.password});
}

class OnCheckUserLoginEvent extends AuthEvent {}

class OnCerrarSesionEvent extends AuthEvent {}

class OnNavigateToRegisterEvent extends AuthEvent {}

class OnNavigateToLoginEvent extends AuthEvent {}
