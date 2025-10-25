import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_availability_model.dart';

class FirestoreInitData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializar disponibilidad de médicos desde 25 octubre hasta 10 noviembre
  Future<void> initializeDoctorAvailability() async {
    try {
      print('Iniciando creación de disponibilidad de médicos...');

      // Lista de médicos con sus especialidades
      List<Map<String, String>> doctores = [
        {'id': 'med_001', 'nombre': 'Dr. Carlos Ramírez', 'especialidad': 'Cardiología'},
        {'id': 'med_002', 'nombre': 'Dra. Ana Martínez', 'especialidad': 'Dermatología'},
        {'id': 'med_003', 'nombre': 'Dr. Luis Hernández', 'especialidad': 'Pediatría'},
        {'id': 'med_004', 'nombre': 'Dra. María López', 'especialidad': 'Oftalmología'},
        {'id': 'med_005', 'nombre': 'Dr. Jorge Sánchez', 'especialidad': 'Neurología'},
        {'id': 'med_006', 'nombre': 'Dr. Roberto Cruz', 'especialidad': 'Medicina General'},
        {'id': 'med_007', 'nombre': 'Dra. Patricia Gómez', 'especialidad': 'Ginecología'},
      ];

      // Horarios disponibles (formato 24h)
      List<Map<String, String>> horarios = [
        {'inicio': '09:00', 'fin': '10:00'},
        {'inicio': '10:00', 'fin': '11:00'},
        {'inicio': '11:00', 'fin': '12:00'},
        {'inicio': '14:00', 'fin': '15:00'},
        {'inicio': '15:00', 'fin': '16:00'},
        {'inicio': '16:00', 'fin': '17:00'},
        {'inicio': '17:00', 'fin': '18:00'},
      ];

      int slotsCreados = 0;

      // Fecha inicial: 25 de octubre de 2025
      DateTime fechaInicio = DateTime(2025, 10, 25);
      // Fecha final: 10 de noviembre de 2025
      DateTime fechaFin = DateTime(2025, 11, 10);

      // Calcular días entre las dos fechas
      int totalDias = fechaFin.difference(fechaInicio).inDays + 1;

      // Crear slots para cada día en el rango
      for (int dia = 0; dia < totalDias; dia++) {
        DateTime fecha = fechaInicio.add(Duration(days: dia));

        // Saltar fines de semana
        if (fecha.weekday == DateTime.saturday || fecha.weekday == DateTime.sunday) {
          continue;
        }

        for (var doctor in doctores) {
          for (var horario in horarios) {
            // Crear fecha y hora completa
            List<String> horaInicioParts = horario['inicio']!.split(':');
            DateTime fechaHoraInicio = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              int.parse(horaInicioParts[0]),
              int.parse(horaInicioParts[1]),
            );

            List<String> horaFinParts = horario['fin']!.split(':');
            DateTime fechaHoraFin = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              int.parse(horaFinParts[0]),
              int.parse(horaFinParts[1]),
            );

            DoctorAvailabilityModel availability = DoctorAvailabilityModel(
              medicoId: doctor['id']!,
              medicoNombre: doctor['nombre']!,
              especialidad: doctor['especialidad']!,
              fecha: fechaHoraInicio,
              horaInicio: horario['inicio']!,
              horaFin: horario['fin']!,
              estaDisponible: true,
            );

            await _firestore.collection('disponibilidad_medicos').add(availability.toFirestore());
            slotsCreados++;
          }
        }
      }

      print('✓ Disponibilidad creada: $slotsCreados slots (del 25 oct al 10 nov 2025)');
    } catch (e) {
      print('Error al inicializar disponibilidad: $e');
      throw Exception('Error al inicializar disponibilidad: $e');
    }
  }

  /// Verificar si ya existen datos de disponibilidad
  Future<bool> checkIfDataExists() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('disponibilidad_medicos')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
