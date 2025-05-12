import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class Usuario {
  final String authUserId;
  final String mail;
  final String name;
  final String surnames;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String userName;
  final String status;
  final int? idProgress;
  final String description;
  final int? id;

  Usuario({
    this.id,
    required this.authUserId,
    required this.mail,
    required this.name,
    required this.surnames,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.userName,
    required this.status,
    this.idProgress,
    required this.description,
  });

  factory Usuario.fromAuthUser(supabase.User authUser) {
    return Usuario(
      authUserId: authUser.id,
      mail: authUser.email ?? '',
      name: '',
      surnames: '',
      age: 0,
      weight: 0.0,
      height: 0.0,
      gender: '',
      userName: '',
      status: 'active',
      idProgress: null,
      description: '',
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      authUserId: json['auth_user_id'] as String,
      mail: json['mail'] as String,
      name: json['name'] as String,
      surnames: json['surnames'] as String,
      age: json['age'] as int,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      gender: json['gender'] as String,
      userName: json['user_name'] as String,
      status: json['status'] as String,
      idProgress: json['id_progress'] as int?,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'auth_user_id': authUserId,
    'mail': mail,
    'name': name,
    'surnames': surnames,
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'user_name': userName,
    'status': status,
    'id_progress': idProgress,
    'description': description,
  };
}