# 🏥 Sistema de Gestión de Citas Médicas

Aplicación móvil desarrollada en Flutter con Firebase Firestore para la gestión completa de citas médicas, permitiendo a los pacientes agendar, visualizar, modificar y cancelar consultas médicas con diferentes especialistas.

---

## 📱 Características Principales

### ✅ CRUD Completo
- **Crear**: Agendar nuevas citas con especialistas médicos
- **Leer**: Visualizar lista de citas con actualización en tiempo real
- **Actualizar**: Modificar fecha, hora, motivo y estado de citas
- **Eliminar**: Cancelar citas con confirmación de seguridad

### 🔐 Autenticación
- Registro de usuarios con email y contraseña
- Inicio de sesión seguro con Firebase Authentication
- Cierre de sesión con confirmación

### 👤 Gestión de Perfil
- Edición de información personal (nombre, edad, teléfono, padecimientos)
- Actualización en tiempo real con Firestore

### 📅 Sistema de Citas
- Selección de especialidad médica (7 especialidades)
- Calendario de disponibilidad
- Slots de 1 hora (9:00 - 18:00)
- Validación de horarios para evitar conflictos
- Estados de cita: pendiente, confirmada, completada, cancelada

### 🎨 Interfaz de Usuario
- Diseño Material Design moderno
- Bottom Navigation Bar con 3 secciones
- Actualización en tiempo real con StreamBuilder
- Feedback visual con SnackBars y diálogos
- Filtros por estado de cita

---

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **Backend**: Firebase (BaaS)
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Core
- **Arquitectura**: MVC simplificada
- **Estado**: StatefulWidget + Streams

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada
├── models/                            # Modelos de datos
│   ├── user_model.dart
│   ├── appointment_model.dart
│   └── doctor_availability_model.dart
├── screens/                           # Pantallas de la app
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigation.dart
│   ├── home_screen.dart
│   ├── appointments_screen.dart       # READ + DELETE
│   ├── create_appointment_screen.dart # CREATE
│   ├── edit_appointment_screen.dart   # UPDATE + DELETE
│   ├── messages_screen.dart
│   ├── settings_screen.dart
│   ├── profile_page.dart
│   ├── edit_profile_screen.dart
│   ├── privacy_screen.dart
│   └── about_us_screen.dart
└── services/                          # Lógica de negocio
    ├── auth_service.dart              # Autenticación
    ├── firestore_service.dart         # CRUD de Firestore
    └── firestore_init_data.dart       # Inicialización de datos
```

---

## 🗄️ Estructura de Base de Datos (Firestore)

### Colección: `usuarios`
```javascript
{
  uid: "firebase_uid",
  email: "usuario@example.com",
  nombre: "Juan Pérez",
  edad: 35,
  lugar_nacimiento: "Ciudad de México",
  padecimientos: "Hipertensión",
  telefono: "+52 55 1234 5678",
  fecha_registro: Timestamp
}
```

### Colección: `citas`
```javascript
{
  id: "auto_generated",
  paciente_id: "firebase_uid",
  medico_id: "med_001",
  medico_nombre: "Dr. Carlos Ramírez",
  especialidad: "Cardiología",
  fecha_hora: Timestamp,
  motivo: "Consulta de seguimiento",
  estado: "pendiente", // pendiente | confirmada | completada | cancelada
  fecha_creacion: Timestamp
}
```

### Colección: `disponibilidad_medicos`
```javascript
{
  id: "auto_generated",
  medico_id: "med_001",
  medico_nombre: "Dr. Carlos Ramírez",
  especialidad: "Cardiología",
  fecha: Timestamp,
  hora_inicio: "09:00",
  hora_fin: "10:00",
  esta_disponible: true
}
```

---

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (3.x o superior)
- Dart SDK
- Android Studio / VS Code
- Cuenta de Firebase

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/act5.git
cd act5
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
   - Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Habilitar Authentication (Email/Password)
   - Crear base de datos Firestore en modo prueba
   - Descargar archivos de configuración:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`

4. **Ejecutar la aplicación**
```bash
flutter run
```

5. **Inicializar datos de prueba**
   - Abrir la app
   - Ir a Configuración
   - Tocar "Inicializar Horarios"
   - Esperar ~30 segundos

