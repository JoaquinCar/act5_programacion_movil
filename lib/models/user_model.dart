import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final int edad;
  final String lugarNacimiento;
  final String padecimientos;
  final String? telefono;
  final DateTime fechaRegistro;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.edad,
    required this.lugarNacimiento,
    required this.padecimientos,
    this.telefono,
    required this.fechaRegistro,
  });

  // Convertir de Firestore a UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      edad: data['edad'] ?? 0,
      lugarNacimiento: data['lugar_nacimiento'] ?? '',
      padecimientos: data['padecimientos'] ?? '',
      telefono: data['telefono'],
      fechaRegistro: (data['fecha_registro'] as Timestamp).toDate(),
    );
  }

  // Convertir UserModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'edad': edad,
      'lugar_nacimiento': lugarNacimiento,
      'padecimientos': padecimientos,
      'telefono': telefono,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
    };
  }
}
