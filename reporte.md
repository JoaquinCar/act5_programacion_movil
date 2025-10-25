# Reporte Técnico: Sistema de Gestión de Citas Médicas
## Aplicación Flutter con Firebase Firestore

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)
4. [Estructura de Base de Datos](#estructura-de-base-de-datos)
5. [Implementación del CRUD](#implementación-del-crud)
6. [Componentes Principales](#componentes-principales)
7. [Servicios y Modelos](#servicios-y-modelos)
8. [Navegación y Routing](#navegación-y-routing)
9. [Decisiones Técnicas](#decisiones-técnicas)
10. [Desafíos y Soluciones](#desafíos-y-soluciones)

---

## 1. Resumen Ejecutivo

### Objetivo del Proyecto
Desarrollar una aplicación móvil de gestión de citas médicas con funcionalidad CRUD completa utilizando Flutter y Firebase Firestore, permitiendo a los pacientes crear, visualizar, modificar y cancelar citas con diferentes especialistas médicos.

### Alcance Implementado
- ✅ Sistema de autenticación con Firebase Authentication
- ✅ CRUD completo de citas médicas
- ✅ Gestión de disponibilidad de médicos
- ✅ Perfil de usuario editable
- ✅ Sistema de navegación con bottom navigation bar
- ✅ Actualización en tiempo real de datos
- ✅ Validación de horarios y prevención de conflictos

---

## 2. Arquitectura del Proyecto

### Patrón Arquitectónico
El proyecto sigue una arquitectura **MVC simplificada** adaptada para Flutter:

```
lib/
├── models/              # Modelos de datos (Model)
├── services/            # Lógica de negocio y conexión a Firebase (Controller)
├── screens/             # Interfaces de usuario (View)
└── main.dart           # Punto de entrada y configuración
```

### Capas de la Aplicación

**Capa de Presentación (UI)**
- Screens: Pantallas completas de la aplicación
- Widgets: Componentes reutilizables de interfaz

**Capa de Lógica de Negocio**
- Services: Gestión de operaciones con Firebase
- Estado: Manejo de estado con StatefulWidget y Streams

**Capa de Datos**
- Models: Clases que representan entidades del dominio
- Firestore: Base de datos NoSQL en la nube

---

## 3. Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter 3.x**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación

### Backend as a Service (BaaS)
- **Firebase Authentication**: Autenticación de usuarios (email/password)
- **Cloud Firestore**: Base de datos NoSQL en tiempo real
- **Firebase Core**: Inicialización y configuración

### Librerías Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.8.1        # Configuración de Firebase
  firebase_auth: ^5.3.3        # Autenticación
  cloud_firestore: ^5.5.0      # Base de datos
```

---

## 4. Estructura de Base de Datos

### Colecciones de Firestore

#### 4.1 Colección: `usuarios`
**Propósito**: Almacenar información de perfil de los pacientes

```javascript
{
  uid: "firebase_uid_123",
  email: "paciente@example.com",
  nombre: "Juan Pérez",
  edad: 35,
  lugar_nacimiento: "Ciudad de México",
  padecimientos: "Hipertensión",
  telefono: "+52 55 1234 5678",
  fecha_registro: Timestamp
}
```

**Campos clave**:
- `uid` (String): Identificador único del usuario (mismo que Firebase Auth)
- `telefono` (String?): Campo opcional para contacto
- `fecha_registro` (Timestamp): Fecha de creación del perfil

**Modelo implementado**: `UserModel` en `lib/models/user_model.dart`

---

#### 4.2 Colección: `citas`
**Propósito**: Registrar todas las citas médicas agendadas

```javascript
{
  id: "auto_generated_id",
  paciente_id: "firebase_uid_123",
  medico_id: "med_001",
  medico_nombre: "Dr. Carlos Ramírez",
  especialidad: "Cardiología",
  fecha_hora: Timestamp,
  motivo: "Consulta de seguimiento",
  estado: "pendiente",  // pendiente | confirmada | completada | cancelada
  fecha_creacion: Timestamp
}
```

**Campos clave**:
- `estado` (String): Control del ciclo de vida de la cita
- `fecha_hora` (Timestamp): Fecha y hora de la cita
- `motivo` (String): Razón de la consulta médica

**Modelo implementado**: `AppointmentModel` en `lib/models/appointment_model.dart`

**Estados posibles**:
1. `pendiente`: Cita creada, esperando confirmación
2. `confirmada`: Cita confirmada por el médico/sistema
3. `completada`: Consulta realizada
4. `cancelada`: Cita cancelada por el paciente o médico

---

#### 4.3 Colección: `disponibilidad_medicos`
**Propósito**: Gestionar horarios disponibles de los médicos

```javascript
{
  id: "auto_generated_id",
  medico_id: "med_001",
  medico_nombre: "Dr. Carlos Ramírez",
  especialidad: "Cardiología",
  fecha: Timestamp,
  hora_inicio: "09:00",
  hora_fin: "10:00",
  esta_disponible: true
}
```

**Campos clave**:
- `esta_disponible` (Boolean): Indica si el slot está libre u ocupado
- `hora_inicio/hora_fin` (String): Horario del slot en formato 24h

**Modelo implementado**: `DoctorAvailabilityModel` en `lib/models/doctor_availability_model.dart`

**Lógica de disponibilidad**:
- Cuando se crea una cita, `esta_disponible` cambia a `false`
- Permite prevenir doble asignación de horarios
- Slots de 1 hora de duración

---

## 5. Implementación del CRUD

### 5.1 CREATE (Crear Citas)

**Archivo**: `lib/screens/create_appointment_screen.dart`

#### Flujo de Creación
La creación de citas sigue un **wizard de 4 pasos**:

```
Paso 1: Seleccionar Especialidad
   ↓
Paso 2: Seleccionar Fecha
   ↓
Paso 3: Seleccionar Horario Disponible
   ↓
Paso 4: Ingresar Motivo de Consulta
   ↓
Confirmación y Creación
```

#### Implementación Técnica

**Estado del Formulario**:
```dart
class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  String? _selectedEspecialidad;
  DateTime? _selectedDate;
  DoctorAvailabilityModel? _selectedSlot;
  List<DoctorAvailabilityModel> _availableSlots = [];
  final TextEditingController _motivoController = TextEditingController();
}
```

**Paso 1 - Selección de Especialidad**:
```dart
DropdownButtonFormField<String>(
  items: _especialidades.map((especialidad) =>
    DropdownMenuItem(value: especialidad, child: Text(especialidad))
  ).toList(),
  onChanged: (value) {
    setState(() {
      _selectedEspecialidad = value;
      _selectedDate = null;
      _selectedSlot = null;
      _availableSlots = [];
    });
  },
)
```

**Razón de diseño**: Resetear selecciones posteriores cuando cambia la especialidad para evitar inconsistencias.

**Paso 2 - Selección de Fecha**:
```dart
Future<void> _selectDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 30)),
  );

  if (picked != null) {
    setState(() {
      _selectedDate = picked;
      _selectedSlot = null;
    });
    _loadAvailableSlots(); // Cargar slots disponibles
  }
}
```

**Validación**: Solo permite fechas futuras (máximo 30 días adelante).

**Paso 3 - Carga de Slots Disponibles**:
```dart
Future<void> _loadAvailableSlots() async {
  if (_selectedDate == null || _selectedEspecialidad == null) return;

  setState(() => _isLoading = true);

  try {
    final slots = await _firestoreService.getAvailableSlots(
      fecha: _selectedDate,
      especialidad: _selectedEspecialidad,
    );

    setState(() {
      _availableSlots = slots;
      _isLoading = false;
    });
  } catch (e) {
    // Manejo de errores
  }
}
```

**Optimización**: Consulta a Firestore filtrada por fecha y especialidad para minimizar datos transferidos.

**Paso 4 - Creación de la Cita**:
```dart
Future<void> _createAppointment() async {
  if (!_formKey.currentState!.validate()) return;

  final user = FirebaseAuth.instance.currentUser;

  // Construir objeto de cita
  final appointment = AppointmentModel(
    pacienteId: user!.uid,
    medicoId: _selectedSlot!.medicoId,
    medicoNombre: _selectedSlot!.medicoNombre,
    especialidad: _selectedSlot!.especialidad,
    fechaHora: _selectedSlot!.fecha,
    motivo: _motivoController.text.trim(),
    estado: 'pendiente',
    fechaCreacion: DateTime.now(),
  );

  // Operación atómica: crear cita + marcar slot ocupado
  await _firestoreService.bookAppointment(
    appointment: appointment,
    availabilityId: _selectedSlot!.id!,
  );
}
```

**Transacción importante**: `bookAppointment` realiza dos operaciones:
1. Crea el documento en `citas`
2. Marca el slot como `esta_disponible: false`

---

### 5.2 READ (Visualizar Citas)

**Archivo**: `lib/screens/appointments_screen.dart`

#### Implementación con StreamBuilder

**Razón de usar Streams**: Actualización automática en tiempo real cuando hay cambios en Firestore.

```dart
StreamBuilder<List<AppointmentModel>>(
  stream: _firestoreService.getPatientAppointmentsStream(user.uid),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    List<AppointmentModel> appointments = snapshot.data ?? [];

    // Filtrar por estado si se seleccionó filtro
    if (_selectedFilter != 'todas') {
      appointments = appointments.where(
        (apt) => apt.estado == _selectedFilter
      ).toList();
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
    );
  },
)
```

#### Sistema de Filtros

**Implementación de filtros por estado**:
```dart
List<String> _filters = ['todas', 'pendiente', 'confirmada', 'completada', 'cancelada'];
String _selectedFilter = 'todas';

// Chips para selección
Wrap(
  spacing: 8,
  children: _filters.map((filter) =>
    ChoiceChip(
      label: Text(filter),
      selected: _selectedFilter == filter,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
        }
      },
    )
  ).toList(),
)
```

**Ventaja**: Filtrado en cliente (no requiere consultas adicionales a Firestore).

#### Tarjeta de Cita

```dart
Widget _buildAppointmentCard(AppointmentModel appointment) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(appointment.estado),
        child: Icon(_getSpecialtyIcon(appointment.especialidad)),
      ),
      title: Text(appointment.medicoNombre),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${appointment.especialidad}'),
          Text('${_formatDate(appointment.fechaHora)}'),
          Text('Motivo: ${appointment.motivo}'),
        ],
      ),
      trailing: _buildStatusChip(appointment.estado),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAppointmentScreen(
              appointment: appointment,
            ),
          ),
        );
      },
    ),
  );
}
```

**Elementos visuales**:
- Color de avatar según estado (pendiente=naranja, confirmada=verde, etc.)
- Icono de especialidad médica
- Chip de estado con color
- Tap para editar

---

### 5.3 UPDATE (Actualizar Citas)

**Archivo**: `lib/screens/edit_appointment_screen.dart`

#### Funcionalidades de Edición

La pantalla de edición permite modificar:
1. **Estado de la cita** (pendiente → confirmada → completada)
2. **Fecha y hora** (cambiando especialidad, fecha y slot)
3. **Motivo de consulta**
4. **Eliminar/cancelar cita**

#### Protección Contra Pérdida de Datos

**Implementación de WillPopScope**:
```dart
WillPopScope(
  onWillPop: () async {
    if (_hasChanges) {
      return await _showExitDialog() ?? false;
    }
    return true;
  },
  child: Scaffold(...)
)
```

**Diálogo de confirmación**:
```dart
Future<bool?> _showExitDialog() async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Salir sin guardar?'),
      content: Text('Tienes cambios sin guardar. ¿Deseas salir?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Salir sin guardar'),
        ),
      ],
    ),
  );
}
```

**Razón**: Prevenir pérdida accidental de datos cuando el usuario presiona el botón de retroceso.

#### Cambio de Estado

**Selector de estados con chips**:
```dart
Widget _buildEstadoSelector() {
  List<String> estados = ['pendiente', 'confirmada', 'completada', 'cancelada'];

  return Wrap(
    spacing: 8,
    children: estados.map((estado) =>
      ChoiceChip(
        label: Text(estado),
        selected: _selectedEstado == estado,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedEstado = estado;
              _hasChanges = true;
            });
          }
        },
      )
    ).toList(),
  );
}
```

#### Cambio de Fecha/Hora

**Flujo condicional**:
```dart
if (_needsNewSlot) {
  // Usuario cambió especialidad o fecha
  await _loadNewAvailableSlots();

  // Mostrar selector de nuevos slots
  Widget _buildSlotsSelector() {
    return ListView.builder(
      itemCount: _newAvailableSlots.length,
      itemBuilder: (context, index) {
        final slot = _newAvailableSlots[index];
        return RadioListTile(
          title: Text('${slot.horaInicio} - ${slot.horaFin}'),
          subtitle: Text(slot.medicoNombre),
          value: slot,
          groupValue: _selectedNewSlot,
          onChanged: (value) {
            setState(() => _selectedNewSlot = value);
          },
        );
      },
    );
  }
}
```

#### Actualización en Firestore

```dart
Future<void> _updateAppointment() async {
  try {
    if (_selectedNewSlot != null) {
      // Caso 1: Cambió fecha/hora - crear nueva cita
      final updatedAppointment = AppointmentModel(
        id: widget.appointment.id,
        pacienteId: widget.appointment.pacienteId,
        medicoId: _selectedNewSlot!.medicoId,
        medicoNombre: _selectedNewSlot!.medicoNombre,
        especialidad: _selectedNewSlot!.especialidad,
        fechaHora: _selectedNewSlot!.fecha,
        motivo: _motivoController.text.trim(),
        estado: _selectedEstado,
        fechaCreacion: widget.appointment.fechaCreacion,
      );

      // Eliminar documento anterior y crear nuevo con nuevo slot
      await _firestoreService.updateAppointment(updatedAppointment);

    } else {
      // Caso 2: Solo cambió estado o motivo
      await _firestoreService.updateAppointmentStatus(
        widget.appointment.id!,
        _selectedEstado,
      );
    }

    Navigator.pop(context);
  } catch (e) {
    // Mostrar error
  }
}
```

**Validación importante**: Verifica que el nuevo slot no esté ocupado antes de asignar.

---

### 5.4 DELETE (Eliminar Citas)

**Ubicación**: Implementado en `appointments_screen.dart` y `edit_appointment_screen.dart`

#### Confirmación de Eliminación

**Diálogo de confirmación con advertencia visual**:
```dart
Future<void> _deleteAppointment() async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Eliminar Cita'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta cita?\n\n'
          'Médico: ${widget.appointment.medicoNombre}\n'
          'Fecha: ${_formatDate(widget.appointment.fechaHora)}\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await _firestoreService.updateAppointmentStatus(
      widget.appointment.id!,
      'cancelada',
    );

    Navigator.pop(context); // Regresar a lista
  }
}
```

**Decisión de diseño**: En lugar de eliminar el documento, se marca como `cancelada`. Razones:
1. **Auditoría**: Mantener historial de citas canceladas
2. **Análisis**: Poder analizar patrones de cancelación
3. **Reversibilidad**: Posibilidad de reactivar si fue error

#### Liberación de Slot (Funcionalidad Avanzada)

**Método opcional en `firestore_service.dart`**:
```dart
Future<void> cancelAppointmentAndFreeSlot({
  required String citaId,
  required String availabilityId,
}) async {
  try {
    // 1. Cancelar la cita
    await updateAppointmentStatus(citaId, 'cancelada');

    // 2. Liberar el horario para que otro paciente pueda usarlo
    await markSlotAsAvailable(availabilityId);
  } catch (e) {
    throw Exception('Error al cancelar cita y liberar horario: $e');
  }
}
```

**Ventaja**: Cuando se cancela una cita, el horario queda disponible nuevamente.

---

## 6. Componentes Principales

### 6.1 Autenticación

**Archivo**: `lib/services/auth_service.dart`

#### Métodos Implementados

**Registro de Usuario**:
```dart
Future<User?> signUpWithEmailPassword({
  required String email,
  required String password,
}) async {
  try {
    UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      throw Exception('La contraseña es muy débil');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('Ya existe una cuenta con este correo');
    }
    throw Exception('Error al registrar: ${e.message}');
  }
}
```

**Inicio de Sesión**:
```dart
Future<User?> signInWithEmailPassword({
  required String email,
  required String password,
}) async {
  try {
    UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('No existe usuario con este correo');
    } else if (e.code == 'wrong-password') {
      throw Exception('Contraseña incorrecta');
    }
    throw Exception('Error al iniciar sesión: ${e.message}');
  }
}
```

**Cierre de Sesión**:
```dart
Future<void> signOut() async {
  await _auth.signOut();
}
```

**Stream de Estado de Autenticación**:
```dart
Stream<User?> get authStateChanges => _auth.authStateChanges();
```

---

### 6.2 Gestión de Estado de Autenticación

**Archivo**: `lib/main.dart`

**StreamBuilder para navegación reactiva**:
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Esperando conexión
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Usuario autenticado
          if (snapshot.hasData) {
            return MainNavigation(); // Pantalla principal
          }

          // Usuario no autenticado
          return LoginScreen();
        },
      ),
    );
  }
}
```

