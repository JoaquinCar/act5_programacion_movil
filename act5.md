# Guía: Pantalla de Inicio de Sesión en Flutter

## Descripción del Proyecto
Desarrollo de una aplicación Flutter con una pantalla de inicio de sesión funcional, validación de formularios, **integración con Firebase Authentication** y diseño inspirado en aplicaciones de citas médicas (fondo blanco, botones morados).

## Requisitos
- Flutter SDK instalado
- Editor de código (VS Code o Android Studio)
- Emulador o dispositivo físico para pruebas
- 2
- Cuenta de Firebase (gratuita)
- Node.js instalado (para Firebase CLI)

---
## Paso 1: Verificar la Estructura del Proyecto

Asegúrate de que tu proyecto Flutter esté creado correctamente. La estructura básica debe verse así:

```
act5/
├── lib/
│   └── main.dart
├── pubspec.yaml
└── ...
```

---

## Paso 2: Configurar Dependencias (pubspec.yaml)

Abre el archivo `pubspec.yaml` y agrega las dependencias de Firebase:

```yaml
name: act5
description: Aplicación de inicio de sesión con Flutter

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

Después de modificar el archivo, ejecuta:
```bash
flutter pub get
```

---

## Paso 3: Configurar Firebase

### 3.1 Instalar Firebase CLI y FlutterFire CLI

Primero, instala las herramientas necesarias:

```bash
# Instalar Firebase CLI (requiere Node.js)
npm install -g firebase-tools

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli
```

Verifica la instalación:
```bash
firebase --version
flutterfire --version
```

### 3.2 Iniciar Sesión en Firebase

```bash
firebase login
```

Se abrirá tu navegador para que inicies sesión con tu cuenta de Google.

### 3.3 Crear y Configurar Proyecto Firebase AUTOMÁTICAMENTE

Este comando hace TODO el trabajo por ti (crea el proyecto, configura Android/iOS, descarga archivos):

```bash
flutterfire configure --project=act5-login-app
```

El comando te preguntará:
1. **¿Crear nuevo proyecto?** → Sí (Y)
2. **¿Qué plataformas configurar?** → Selecciona:
   - [x] android
   - [ ] ios (opcional)
   - [ ] macos (opcional)
   - [ ] web (opcional)

**¿Qué hace este comando automáticamente?**
- ✅ Crea el proyecto en Firebase Console
- ✅ Genera y descarga `google-services.json` (Android)
- ✅ Genera y descarga `GoogleService-Info.plist` (iOS)
- ✅ Crea el archivo `firebase_options.dart` con toda la configuración
- ✅ Configura los archivos de Gradle automáticamente

### 3.4 Configurar Gradle (Solo si es necesario)

Si `flutterfire configure` no configuró Gradle automáticamente, haz lo siguiente:

#### android/build.gradle (nivel proyecto):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Agrega esta línea
    }
}
```

#### android/app/build.gradle (nivel app):
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Agrega esta línea
}

android {
    defaultConfig {
        minSdkVersion 21  // Asegúrate que sea al menos 21
    }
}
```

### 3.5 Habilitar Email/Password en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto "act5-login-app"
3. En el menú lateral, ve a **Authentication**
4. Click en "Get Started" o "Comenzar"
5. Ve a la pestaña "Sign-in method"
6. Click en "Email/Password"
7. **Habilita** la primera opción (Email/Password)
8. Click en "Guardar"

### 3.6 Verificar la Configuración

Verifica que se crearon los archivos:
- ✅ `lib/firebase_options.dart` (generado automáticamente)
- ✅ `android/app/google-services.json` (Android)
- ✅ `ios/Runner/GoogleService-Info.plist` (iOS, si seleccionaste)

**¡Listo!** Firebase está configurado automáticamente.

---

## Paso 4: Crear la Estructura de Archivos

Organiza tu código creando la siguiente estructura en la carpeta `lib/`:

```
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── home_screen.dart
├── services/
│   └── auth_service.dart
└── widgets/
    ├── custom_text_field.dart
    └── custom_button.dart
