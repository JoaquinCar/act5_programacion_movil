import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? id;
  final String pacienteId;
  final String medicoId;
  final String medicoNombre;
  final String especialidad;
  final DateTime fechaHora;
  final String motivo;
  final String estado; // 'pendiente', 'confirmada', 'cancelada', 'completada'
  final DateTime fechaCreacion;

  AppointmentModel({
    this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.medicoNombre,
    required this.especialidad,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    required this.fechaCreacion,
  });

  // Convertir de Firestore a AppointmentModel
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      pacienteId: data['paciente_id'] ?? '',
      medicoId: data['medico_id'] ?? '',
      medicoNombre: data['medico_nombre'] ?? '',
      especialidad: data['especialidad'] ?? '',
      fechaHora: (data['fecha_hora'] as Timestamp).toDate(),
      motivo: data['motivo'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      fechaCreacion: (data['fecha_creacion'] as Timestamp).toDate(),
    );
  }

  // Convertir AppointmentModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'medico_nombre': medicoNombre,
      'especialidad': especialidad,
      'fecha_hora': Timestamp.fromDate(fechaHora),
      'motivo': motivo,
      'estado': estado,
      'fecha_creacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}