**Ventaja clave**: La aplicación reacciona automáticamente a cambios de autenticación:
- Login exitoso → navega a home automáticamente
- Logout → regresa a login automáticamente
- No requiere navegación manual con `pushReplacement`

---

### 6.3 Navegación Principal

**Archivo**: `lib/screens/main_navigation.dart`

**Bottom Navigation Bar con 3 pestañas**:
```dart
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),      // Inicio
    MessagesScreen(),  // Mensajes (UI placeholder)
    SettingsScreen(),  // Configuración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
```

---

### 6.4 Pantalla Principal (Home)

**Archivo**: `lib/screens/home_screen.dart`

#### Elementos de la Interfaz

**1. Mensaje de Bienvenida Personalizado**:
```dart
final user = FirebaseAuth.instance.currentUser;
String userName = user?.email?.split('@')[0] ?? 'Usuario';

Text('¡Hola, $userName!'),
Text('¿En qué podemos ayudarte?'),
```

**Extracción del nombre**: Toma la parte antes del `@` del email.

**2. Botones de Acción Rápida** (Horizontal Scroll):
```dart
SizedBox(
  height: 130,
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
      _buildQuickActionButton(
        context,
        icon: Icons.calendar_today,
        title: 'Agendar\nuna Cita',
        color: Colors.purple,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAppointmentScreen())),
      ),
      _buildQuickActionButton(
        context,
        icon: Icons.event_note,
        title: 'Mis\nCitas',
        color: Colors.indigo,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => AppointmentsScreen())),
      ),
      _buildQuickActionButton(
        context,
        icon: Icons.medical_services,
        title: 'Consejos\nmédicos',
        color: Colors.deepPurple,
        onTap: () => _showMedicalTipsDialog(context),
      ),
    ],
  ),
)
```

