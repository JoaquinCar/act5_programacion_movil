# Firestore - Colecciones del MVP

Este proyecto implementa 3 colecciones principales en Firestore para el Producto Mínimo Viable (MVP).

## 📚 Colecciones Implementadas

### 1. **usuarios** (Colección de Usuarios)
Almacena la información personal de cada usuario registrado.

**Estructura del documento:**
```json
{
  "email": "usuario@ejemplo.com",
  "nombre": "Juan Pérez",
  "edad": 35,
  "lugar_nacimiento": "Ciudad de México, México",
  "padecimientos": "Hipertensión, Diabetes tipo 2",
  "telefono": "+52 55 1234 5678",
  "fecha_registro": Timestamp
}
```

**ID del documento:** UID de Firebase Authentication

**Uso:**
- Se crea/actualiza automáticamente cuando el usuario completa su perfil en la app
- Los datos se cargan automáticamente en la pantalla de edición de perfil
- Funciones disponibles en `FirestoreService`:
  - `createOrUpdateUser(UserModel user)`
  - `getUser(String uid)`
  - `getUserStream(String uid)`

---

### 2. **citas** (Colección de Citas)
Guarda todas las citas programadas en la aplicación.

**Estructura del documento:**
```json
{
  "paciente_id": "uid_del_paciente",
  "medico_id": "dr_carlos_ramirez",
  "medico_nombre": "Dr. Carlos Ramírez",
  "especialidad": "Cardiología",
  "fecha_hora": Timestamp,
  "motivo": "Dolor en el pecho",
  "estado": "pendiente",
  "fecha_creacion": Timestamp
}
```

**Estados posibles:**
- `pendiente` - Cita agendada, esperando confirmación
- `confirmada` - Cita confirmada por el médico
- `cancelada` - Cita cancelada
- `completada` - Cita ya realizada

**Uso:**
- Se crea cuando un usuario agenda una cita
- Funciones disponibles en `FirestoreService`:
  - `createAppointment(AppointmentModel appointment)`
  - `getPatientAppointments(String pacienteId)`
  - `getDoctorAppointments(String medicoId)`
  - `updateAppointmentStatus(String citaId, String nuevoEstado)`
  - `cancelAppointment(String citaId)`
  - `getPatientAppointmentsStream(String pacienteId)` - Tiempo real

---

### 3. **disponibilidad_medicos** (Colección de Disponibilidad)
Almacena los horarios disponibles de cada médico.

**Estructura del documento:**
```json
{
  "medico_id": "dr_carlos_ramirez",
  "medico_nombre": "Dr. Carlos Ramírez",
  "especialidad": "Cardiología",
  "fecha": Timestamp,
  "hora_inicio": "09:00",
  "hora_fin": "10:00",
  "esta_disponible": true
}
```

**Campo `esta_disponible`:**
- `true` - El horario está libre para agendar
- `false` - El horario ya está ocupado

**Uso:**
- Los horarios se pueden inicializar con datos de ejemplo
- Se marca como `false` cuando se agenda una cita
- Se marca como `true` si se cancela una cita
- Funciones disponibles en `FirestoreService`:
  - `createDoctorAvailability(DoctorAvailabilityModel availability)`
  - `getDoctorAvailability({required String medicoId, required DateTime fecha})`
  - `getAvailableSlots({DateTime? fecha, String? especialidad})`
  - `markSlotAsUnavailable(String availabilityId)`
  - `markSlotAsAvailable(String availabilityId)`

---

## 🚀 Operaciones Combinadas

### Agendar una Cita Completa
```dart
FirestoreService firestoreService = FirestoreService();

// 1. Crear el modelo de la cita
AppointmentModel appointment = AppointmentModel(
  pacienteId: currentUser.uid,
  medicoId: 'dr_carlos_ramirez',
  medicoNombre: 'Dr. Carlos Ramírez',
  especialidad: 'Cardiología',
  fechaHora: DateTime(2025, 10, 25, 10, 0),
  motivo: 'Revisión general',
  estado: 'pendiente',
  fechaCreacion: DateTime.now(),
);

// 2. Agendar (crea la cita Y marca el horario como ocupado)
String citaId = await firestoreService.bookAppointment(
  appointment: appointment,
  availabilityId: 'id_del_slot_disponible',
);
```

### Cancelar una Cita y Liberar el Horario
```dart
await firestoreService.cancelAppointmentAndFreeSlot(
  citaId: 'id_de_la_cita',
  availabilityId: 'id_del_slot',
);
```

---

## 🛠️ Inicialización de Datos de Ejemplo

Para poblar la base de datos con disponibilidad de médicos:

```dart
import 'package:act5/services/firestore_init_data.dart';

// En tu código (por ejemplo, en un botón de administrador)
FirestoreInitData initData = FirestoreInitData();

// Inicializar solo si no hay datos
await initData.initializeIfNeeded();

// O forzar la inicialización
await initData.initializeDoctorAvailability();
```

Esto creará:
- **7 médicos** con diferentes especialidades
- **7 horarios diarios** (de 9:00 AM a 6:00 PM)
- **7 días** de disponibilidad (próxima semana)
- **Total: 343 slots** de citas disponibles

---

## 📖 Modelos de Datos

### UserModel (`lib/models/user_model.dart`)
```dart
UserModel(
  uid: String,
  email: String,
  nombre: String,
  edad: int,
  lugarNacimiento: String,
  padecimientos: String,
  telefono: String?,
  fechaRegistro: DateTime,
)
```

### AppointmentModel (`lib/models/appointment_model.dart`)
```dart
AppointmentModel(
  id: String?,
  pacienteId: String,
  medicoId: String,
  medicoNombre: String,
  especialidad: String,
  fechaHora: DateTime,
  motivo: String,
  estado: String,
  fechaCreacion: DateTime,
)
```

### DoctorAvailabilityModel (`lib/models/doctor_availability_model.dart`)
```dart
DoctorAvailabilityModel(
  id: String?,
  medicoId: String,
  medicoNombre: String,
  especialidad: String,
  fecha: DateTime,
  horaInicio: String,
  horaFin: String,
  estaDisponible: bool,
)
```

---

## 🔒 Reglas de Seguridad de Firestore (Recomendadas)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Colección de usuarios
    match /usuarios/{userId} {
      // Solo el usuario puede leer/escribir su propio documento
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Colección de citas
    match /citas/{citaId} {
      // El paciente puede leer sus propias citas
      allow read: if request.auth != null &&
                     resource.data.paciente_id == request.auth.uid;
      // El paciente puede crear citas
      allow create: if request.auth != null &&
                       request.resource.data.paciente_id == request.auth.uid;
      // El paciente puede actualizar/cancelar sus citas
      allow update, delete: if request.auth != null &&
                               resource.data.paciente_id == request.auth.uid;
    }

    // Colección de disponibilidad
    match /disponibilidad_medicos/{slotId} {
      // Todos los usuarios autenticados pueden leer
      allow read: if request.auth != null;
      // Solo permitir actualizaciones del campo esta_disponible
      allow update: if request.auth != null;
    }
  }
}
```

---

## ✅ Integración Actual

La app ya tiene integrado:

1. ✅ **EditProfileScreen** guarda y carga datos de la colección `usuarios`
2. ✅ **FirestoreService** con todas las funciones CRUD
3. ✅ **Modelos de datos** con conversión Firestore ↔️ Dart
4. ✅ **Script de inicialización** para datos de prueba

---

## 📝 Próximos Pasos Sugeridos

Para completar la funcionalidad:

1. **Pantalla de Agendar Cita:**
   - Mostrar especialidades disponibles
   - Seleccionar fecha
   - Mostrar horarios disponibles
   - Confirmar y crear la cita

2. **Pantalla de Mis Citas:**
   - Listar citas del usuario
   - Ver detalles
   - Opción de cancelar

3. **Notificaciones:**
   - Recordatorios de citas
   - Confirmaciones

---

## 🎯 Ejemplo de Flujo Completo

```dart
// 1. Usuario completa su perfil
UserModel user = UserModel(...);
await firestoreService.createOrUpdateUser(user);

// 2. Usuario busca disponibilidad
List<DoctorAvailabilityModel> slots = await firestoreService.getAvailableSlots(
  fecha: DateTime(2025, 10, 25),
  especialidad: 'Cardiología',
);

// 3. Usuario selecciona un horario y agenda
AppointmentModel cita = AppointmentModel(...);
String citaId = await firestoreService.bookAppointment(
  appointment: cita,
  availabilityId: slots.first.id!,
);

// 4. Usuario ve sus citas
List<AppointmentModel> misCitas = await firestoreService.getPatientAppointments(
  user.uid,
);

// 5. Usuario cancela una cita
await firestoreService.cancelAppointmentAndFreeSlot(
  citaId: citaId,
  availabilityId: slots.first.id!,
);
```

---

## 🔧 Configuración de Firebase

1. Asegúrate de tener Firebase configurado en tu proyecto
2. Habilita Firestore en la consola de Firebase
3. Aplica las reglas de seguridad sugeridas
4. Ejecuta la app y prueba guardando tu perfil

---

**¡Listo para usar! 🎉**
