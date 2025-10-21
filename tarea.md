# Actividad 5 - Aplicación de Login con Firebase

## Información del Proyecto
- **Repositorio**: https://github.com/JoaquinCar/act5_programacion_movil
- **Tecnologías**: Flutter + Firebase Authentication
- **Plataformas**: Android, iOS, Web

---

## Descripción del Proyecto

Desarrollé una aplicación de inicio de sesión completa usando Flutter y Firebase Authentication. La app permite a los usuarios registrarse, iniciar sesión y recuperar su contraseña de forma real, ya que está conectada directamente con Firebase.

El diseño está inspirado en aplicaciones médicas, usando colores morado y blanco para darle un aspecto profesional pero amigable.

---

## Elementos Implementados

### 1. Campo de Correo Electrónico
Tiene validación para verificar que el correo tenga un formato válido (usuario@dominio.com). Si el usuario intenta enviar un correo inválido, le muestra un mensaje de error claro.

### 2. Campo de Contraseña
La contraseña se muestra oculta (con asteriscos) por seguridad. También valida que tenga al menos 6 caracteres, que es el mínimo que requiere Firebase.

### 3. Botón "Olvidó su contraseña"
Este botón funciona de verdad - cuando el usuario da click, Firebase envía un correo electrónico con un link para recuperar la contraseña. Primero valida que el usuario haya puesto su correo en el campo correspondiente.

### 4. Botón "Crear Cuenta Nueva"
Lleva a una pantalla de registro donde el usuario puede crear una cuenta nueva. Incluye un campo adicional para confirmar la contraseña y valida que ambas coincidan antes de crear la cuenta.

### 5. Botón "Iniciar Sesión"
Es el botón principal que autentica al usuario con Firebase. Muestra un indicador de carga mientras se procesa la solicitud y maneja los errores de forma clara (por ejemplo, si la contraseña es incorrecta o el usuario no existe).

---

## Proceso de Desarrollo

### Configuración Inicial
Primero creé el proyecto en Flutter y luego configuré Firebase usando el comando `flutterfire configure`, que automatiza toda la configuración y genera los archivos necesarios. Esto incluye el `firebase_options.dart` que contiene todas las claves de configuración.

### Arquitectura del Código
Organicé el código en carpetas para mantenerlo limpio:
- **screens/**: Las tres pantallas (Login, Registro y Home)
- **services/**: El servicio de autenticación que maneja toda la comunicación con Firebase
- **widgets/**: Componentes reutilizables como los campos de texto y botones personalizados

### Integración con Firebase
El servicio de autenticación (`auth_service.dart`) maneja:
- Registro de nuevos usuarios
- Inicio de sesión
- Recuperación de contraseña
- Cierre de sesión
- Manejo de errores traducidos al español

También implementé persistencia de sesión, lo que significa que si cierras la app y la vuelves a abrir, seguirás con tu sesión iniciada.

### Pantallas
**Login Screen**: Es la primera pantalla que ve el usuario. Tiene los dos campos principales (email y contraseña), el botón para recuperar contraseña y el botón para crear cuenta.

**Register Screen**: Permite crear cuentas nuevas. Incluye validación para asegurar que las contraseñas coincidan y que el email sea válido.

**Home Screen**: Es la pantalla que ve el usuario después de iniciar sesión. Muestra su información (email y UID de Firebase) y tiene un botón para cerrar sesión.

### Validaciones
Todas las validaciones funcionan en tiempo real:
- Email con formato válido
- Contraseña mínima de 6 caracteres
- Contraseñas que coincidan en el registro
- Mensajes de error específicos de Firebase (usuario no existe, contraseña incorrecta, etc.)

---

## Funcionalidades Destacadas

### Autenticación Real
A diferencia de un simple mock-up, esta app se conecta con Firebase y crea usuarios reales. Puedes verlos en la consola de Firebase después de registrarte.

### Manejo de Errores
Implementé un sistema que traduce los códigos de error de Firebase al español y muestra mensajes claros al usuario. Por ejemplo, en lugar de "user-not-found", muestra "No existe una cuenta con este correo electrónico".

### Persistencia de Sesión
Firebase maneja automáticamente la persistencia, así que el usuario no tiene que iniciar sesión cada vez que abre la app.

### Diseño Responsivo
Usé `SingleChildScrollView` para que el teclado no tape los campos cuando aparece, y todos los elementos se adaptan bien a diferentes tamaños de pantalla.

---

## Dificultades y Soluciones

### Configuración de Firebase
Al principio intenté configurar Firebase manualmente, pero fue más complicado de lo esperado. Decidí usar `flutterfire configure` que automatiza todo el proceso y es el método oficial recomendado.

### Manejo de Assets
Tuve algunos problemas con las rutas de las imágenes en Flutter Web porque a veces duplicaba la carpeta "assets". Lo resolví configurando el `pubspec.yaml` para incluir toda la carpeta de imágenes en lugar de listar cada archivo individualmente.

### Validaciones
Quería que las validaciones fueran claras pero no molestas. Implementé validación al enviar el formulario en lugar de en cada tecla, para no interrumpir al usuario mientras escribe.

---

## Conclusión

Logré crear una aplicación funcional de login que cumple con todos los requisitos y va más allá al incluir autenticación real con Firebase. La app está bien organizada, tiene buen manejo de errores y una interfaz limpia y profesional.

El proyecto me ayudó a entender mejor cómo funcionan los servicios de autenticación en aplicaciones reales y cómo organizar el código de forma que sea fácil de mantener y escalar.

---

## Capturas de Pantalla

_(Ver carpeta screenshots/ en el repositorio)_

1. Pantalla de Login
2. Validaciones de formulario
3. Pantalla de Registro
4. Pantalla Home después del login
5. Consola de Firebase mostrando usuarios registrados