**3. Lista de Especialistas**:
```dart
_buildSpecialistCard(
  icon: Icons.favorite,
  name: 'Dr. Carlos Ramírez',
  specialty: 'Cardiólogo',
  color: Colors.red,
),
```

**Widget reutilizable con parámetros**:
```dart
Widget _buildSpecialistCard({
  required IconData icon,
  required String name,
  required String specialty,
  required Color color,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 35, color: color),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(specialty, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
      ],
    ),
  );
}
```

---

## 7. Servicios y Modelos

### 7.1 FirestoreService

**Archivo**: `lib/services/firestore_service.dart`

Este servicio centraliza todas las operaciones con Firestore, siguiendo el patrón **Repository**.

#### Métodos de Usuarios

**Crear o Actualizar Usuario**:
```dart
Future<void> createOrUpdateUser(UserModel user) async {
  try {
    await _firestore.collection('usuarios').doc(user.uid).set(
      user.toFirestore(),
      SetOptions(merge: true), // Merge: actualiza solo campos enviados
    );
  } catch (e) {
    throw Exception('Error al guardar usuario: $e');
  }
}
```

**Obtener Usuario**:
```dart
Future<UserModel?> getUser(String uid) async {
  try {
    DocumentSnapshot doc = await _firestore
      .collection('usuarios')
      .doc(uid)
      .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  } catch (e) {
    throw Exception('Error al obtener usuario: $e');
  }
}
```