```
---

## Paso 5: Configurar el Archivo Principal (main.dart)

Edita `lib/main.dart` para inicializar Firebase con las opciones generadas:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';  // Archivo generado por flutterfire configure
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Usa las opciones generadas
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si el usuario está autenticado, muestra HomeScreen
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // Si no está autenticado, muestra LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
```

---

## Paso 6: Crear el Servicio de Autenticación

Crea el archivo `lib/services/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  // Registrar nuevo usuario
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Recuperar contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Manejo de excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
```

---

## Paso 7: Crear el Widget de Campo de Texto Personalizado

Crea el archivo `lib/widgets/custom_text_field.dart`:

```dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.purple) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
```

---

## Paso 8: Crear el Widget de Botón Personalizado

Crea el archivo `lib/widgets/custom_button.dart`:

```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.purple,
    this.textColor = Colors.white,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.purple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
    );
  }
}
```

---

## Paso 9: Crear la Pantalla de Login con Firebase

Crea el archivo `lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingrese un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Método para iniciar sesión con Firebase
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inicio de sesión exitoso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Método para recuperar contraseña
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese su correo electrónico primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Correo Enviado'),
            content: Text(
              'Se ha enviado un enlace de recuperación a ${_emailController.text}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para navegar a la pantalla de registro
  void _handleCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo o ícono
                  Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.purple.shade400,
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtítulo
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 1. Campo de correo electrónico
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // 2. Campo de contraseña
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    hintText: '********',
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 10),

                  // 3. Botón de "Olvidó su contraseña"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: const Text(
                        '¿Olvidó su contraseña?',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Botón de iniciar sesión (con indicador de carga)
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Iniciar Sesión',
                          onPressed: _handleLogin,
                        ),
                  const SizedBox(height: 20),

                  // Divisor
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'O',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Botón de "Crear una cuenta nueva"
                  CustomButton(
                    text: 'Crear Cuenta Nueva',
                    onPressed: _isLoading ? () {} : _handleCreateAccount,
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Paso 10: Crear la Pantalla de Registro

Crea el archivo `lib/screens/register_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingrese un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirme su contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add,
                    size: 80,
                    color: Colors.purple.shade400,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Registro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Crea tu cuenta para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    hintText: '********',
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmar Contraseña',
                    hintText: '********',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Crear Cuenta',
                          onPressed: _handleRegister,
                        ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Paso 11: Crear la Pantalla de Inicio (Home)

