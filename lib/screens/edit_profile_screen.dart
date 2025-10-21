import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        UserModel? userData = await _firestoreService.getUser(user.uid);
        if (userData != null) {
          setState(() {
            _nameController.text = userData.nombre;
            _ageController.text = userData.edad.toString();
            _birthplaceController.text = userData.lugarNacimiento;
            _conditionsController.text = userData.padecimientos;
            _phoneController.text = userData.telefono ?? '';
          });
        }
      } catch (e) {
        // Si no existe el usuario en Firestore, los campos quedan vacíos
      } finally {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Guardar perfil en Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        nombre: _nameController.text.trim(),
        edad: int.parse(_ageController.text.trim()),
        lugarNacimiento: _birthplaceController.text.trim(),
        padecimientos: _conditionsController.text.trim(),
        telefono: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        fechaRegistro: DateTime.now(),
      );

      await _firestoreService.createOrUpdateUser(userModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente en Firestore'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _birthplaceController.dispose();
    _conditionsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Avatar del usuario
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.purple.shade400,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Email (solo lectura)
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Correo Electrónico',
                  content: user?.email ?? 'No disponible',
                  isReadOnly: true,
                ),

                const SizedBox(height: 20),

                // Campo de Nombre
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre Completo',
                  icon: Icons.person_outline,
                  hint: 'Ingresa tu nombre completo',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo de Edad
                _buildTextField(
                  controller: _ageController,
                  label: 'Edad',
                  icon: Icons.cake,
                  hint: 'Ingresa tu edad',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu edad';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 120) {
                      return 'Ingresa una edad válida';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo de Teléfono
                _buildTextField(
                  controller: _phoneController,
                  label: 'Número de Teléfono',
                  icon: Icons.phone,
                  hint: 'Ej: +52 55 1234 5678',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // El teléfono es opcional, no validamos
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo de Lugar de Nacimiento
                _buildTextField(
                  controller: _birthplaceController,
                  label: 'Lugar de Nacimiento',
                  icon: Icons.location_on,
                  hint: 'Ciudad, País',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu lugar de nacimiento';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo de Padecimientos
                _buildTextField(
                  controller: _conditionsController,
                  label: 'Padecimientos',
                  icon: Icons.medical_services,
                  hint: 'Ej: Diabetes, Hipertensión, Ninguno',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tus padecimientos o escribe "Ninguno"';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Botón de Guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isReadOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.purple),
          labelStyle: const TextStyle(color: Colors.purple),
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