**Stream de Usuario** (actualización en tiempo real):
```dart
Stream<UserModel?> getUserStream(String uid) {
  return _firestore
    .collection('usuarios')
    .doc(uid)
    .snapshots()
    .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
}
```

#### Métodos de Citas

**Crear Cita**:
```dart
Future<String> createAppointment(AppointmentModel appointment) async {
  try {
    DocumentReference docRef = await _firestore
      .collection('citas')
      .add(appointment.toFirestore());
    return docRef.id; // Retorna el ID generado
  } catch (e) {
    throw Exception('Error al crear cita: $e');
  }
}
```

**Obtener Citas del Paciente** (con ordenamiento en memoria):
```dart
Future<List<AppointmentModel>> getPatientAppointments(String pacienteId) async {
  try {
    QuerySnapshot querySnapshot = await _firestore
      .collection('citas')
      .where('paciente_id', isEqualTo: pacienteId)
      .get();

    List<AppointmentModel> appointments = querySnapshot.docs
      .map((doc) => AppointmentModel.fromFirestore(doc))
      .toList();

    // Ordenar en memoria para evitar índice compuesto
    appointments.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return appointments;
  } catch (e) {
    throw Exception('Error al obtener citas: $e');
  }
}
```

**Razón de ordenar en memoria**: Evitar crear índices compuestos en Firestore (que requieren configuración manual).

