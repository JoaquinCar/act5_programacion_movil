import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAvailabilityModel {
  final String? id;
  final String medicoId;
  final String medicoNombre;
  final String especialidad;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final bool estaDisponible;

  DoctorAvailabilityModel({
    this.id,
    required this.medicoId,
    required this.medicoNombre,
    required this.especialidad,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estaDisponible,
  });

  // Convertir de Firestore a DoctorAvailabilityModel
  factory DoctorAvailabilityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DoctorAvailabilityModel(
      id: doc.id,
      medicoId: data['medico_id'] ?? '',
      medicoNombre: data['medico_nombre'] ?? '',
      especialidad: data['especialidad'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      horaInicio: data['hora_inicio'] ?? '',
      horaFin: data['hora_fin'] ?? '',
      estaDisponible: data['esta_disponible'] ?? true,
    );
  }

  // Convertir DoctorAvailabilityModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'medico_id': medicoId,
      'medico_nombre': medicoNombre,
      'especialidad': especialidad,
      'fecha': Timestamp.fromDate(fecha),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'esta_disponible': estaDisponible,
    };
  }
}