Crea el archivo `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.purple.shade400,
              ),
              const SizedBox(height: 30),

              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Has iniciado sesión correctamente',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Información de la cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${user?.email ?? "No disponible"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'UID: ${user?.uid ?? "No disponible"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authService.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Paso 12: Ejecutar la Aplicación

### Opción 1: Usando el terminal
```bash
flutter run
```

### Opción 2: Usando VS Code
- Presiona `F5` o usa el botón "Run" en la esquina superior derecha

### Opción 3: Usando Android Studio
- Click en el botón "Run" (triángulo verde)

---

## Paso 13: Probar la Aplicación con Firebase

### 13.1 Crear un Usuario de Prueba

1. Ejecuta la aplicación: `flutter run`
2. Click en "Crear Cuenta Nueva"
3. Ingresa un correo (ej: test@example.com)
4. Ingresa una contraseña de al menos 6 caracteres
5. Confirma la contraseña
6. Click en "Crear Cuenta"
7. La app debe crear el usuario y llevarte al HomeScreen automáticamente

### 13.2 Verificar en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Authentication** > **Users**
4. Verifica que el usuario que creaste aparezca en la lista

### 13.3 Prueba las Funcionalidades

**Registro:**
- Crear cuenta con email y contraseña
- Validación de campos vacíos
- Validación de formato de email
- Validación de contraseñas que coincidan
- Validación de longitud mínima de contraseña

**Login:**
- Iniciar sesión con email y contraseña registrados
- Error al ingresar credenciales incorrectas
- Validación de campos vacíos
- Indicador de carga durante el proceso

**Recuperar Contraseña:**
- Click en "¿Olvidó su contraseña?"
- Ingresar email registrado
- Verificar que llegue el correo de recuperación

**Cerrar Sesión:**
- Click en el botón de logout en HomeScreen
- Verificar que regrese al LoginScreen

**Persistencia de Sesión:**
- Cierra la app completamente
- Vuelve a abrirla
- Debe seguir en HomeScreen (sesión persistente)

---

## Paso 14: Preparar para GitHub

### 1. Inicializar Git (si no lo has hecho)
```bash
git init
```

### 2. Crear archivo .gitignore
Asegúrate de tener un archivo `.gitignore` con el siguiente contenido:

```
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Firebase (NO subir archivos sensibles por seguridad)
# google-services.json contiene información sensible del proyecto
**/android/app/google-services.json
**/ios/Runner/GoogleService-Info.plist
```

**Nota sobre firebase_options.dart:** Este archivo SÍ se puede subir a GitHub ya que no contiene información sensible. Fue generado por `flutterfire configure`.

### 3. Hacer commit de los cambios
```bash
git add .
git commit -m "feat: Implementar login con Firebase Authentication"
```

**IMPORTANTE:** No subir `google-services.json` a GitHub (ya está en .gitignore)

### 4. Crear repositorio en GitHub
- Ve a https://github.com/new
- Crea un nuevo repositorio llamado `flutter-login-app` (o el nombre que prefieras)
- No inicialices con README, .gitignore o licencia

### 5. Conectar y subir tu proyecto
```bash
git remote add origin https://github.com/TU_USUARIO/flutter-login-app.git
git branch -M main
git push -u origin main
```

---

## Paso 15: Tomar Capturas de Pantalla

Crea una carpeta `screenshots/` en tu proyecto y toma las siguientes capturas:

### Capturas Requeridas:

1. **Login Screen** - Pantalla de inicio de sesión vacía
2. **Validación de Email** - Error al ingresar correo inválido
3. **Validación de Contraseña** - Error al ingresar contraseña corta
4. **Diálogo Olvidó Contraseña** - Ventana emergente de recuperación
5. **Register Screen** - Pantalla de registro de cuenta
6. **Validación de Contraseñas No Coinciden** - Error en registro
7. **Home Screen** - Pantalla después de login exitoso
8. **Firebase Console - Users** - Captura de la consola de Firebase mostrando los usuarios registrados
9. **Login Exitoso** - SnackBar de inicio de sesión exitoso
10. **Cerrar Sesión** - Botón de logout funcionando

### Cómo tomar capturas en el emulador:

**Android Studio:**
- Click en el ícono de cámara en la barra lateral del emulador

**VS Code:**
- Usa las herramientas del emulador de Android o captura con tu sistema operativo

Guarda todas las capturas en la carpeta `screenshots/`.

---

## Paso 16: Crear Reporte Explicativo

Crea un archivo `REPORTE.md` con el siguiente contenido:

```markdown
# Reporte: Aplicación de Inicio de Sesión con Firebase en Flutter

## Información del Proyecto
- **Nombre**: Act5 - Login App con Firebase Authentication
- **Tecnología**: Flutter + Firebase
- **Fecha**: [Tu fecha]
- **Autor**: [Tu nombre]
- **Repositorio GitHub**: [Tu link]

## Descripción
Aplicación móvil desarrollada en Flutter que implementa un sistema completo de autenticación con Firebase Authentication, incluyendo registro, inicio de sesión, recuperación de contraseña y persistencia de sesión. El diseño está inspirado en aplicaciones de citas médicas con colores morado y blanco.