**Stream de Citas** (actualización en tiempo real):
```dart
Stream<List<AppointmentModel>> getPatientAppointmentsStream(String pacienteId) {
  return _firestore
    .collection('citas')
    .where('paciente_id', isEqualTo: pacienteId)
    .snapshots()
    .map((snapshot) {
      List<AppointmentModel> appointments = snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();

      appointments.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

      return appointments;
    });
}
```

**Actualizar Estado de Cita**:
```dart
Future<void> updateAppointmentStatus(String citaId, String nuevoEstado) async {
  try {
    await _firestore.collection('citas').doc(citaId).update({
      'estado': nuevoEstado,
    });
  } catch (e) {
    throw Exception('Error al actualizar estado: $e');
  }
}
```

#### Métodos de Disponibilidad

**Obtener Slots Disponibles**:
```dart
Future<List<DoctorAvailabilityModel>> getAvailableSlots({
  DateTime? fecha,
  String? especialidad,
}) async {
  try {
    Query query = _firestore.collection('disponibilidad_medicos');

    // Filtrar por rango de fecha si se proporciona
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

    // Filtrar en memoria para evitar índices compuestos
    slots = slots.where((slot) => slot.estaDisponible == true).toList();

    if (especialidad != null && especialidad.isNotEmpty) {
      slots = slots.where((slot) => slot.especialidad == especialidad).toList();
    }

    return slots;
  } catch (e) {
    throw Exception('Error al obtener horarios: $e');
  }
}
```

