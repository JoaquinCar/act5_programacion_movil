import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_availability_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COLECCIÓN: USUARIOS ====================

  /// Crear o actualizar un usuario en Firestore
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection('usuarios').doc(user.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Error al guardar usuario: $e');
    }
  }

  /// Obtener un usuario por su UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Stream para escuchar cambios en tiempo real de un usuario
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      },
    );
  }

  // ==================== COLECCIÓN: CITAS ====================

  /// Crear una nueva cita
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('citas')
          .add(appointment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  /// Obtener todas las citas de un paciente
  Future<List<AppointmentModel>> getPatientAppointments(
      String pacienteId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('citas')
          .where('paciente_id', isEqualTo: pacienteId)
          .orderBy('fecha_hora', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener citas del paciente: $e');
    }
  }

  /// Obtener todas las citas de un médico
  Future<List<AppointmentModel>> getDoctorAppointments(String medicoId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('citas')
          .where('medico_id', isEqualTo: medicoId)
          .orderBy('fecha_hora', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener citas del médico: $e');
    }
  }

  /// Actualizar el estado de una cita
  Future<void> updateAppointmentStatus(String citaId, String nuevoEstado) async {
    try {
      await _firestore.collection('citas').doc(citaId).update({
        'estado': nuevoEstado,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado de cita: $e');
    }
  }

  /// Cancelar una cita
  Future<void> cancelAppointment(String citaId) async {
    try {
      await updateAppointmentStatus(citaId, 'cancelada');
    } catch (e) {
      throw Exception('Error al cancelar cita: $e');
    }
  }

  /// Stream de citas del paciente en tiempo real
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(
      String pacienteId) {
    return _firestore
        .collection('citas')
        .where('paciente_id', isEqualTo: pacienteId)
        .orderBy('fecha_hora', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== COLECCIÓN: DISPONIBILIDAD DE MÉDICOS ====================

  /// Crear horario de disponibilidad para un médico
  Future<String> createDoctorAvailability(
      DoctorAvailabilityModel availability) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('disponibilidad_medicos')
          .add(availability.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear disponibilidad: $e');
    }
  }

  /// Obtener disponibilidad de un médico en una fecha específica
  Future<List<DoctorAvailabilityModel>> getDoctorAvailability({
    required String medicoId,
    required DateTime fecha,
  }) async {
    try {
      // Inicio y fin del día
      DateTime startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
      DateTime endOfDay = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

      QuerySnapshot querySnapshot = await _firestore
          .collection('disponibilidad_medicos')
          .where('medico_id', isEqualTo: medicoId)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) => DoctorAvailabilityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener disponibilidad: $e');
    }
  }

  /// Obtener todos los horarios disponibles (no ocupados)
  Future<List<DoctorAvailabilityModel>> getAvailableSlots({
    DateTime? fecha,
    String? especialidad,
  }) async {
    try {
      Query query = _firestore
          .collection('disponibilidad_medicos')
          .where('esta_disponible', isEqualTo: true);

      if (fecha != null) {
        DateTime startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
        DateTime endOfDay = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);
        query = query
            .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      }

      QuerySnapshot querySnapshot = await query.get();

      List<DoctorAvailabilityModel> slots = querySnapshot.docs
          .map((doc) => DoctorAvailabilityModel.fromFirestore(doc))
          .toList();

      // Filtrar por especialidad si se proporciona
      if (especialidad != null && especialidad.isNotEmpty) {
        slots = slots
            .where((slot) => slot.especialidad == especialidad)
            .toList();
      }

      return slots;
    } catch (e) {
      throw Exception('Error al obtener horarios disponibles: $e');
    }
  }

  /// Marcar un horario como ocupado
  Future<void> markSlotAsUnavailable(String availabilityId) async {
    try {
      await _firestore
          .collection('disponibilidad_medicos')
          .doc(availabilityId)
          .update({'esta_disponible': false});
    } catch (e) {
      throw Exception('Error al marcar horario como ocupado: $e');
    }
  }

  /// Marcar un horario como disponible nuevamente
  Future<void> markSlotAsAvailable(String availabilityId) async {
    try {
      await _firestore
          .collection('disponibilidad_medicos')
          .doc(availabilityId)
          .update({'esta_disponible': true});
    } catch (e) {
      throw Exception('Error al marcar horario como disponible: $e');
    }
  }

  // ==================== OPERACIONES COMBINADAS ====================

  /// Agendar una cita y marcar el horario como ocupado
  Future<String> bookAppointment({
    required AppointmentModel appointment,
    required String availabilityId,
  }) async {
    try {
      // Crear la cita
      String citaId = await createAppointment(appointment);

      // Marcar el horario como ocupado
      await markSlotAsUnavailable(availabilityId);

      return citaId;
    } catch (e) {
      throw Exception('Error al agendar cita: $e');
    }
  }

  /// Cancelar cita y liberar el horario
  Future<void> cancelAppointmentAndFreeSlot({
    required String citaId,
    required String availabilityId,
  }) async {
    try {
      // Cancelar la cita
      await cancelAppointment(citaId);

      // Marcar el horario como disponible
      await markSlotAsAvailable(availabilityId);
    } catch (e) {
      throw Exception('Error al cancelar cita y liberar horario: $e');
    }
  }
}