## Elementos Implementados

### Requisitos Cumplidos (5 elementos mínimos):

#### 1. Campo de Correo Electrónico
- Validación de formato de email con expresión regular
- Ícono visual de sobre (email)
- Mensaje de error descriptivo
- Integrado con Firebase Authentication

#### 2. Campo de Contraseña
- Texto oculto (obscureText) para seguridad
- Validación de longitud mínima (6 caracteres)
- Ícono visual de candado
- Validación en Firebase

#### 3. Botón "Olvidó su Contraseña"
- Implementado como TextButton
- Envía correo real de recuperación vía Firebase
- Muestra diálogo de confirmación
- Manejo de errores

#### 4. Botón "Crear Cuenta Nueva"
- Estilo outlined con borde morado
- Navega a pantalla de registro funcional
- Crea usuarios reales en Firebase

#### 5. Botón "Iniciar Sesión"
- Botón principal con fondo morado
- Valida formulario antes de proceder
- Autentica con Firebase Authentication
- Indicador de carga durante el proceso
- Manejo de errores con mensajes descriptivos

## Características Técnicas

### Autenticación con Firebase
- **Registro de usuarios**: Creación de cuentas con email/password
- **Inicio de sesión**: Autenticación con credenciales de Firebase
- **Recuperación de contraseña**: Envío de correos de recuperación
- **Persistencia de sesión**: Usuario permanece logueado al cerrar/abrir app
- **Cerrar sesión**: Funcionalidad completa de logout
- **Manejo de errores**: Mensajes descriptivos para todos los casos

### Validaciones
- **Email**:
  - Campo obligatorio
  - Formato válido (usuario@dominio.com)
  - Verificación en Firebase
- **Contraseña**:
  - Mínimo 6 caracteres
  - Campo obligatorio
- **Confirmar Contraseña** (Registro):
  - Debe coincidir con la contraseña
  - Validación en tiempo real