**Marcar Slot como Ocupado**:
```dart
Future<void> markSlotAsUnavailable(String availabilityId) async {
  try {
    await _firestore
      .collection('disponibilidad_medicos')
      .doc(availabilityId)
      .update({'esta_disponible': false});
  } catch (e) {
    throw Exception('Error al marcar horario: $e');
  }
}
```

#### Operación Combinada: Agendar Cita

```dart
Future<String> bookAppointment({
  required AppointmentModel appointment,
  required String availabilityId,
}) async {
  try {
    // 1. Crear la cita
    String citaId = await createAppointment(appointment);

    // 2. Marcar el slot como ocupado
    await markSlotAsUnavailable(availabilityId);

    return citaId;
  } catch (e) {
    throw Exception('Error al agendar cita: $e');
  }
}
```

**Importante**: Esta operación debería ser una transacción atómica en producción para evitar condiciones de carrera.

---

### 7.2 Modelos de Datos

#### UserModel

**Archivo**: `lib/models/user_model.dart`

```dart
class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final int edad;
  final String lugarNacimiento;
  final String padecimientos;
  final String? telefono; // Campo opcional
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

  // Convertir desde Firestore
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

  // Convertir a Firestore
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
```

**Decisión de diseño**: `uid` no se guarda en el documento porque es el ID del documento mismo.

#### AppointmentModel

**Archivo**: `lib/models/appointment_model.dart`

```dart
class AppointmentModel {
  final String? id; // Nullable porque se genera al crear
  final String pacienteId;
  final String medicoId;
  final String medicoNombre;
  final String especialidad;
  final DateTime fechaHora;
  final String motivo;
  final String estado;
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
```

#### DoctorAvailabilityModel

**Archivo**: `lib/models/doctor_availability_model.dart`

```dart
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
```

---

## 8. Navegación y Routing

### 8.1 Estrategia de Navegación

