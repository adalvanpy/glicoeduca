import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String avatar;
  final String sex;
  final String email;
  final String? password; 
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.sex = '',
    this.email = '',
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      sex: map['sex'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'sex': sex,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // 🔥 CÓPIA COM DADOS ATUALIZADOS
  UserModel copyWith({
    String? name,
    String? avatar,
    String? sex,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      sex: sex ?? this.sex,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // 🔥 PARA EXIBIÇÃO SEM A SENHA
  Map<String, dynamic> toPublicMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'sex': sex,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