### Diseño
- **Tema principal**: Morado (#9C27B0)
- **Fondo**: Blanco
- **Bordes redondeados** en campos y botones
- **Diseño responsivo** con SingleChildScrollView
- **Iconos visuales** para mejor UX
- **Indicadores de carga** durante operaciones asíncronas
- **SnackBars** para feedback al usuario

### Arquitectura del Proyecto
```
lib/
├── main.dart (inicialización de Firebase y rutas)
├── screens/
│   ├── login_screen.dart (pantalla de inicio de sesión)
│   ├── register_screen.dart (pantalla de registro)
│   └── home_screen.dart (pantalla principal después de login)
├── services/
│   └── auth_service.dart (lógica de autenticación)
└── widgets/
    ├── custom_text_field.dart (campo de texto reutilizable)
    └── custom_button.dart (botón reutilizable)
```

### Dependencias Utilizadas
```yaml
firebase_core: ^3.8.1      # Core de Firebase
firebase_auth: ^5.3.3      # Autenticación de Firebase
```

## Funcionalidades Implementadas

### 1. Sistema de Registro
- Formulario con validación
- Confirmación de contraseña
- Creación de cuenta en Firebase
- Navegación automática al home después del registro

### 2. Sistema de Login
- Validación de credenciales
- Autenticación con Firebase
- Mensajes de error descriptivos
- Estado de carga visual

### 3. Recuperación de Contraseña
- Validación de email
- Envío de correo de recuperación vía Firebase
- Confirmación visual del envío

### 4. Persistencia de Sesión
- El usuario permanece logueado al cerrar la app
- Verificación automática del estado de autenticación
- Redirección según el estado de sesión

### 5. Pantalla Home
- Muestra información del usuario
- Email y UID del usuario logueado
- Botón de cerrar sesión
- Diseño consistente con el tema

## Capturas de Pantalla
[Ver carpeta screenshots/]

1. Pantalla de Login
2. Validaciones de formulario
3. Pantalla de Registro
4. Home Screen con usuario logueado
5. Firebase Console mostrando usuarios registrados
6. Recuperación de contraseña
7. Mensajes de error y éxito

## Pruebas Realizadas

### Casos de Prueba Exitosos:
- ✅ Registro de nuevo usuario
- ✅ Login con credenciales correctas
- ✅ Error al usar credenciales incorrectas
- ✅ Envío de correo de recuperación
- ✅ Persistencia de sesión
- ✅ Cierre de sesión
- ✅ Validaciones de formulario
- ✅ Manejo de errores de red

## Configuración de Firebase

### Servicios Habilitados:
- Firebase Authentication (Email/Password)

### Archivos de Configuración:
- `android/app/google-services.json` (Android)
- Configuración en `android/build.gradle`
- Configuración en `android/app/build.gradle`

## Conclusiones

La aplicación cumple exitosamente con todos los requisitos solicitados e incluye funcionalidad real de autenticación mediante Firebase. Se implementó:

1. ✅ Los 5 elementos requeridos de login
2. ✅ Interfaz visual inspirada en apps médicas (morado/blanco)
3. ✅ Validación funcional de formularios
4. ✅ **Autenticación real con Firebase**
5. ✅ Sistema de registro funcional
6. ✅ Recuperación de contraseña real
7. ✅ Persistencia de sesión
8. ✅ Manejo profesional de errores

El código está bien organizado siguiendo principios SOLID, con componentes reutilizables y separación de responsabilidades. La arquitectura facilita el mantenimiento y la escalabilidad del proyecto.

## Posibles Mejoras Futuras
- Autenticación con Google Sign-In
- Autenticación con Facebook
- Verificación de email
- Perfil de usuario editable
- Cambio de contraseña desde la app
- Autenticación de dos factores
- Modo oscuro
- Animaciones y transiciones mejoradas
- Soporte para múltiples idiomas
```

---

## Checklist Final

Antes de entregar, verifica:

### Funcionalidad
- [ ] Firebase configurado correctamente
- [ ] La aplicación se ejecuta sin errores
- [ ] Los 5 elementos requeridos están implementados
- [ ] **Registro de usuarios funciona con Firebase**
- [ ] **Login funciona con Firebase**
- [ ] **Recuperación de contraseña funciona**
- [ ] **Persistencia de sesión funciona**
- [ ] Las validaciones funcionan correctamente
- [ ] El diseño usa colores morado y blanco
- [ ] Los usuarios aparecen en Firebase Console

### Código y Documentación
- [ ] El código está organizado en carpetas (screens, services, widgets)
- [ ] Proyecto subido a GitHub
- [ ] README.md actualizado con instrucciones
- [ ] Capturas de pantalla tomadas (mínimo 10)
- [ ] Reporte explicativo completado
- [ ] Link de GitHub funcionando
- [ ] google-services.json NO subido a GitHub

### Pruebas Realizadas
- [ ] Creado al menos un usuario de prueba
- [ ] Login exitoso con credenciales correctas
- [ ] Error con credenciales incorrectas
- [ ] Recuperación de contraseña enviada
- [ ] Sesión persiste al cerrar/abrir app
- [ ] Cerrar sesión funciona correctamente

---

## Recursos Adicionales

### Documentación Oficial
- [Documentación oficial de Flutter](https://docs.flutter.dev/)
- [Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Auth](https://firebase.flutter.dev/docs/auth/usage)
- [Material Design - Text Fields](https://m3.material.io/components/text-fields)
- [Flutter Widgets Catalog](https://docs.flutter.dev/ui/widgets)

### Tutoriales Útiles
- [Firebase Auth con Flutter - Guía oficial](https://firebase.google.com/docs/auth/flutter/start)
- [Manejo de estados en Flutter](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

---

## Problemas Comunes y Soluciones

### Problemas de Firebase y FlutterFire CLI

#### Error: "flutterfire: command not found"
**Causa**: FlutterFire CLI no está instalado o no está en el PATH.
**Solución**:
1. Instala FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Asegúrate de que el PATH esté configurado correctamente
3. Si usas Windows, reinicia el terminal/PowerShell
4. Verifica la instalación: `flutterfire --version`

#### Error al ejecutar "flutterfire configure"
**Causa**: No has iniciado sesión en Firebase o no tienes permisos.
**Solución**:
1. Ejecuta `firebase login`
2. Inicia sesión con tu cuenta de Google
3. Verifica que tengas permisos para crear proyectos en Firebase
4. Intenta de nuevo con `flutterfire configure --project=act5-login-app`

#### firebase_options.dart no se genera
**Causa**: El comando no completó correctamente.
**Solución**:
1. Verifica que seleccionaste al menos una plataforma (Android)
2. Ejecuta de nuevo `flutterfire configure`
3. Si persiste, crea el proyecto manualmente en Firebase Console
4. Luego ejecuta `flutterfire configure` seleccionando el proyecto existente

#### Error: "MissingPluginException"
**Causa**: Firebase no está inicializado correctamente.
**Solución**:
1. Verifica que `firebase_core` y `firebase_auth` estén en pubspec.yaml
2. Ejecuta `flutter pub get`
3. Reinicia la app completamente
4. Si persiste, ejecuta `flutter clean` y luego `flutter pub get`

#### Error: "PlatformException (null-error)"
**Causa**: google-services.json no está en la ubicación correcta.
**Solución**:
1. Verifica que `google-services.json` esté en `android/app/`
2. Verifica que el package name en Firebase coincida con el de tu app
3. Sincroniza Gradle en Android Studio

#### Error: "FirebaseException: An internal error has occurred"
**Causa**: Problema de configuración o red.
**Solución**:
1. Verifica tu conexión a internet
2. Revisa que Email/Password esté habilitado en Firebase Console
3. Limpia y reconstruye el proyecto

#### Error: "INVALID_LOGIN_CREDENTIALS"
**Causa**: El usuario no existe o la contraseña es incorrecta.
**Solución**: Este es un error esperado. Asegúrate de que el usuario esté registrado en Firebase Console.

#### Error: "network-request-failed"
**Causa**: Sin conexión a internet.
**Solución**: Verifica la conexión del emulador/dispositivo.

### Problemas de Flutter

#### Error: "A RenderFlex overflowed"
**Solución**: Asegúrate de usar `SingleChildScrollView` en la pantalla principal.

#### Error: "The getter 'widget' was called on null"
**Solución**: Verifica que estés usando `StatefulWidget` correctamente y que no accedas al widget antes de que esté inicializado.

#### Error en validación de formulario
**Solución**: Asegúrate de que el `_formKey` esté asignado al Form y que llames a `validate()` correctamente.

#### El teclado cubre los campos
**Solución**: Usa `SingleChildScrollView` y `SafeArea` como en el ejemplo.

#### Error: "Gradle build failed"
**Solución**:
1. Verifica que `minSdkVersion` sea al menos 21
2. Asegúrate de tener las configuraciones correctas en build.gradle
3. Sincroniza Gradle
4. Ejecuta `flutter clean`

### Problemas de Dependencias

#### Error al ejecutar `flutter pub get`
**Solución**:
1. Verifica que las versiones de las dependencias sean compatibles
2. Ejecuta `flutter pub upgrade`
3. Si persiste, borra `pubspec.lock` y vuelve a ejecutar `flutter pub get`

---

## Consejos Importantes

1. **Seguridad**: Nunca subas `google-services.json` a un repositorio público
2. **Testing**: Siempre prueba con múltiples usuarios
3. **Errores**: Implementa manejo de errores adecuado
4. **UX**: Usa indicadores de carga para operaciones asíncronas
5. **Validación**: Valida en cliente Y en servidor (Firebase)
6. **Persistencia**: Firebase maneja la persistencia automáticamente
7. **Logs**: Revisa los logs del emulador para debugging

---

## Entrega del Proyecto

### Qué entregar:
1. **Link de GitHub** con el código completo
2. **Capturas de pantalla** (mínimo 10)
3. **Reporte explicativo** (REPORTE.md)
4. **README.md** con instrucciones de instalación

### Formato del README.md sugerido:

```markdown
# Act5 - Login App con Firebase

Aplicación de inicio de sesión con Flutter y Firebase Authentication.

## Características
- Registro de usuarios
- Inicio de sesión
- Recuperación de contraseña
- Persistencia de sesión
- Diseño inspirado en apps médicas

## Tecnologías
- Flutter
- Firebase Authentication
- Dart

## Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Configurar tu propio proyecto de Firebase
4. Agregar tu `google-services.json` en `android/app/`
5. Ejecutar `flutter run`

## Autor
[Tu nombre]

## Screenshots
[Agregar capturas]
```

---

## Paso Extra: Integración con Cloud Firestore (MVP - 3 Colecciones)

### ¿Qué es Cloud Firestore?
Firestore es una base de datos NoSQL en la nube de Firebase que permite almacenar y sincronizar datos en tiempo real.

### Colecciones Implementadas

Para el MVP (Producto Mínimo Viable), se han implementado 3 colecciones principales:

#### 1. **Colección `usuarios`**
Almacena la información personal de cada usuario.

**Campos:**
- `email`: Correo electrónico del usuario
- `nombre`: Nombre completo
- `edad`: Edad del usuario
- `lugar_nacimiento`: Ciudad y país de nacimiento
- `padecimientos`: Condiciones médicas actuales
- `telefono`: Número de teléfono (opcional)
- `fecha_registro`: Fecha de creación del perfil

**Uso:** Se guarda automáticamente cuando el usuario completa su perfil en "Configuración → Perfil".

#### 2. **Colección `citas`**
Guarda todas las citas programadas.

**Campos:**
- `paciente_id`: UID del paciente
- `medico_id`: ID del médico
- `medico_nombre`: Nombre del médico
- `especialidad`: Especialidad médica
- `fecha_hora`: Fecha y hora de la cita
- `motivo`: Razón de la consulta
- `estado`: Estado de la cita (pendiente, confirmada, cancelada, completada)
- `fecha_creacion`: Fecha en que se agendó

**Uso:** Se crea cuando un usuario agenda una cita con un especialista.

#### 3. **Colección `disponibilidad_medicos`**
Almacena los horarios disponibles de cada médico.

**Campos:**
- `medico_id`: ID único del médico
- `medico_nombre`: Nombre del médico
- `especialidad`: Especialidad
- `fecha`: Fecha del horario disponible
- `hora_inicio`: Hora de inicio (ej: "09:00")
- `hora_fin`: Hora de fin (ej: "10:00")
- `esta_disponible`: `true` si está libre, `false` si está ocupado

**Uso:** Permite validar qué horarios están disponibles antes de agendar una cita.

### Dependencia Agregada

```yaml
dependencies:
  cloud_firestore: ^5.5.0
```

### Servicios Creados

#### **FirestoreService** (`lib/services/firestore_service.dart`)
Servicio principal con todas las operaciones CRUD:

**Usuarios:**
- `createOrUpdateUser(UserModel user)` - Crear/actualizar usuario
- `getUser(String uid)` - Obtener usuario por UID
- `getUserStream(String uid)` - Stream en tiempo real

**Citas:**
- `createAppointment(AppointmentModel appointment)` - Crear cita
- `getPatientAppointments(String pacienteId)` - Obtener citas del paciente
- `getDoctorAppointments(String medicoId)` - Obtener citas del médico
- `updateAppointmentStatus(String citaId, String nuevoEstado)` - Cambiar estado
- `cancelAppointment(String citaId)` - Cancelar cita
- `getPatientAppointmentsStream(String pacienteId)` - Stream en tiempo real

**Disponibilidad:**
- `createDoctorAvailability(DoctorAvailabilityModel availability)` - Crear horario
- `getDoctorAvailability({required String medicoId, required DateTime fecha})` - Obtener horarios de un médico
- `getAvailableSlots({DateTime? fecha, String? especialidad})` - Obtener horarios disponibles
- `markSlotAsUnavailable(String availabilityId)` - Marcar como ocupado
- `markSlotAsAvailable(String availabilityId)` - Marcar como disponible

**Operaciones Combinadas:**
- `bookAppointment({required AppointmentModel appointment, required String availabilityId})` - Agendar cita completa
- `cancelAppointmentAndFreeSlot({required String citaId, required String availabilityId})` - Cancelar y liberar horario

### Modelos de Datos

Ubicados en `lib/models/`:

- **`user_model.dart`** - Modelo de usuario
- **`appointment_model.dart`** - Modelo de cita
- **`doctor_availability_model.dart`** - Modelo de disponibilidad

Cada modelo tiene:
- Constructor con campos requeridos
- `fromFirestore()` - Convierte de Firestore a Dart
- `toFirestore()` - Convierte de Dart a Firestore

### Script de Inicialización de Datos

**FirestoreInitData** (`lib/services/firestore_init_data.dart`)

Permite poblar la base de datos con datos de ejemplo:

```dart
FirestoreInitData initData = FirestoreInitData();

// Inicializar solo si no hay datos
await initData.initializeIfNeeded();
```

Esto crea:
- 7 médicos con diferentes especialidades
- 7 horarios diarios (9:00 AM - 6:00 PM)
- 7 días de disponibilidad
- **Total: 343 slots de citas**

### Integración Actual

✅ **EditProfileScreen** ya está integrado con Firestore:
- Carga datos existentes del usuario al abrir
- Guarda/actualiza datos en Firestore al presionar "Guardar Cambios"
- Muestra indicador de carga durante el proceso
- Maneja errores con mensajes informativos

### Reglas de Seguridad Recomendadas

En la consola de Firebase → Firestore → Reglas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuarios solo pueden leer/escribir su propio documento
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Citas - solo el paciente puede ver/modificar sus citas
    match /citas/{citaId} {
      allow read: if request.auth != null &&
                     resource.data.paciente_id == request.auth.uid;
      allow create: if request.auth != null &&
                       request.resource.data.paciente_id == request.auth.uid;
      allow update, delete: if request.auth != null &&
                               resource.data.paciente_id == request.auth.uid;
    }

    // Disponibilidad - todos pueden leer, solo admins escribir
    match /disponibilidad_medicos/{slotId} {
      allow read: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

### Configurar Firestore en Firebase Console

1. Ve a la consola de Firebase: https://console.firebase.google.com
2. Selecciona tu proyecto (`act5-login-app`)
3. En el menú lateral, haz clic en "Firestore Database"
4. Haz clic en "Crear base de datos"
5. Selecciona "Iniciar en modo de prueba" (para desarrollo)
6. Elige la ubicación más cercana (ej: `us-central1`)
7. Haz clic en "Habilitar"

### Probar la Integración

1. Ejecuta la app: `flutter run`
2. Inicia sesión o crea una cuenta
3. Ve a **Configuración → Perfil**
4. Completa los campos:
   - Nombre
   - Edad
   - Lugar de nacimiento
   - Padecimientos
5. Presiona "Guardar Cambios"
6. Verifica en Firebase Console → Firestore que se creó el documento en la colección `usuarios`

### Documentación Completa

Para más detalles sobre el uso de las colecciones, consulta el archivo **`FIRESTORE_README.md`** en la raíz del proyecto.

---

**¡Éxito con tu proyecto! Ahora tienes una aplicación completamente funcional con autenticación Firebase y base de datos Firestore.**