La aplicación usa **navegación imperativa** con `Navigator.push()`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CreateAppointmentScreen()),
);
```

**Ventajas**:
- Simple y directo
- No requiere configuración de rutas nombradas
- Fácil pasar parámetros a pantallas

**Alternativa rechazada**: Rutas nombradas con `Navigator.pushNamed()` - más complejo para proyecto pequeño.

### 8.2 Flujo de Navegación

```
StreamBuilder (main.dart)
├── LoginScreen (si no autenticado)
│   └── RegisterScreen
│
└── MainNavigation (si autenticado)
    ├── HomeScreen (tab 1)
    │   ├── CreateAppointmentScreen
    │   ├── AppointmentsScreen
    │   │   └── EditAppointmentScreen
    │   └── ProfilePage
    │
    ├── MessagesScreen (tab 2)
    │   └── ChatScreen
    │
    └── SettingsScreen (tab 3)
        ├── EditProfileScreen
        ├── PrivacyScreen
        └── AboutUsScreen
```

### 8.3 Paso de Parámetros

**Ejemplo: Editar cita**
```dart
// Desde AppointmentsScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditAppointmentScreen(
      appointment: appointments[index], // Pasar objeto completo
    ),
  ),
);

// En EditAppointmentScreen
class EditAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment; // Recibir parámetro

  const EditAppointmentScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);
}
```

---

## 9. Decisiones Técnicas

### 9.1 Ordenamiento en Memoria vs Firestore

**Problema**: Firestore requiere índices compuestos para consultas que combinan `where()` + `orderBy()`.

**Solución implementada**: Ordenar en memoria después de obtener datos.

```dart
// ❌ Requiere índice compuesto
QuerySnapshot snapshot = await _firestore
  .collection('citas')
  .where('paciente_id', isEqualTo: uid)
  .orderBy('fecha_hora', descending: true) // ← Requiere índice
  .get();

// ✅ Sin índice compuesto
QuerySnapshot snapshot = await _firestore
  .collection('citas')
  .where('paciente_id', isEqualTo: uid)
  .get();

List<AppointmentModel> appointments = snapshot.docs
  .map((doc) => AppointmentModel.fromFirestore(doc))
  .toList();

// Ordenar en memoria
appointments.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
```

**Ventaja**: No requiere configuración manual de índices en Firebase Console.
**Desventaja**: Consume más ancho de banda (trae todos los documentos).
**Justificación**: Para un MVP con pocos datos, es aceptable.

---

### 9.2 Soft Delete vs Hard Delete

**Decisión**: Usar **soft delete** (marcar como cancelada en lugar de eliminar).

```dart
// Soft delete
await updateAppointmentStatus(citaId, 'cancelada');

// vs Hard delete (no usado)
// await _firestore.collection('citas').doc(citaId).delete();
```

**Razones**:
1. **Auditoría**: Mantener historial completo
2. **Análisis**: Estudiar patrones de cancelación
3. **Cumplimiento**: Regulaciones médicas pueden requerir historial
4. **Recuperación**: Posibilidad de revertir errores

---

### 9.3 StreamBuilder vs FutureBuilder

**Elección**: Usar `StreamBuilder` para datos que cambian frecuentemente.

```dart
// ✅ StreamBuilder para lista de citas (actualización en tiempo real)
StreamBuilder<List<AppointmentModel>>(
  stream: _firestoreService.getPatientAppointmentsStream(uid),
  builder: (context, snapshot) { ... },
)

// vs FutureBuilder (no usado para citas)
// FutureBuilder requeriría refresh manual
```

**Ventaja**: Cambios en Firestore se reflejan inmediatamente en la UI.

---

### 9.4 Validación de Formularios

**Implementación con GlobalKey**:

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          if (value.length < 10) {
            return 'Mínimo 10 caracteres';
          }
          return null;
        },
      ),
    ],
  ),
)

// Al guardar
if (_formKey.currentState!.validate()) {
  // Formulario válido, proceder
}
```

---

### 9.5 Manejo de Errores

**Estrategia**: Try-catch con mensajes en español para el usuario.