---

## 📖 Uso de la Aplicación

### 1️⃣ Registro e Inicio de Sesión
1. Abrir la app
2. Tocar "¿No tienes cuenta? Regístrate"
3. Completar formulario de registro
4. Iniciar sesión con credenciales

### 2️⃣ Crear una Cita
1. En la pantalla de inicio, tocar "Agendar una Cita"
2. Seleccionar especialidad médica
3. Elegir fecha del calendario
4. Seleccionar horario disponible
5. Ingresar motivo de consulta
6. Confirmar creación

### 3️⃣ Ver Mis Citas
1. Tocar "Mis Citas" desde inicio
2. Filtrar por estado (opcional)
3. Ver lista de citas con actualización en tiempo real

### 4️⃣ Editar una Cita
1. Desde "Mis Citas", tocar una cita
2. Modificar estado, fecha, hora o motivo
3. Guardar cambios

### 5️⃣ Cancelar una Cita
1. Desde "Mis Citas", tocar una cita
2. Presionar botón de eliminar (ícono de basura)
3. Confirmar cancelación

---

## 🎯 Especialidades Médicas Disponibles

- 🫀 Cardiología
- 🧴 Dermatología
- 👶 Pediatría
- 👁️ Oftalmología
- 🧠 Neurología
- 🏥 Medicina General
- 👩‍⚕️ Ginecología

---

## 📊 Funcionalidades Técnicas

### Tiempo Real con Streams
```dart
StreamBuilder<List<AppointmentModel>>(
  stream: firestoreService.getPatientAppointmentsStream(uid),
  builder: (context, snapshot) {
    // UI se actualiza automáticamente
  },
)
```

### Validación de Horarios
- Previene doble asignación de slots
- Solo muestra horarios disponibles
- Marca slots como ocupados al agendar

### Manejo de Estados
- Pendiente: Cita creada
- Confirmada: Cita confirmada por médico
- Completada: Consulta realizada
- Cancelada: Cita cancelada

### Soft Delete
- Las citas canceladas se marcan como "cancelada"
- No se eliminan físicamente de la base de datos
- Permite auditoría y análisis histórico

---

## 🔒 Seguridad

- Autenticación con Firebase Authentication
- Reglas de seguridad de Firestore configuradas
- Validación de formularios del lado del cliente
- Confirmaciones para acciones destructivas
- Protección contra pérdida de datos (WillPopScope)

---

## 📸 Capturas de Pantalla

> **Nota**: Agregar capturas de pantalla en una carpeta `screenshots/`:
> - Pantalla de login
> - Pantalla de inicio
> - Lista de citas
> - Crear cita
> - Editar cita
> - Configuración

---

## 📝 Documentación Adicional

Para más detalles técnicos, consultar:
- [`reporte.md`](./reporte.md) - Reporte técnico completo
- [`FIRESTORE_README.md`](./FIRESTORE_README.md) - Documentación de Firestore

---

## 🐛 Problemas Conocidos

### Error de Índices Compuestos
**Solución**: La aplicación ordena y filtra datos en memoria para evitar crear índices compuestos en Firestore.

### Flutter Web
**Solución**: Si hay errores de inicialización, ejecutar:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔄 Mejoras Futuras

- [ ] Notificaciones push para recordatorios
- [ ] Chat en tiempo real con médicos
- [ ] Videollamadas para consultas virtuales
- [ ] Historial médico del paciente
- [ ] Integración con calendario del dispositivo
- [ ] Modo offline con caché local
- [ ] Panel de administración web
- [ ] Reportes y estadísticas
- [ ] Autenticación de dos factores
- [ ] Soporte multi-idioma

---

## 👨‍💻 Autor

**Proyecto desarrollado como parte de la actividad académica**

---

## 📄 Licencia

Este proyecto es de uso educativo.

---

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Firebase por la plataforma BaaS
- Material Design por las guías de UI/UX

---

## 📞 Soporte

Para reportar problemas o sugerencias, abrir un issue en el repositorio de GitHub.

---

**Versión**: 1.0.0
**Última actualización**: Octubre 2025
**Estado**: ✅ Funcional