```dart
try {
  await _firestoreService.createAppointment(appointment);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Cita creada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al crear cita: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

**Nota importante**: Siempre verificar `context.mounted` antes de usar context después de `await`.

---

## 10. Desafíos y Soluciones

### Desafío 1: Error de Índices Compuestos

**Problema**:
```
cloud_firestore/failed-precondition: The query requires an index
```

**Causa**: Consultas con múltiples `where()` o `where()` + `orderBy()`.

**Solución**: Filtrar y ordenar en memoria en lugar de en Firestore.

---

### Desafío 2: Navegación después de Logout

**Problema**: Después de logout, usuario quedaba en LoginScreen incluso al re-loguearse.

**Causa**: Uso de `Navigator.pushReplacement()` en logout, sobrepasando el `StreamBuilder`.

**Solución**: Eliminar navegación manual, dejar que `StreamBuilder` maneje todo.

```dart
// ❌ Antes (causaba bug)
await authService.signOut();
Navigator.pushReplacement(context,
  MaterialPageRoute(builder: (context) => LoginScreen()));

// ✅ Después (correcto)
await authService.signOut();
// StreamBuilder detecta cambio automáticamente
```

---

### Desafío 3: Pérdida de Datos al Retroceder

**Problema**: Usuario presiona back button y pierde cambios sin confirmar.

**Solución**: Implementar `WillPopScope` con diálogo de confirmación.

```dart
WillPopScope(
  onWillPop: () async {
    if (_hasChanges) {
      bool? shouldPop = await _showExitDialog();
      return shouldPop ?? false;
    }
    return true;
  },
  child: Scaffold(...),
)
```

---

### Desafío 4: Slots de Disponibilidad Vacíos

**Problema**: No había slots disponibles al crear citas.

**Causa**: No se había ejecutado script de inicialización de datos.

**Solución**: Crear `firestore_init_data.dart` con botón en configuración.

---

### Desafío 5: Fechas del Pasado

**Problema**: Script inicial creaba fechas basadas en `DateTime.now()` que quedaban obsoletas.

**Solución**: Modificar script para rango de fechas específico (25 oct - 10 nov 2025).

---

## 11. Conclusiones

### Logros Alcanzados

1. ✅ **CRUD Completo**: Todas las operaciones implementadas y funcionales
2. ✅ **Tiempo Real**: Uso de Streams para actualización automática
3. ✅ **Validación**: Prevención de conflictos de horarios
4. ✅ **UX**: Interfaz intuitiva con confirmaciones y feedback visual
5. ✅ **Escalabilidad**: Arquitectura modular fácil de extender

### Mejoras Futuras

**Funcionalidades**:
- Notificaciones push para recordatorios de citas
- Chat en tiempo real con médicos (actualmente es UI placeholder)
- Historial médico del paciente
- Integración con calendario del dispositivo
- Videollamadas para consultas virtuales

**Técnicas**:
- Implementar transacciones atómicas en operaciones críticas
- Agregar caché local con SQLite para modo offline
- Implementar paginación para listas largas
- Unit tests y widget tests
- Integración continua con GitHub Actions

**Seguridad**:
- Reglas de seguridad de Firestore más estrictas
- Validación de permisos por rol (paciente/médico/admin)
- Encriptación de datos sensibles
- Autenticación de dos factores

---

## 12. Anexos

### Comandos de Flutter Útiles

```bash
# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar aplicación
flutter run

# Generar APK
flutter build apk

# Ver logs
flutter logs
```

### Configuración de Firebase

**Pasos para configurar el proyecto**:
1. Crear proyecto en Firebase Console
2. Habilitar Authentication (Email/Password)
3. Crear base de datos Firestore en modo prueba
4. Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
5. Configurar FlutterFire CLI

### Estructura Completa de Archivos

```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── appointment_model.dart
│   └── doctor_availability_model.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigation.dart
│   ├── home_screen.dart
│   ├── appointments_screen.dart
│   ├── create_appointment_screen.dart
│   ├── edit_appointment_screen.dart
│   ├── messages_screen.dart
│   ├── settings_screen.dart
│   ├── profile_page.dart
│   ├── edit_profile_screen.dart
│   ├── privacy_screen.dart
│   └── about_us_screen.dart
└── services/
    ├── auth_service.dart
    ├── firestore_service.dart
    └── firestore_init_data.dart
```

---

**Elaborado por**: Sistema de Gestión de Citas Médicas
**Fecha**: Octubre 2025
**Tecnología**: Flutter + Firebase Firestore
**Versión**: 1.0.0
