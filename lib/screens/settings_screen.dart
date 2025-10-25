import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_init_data.dart';
import 'edit_profile_screen.dart';
import 'privacy_screen.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          // Opción de Perfil
          _buildSettingOption(
            context,
            icon: Icons.person,
            iconColor: Colors.blue,
            title: 'Perfil',
            subtitle: 'Edita tu información personal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Opción de Privacidad
          _buildSettingOption(
            context,
            icon: Icons.privacy_tip,
            iconColor: Colors.orange,
            title: 'Privacidad',
            subtitle: 'Políticas y configuración de privacidad',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Opción de Sobre Nosotros
          _buildSettingOption(
            context,
            icon: Icons.info,
            iconColor: Colors.teal,
            title: 'Sobre Nosotros',
            subtitle: 'Conoce más sobre nuestra aplicación',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutUsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // TEMPORAL: Inicializar datos de disponibilidad
          _buildSettingOption(
            context,
            icon: Icons.cloud_download,
            iconColor: Colors.green,
            title: 'Inicializar Horarios',
            subtitle: 'Cargar horarios del 25 oct al 10 nov 2025',
            onTap: () async {
              // Mostrar diálogo de confirmación
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.cloud_download, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Inicializar Horarios'),
                      ],
                    ),
                    content: const Text(
                      '¿Deseas cargar los horarios disponibles de los médicos? Esto creará slots de citas del 25 de octubre al 10 de noviembre de 2025.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('Inicializar'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  final initData = FirestoreInitData();

                  // Inicializar datos (sin verificar, permite agregar nuevos horarios)
                  await initData.initializeDoctorAvailability();

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Cerrar indicador de carga

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Horarios cargados exitosamente (25 oct - 10 nov)'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Cerrar indicador si está abierto

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cargar horarios: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),

          const SizedBox(height: 12),

          // Opción de Cerrar Sesión
          _buildSettingOption(
            context,
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de tu cuenta',
            onTap: () async {
              // Mostrar diálogo de confirmación
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text(
                      '¿Estás seguro de que deseas cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
                await authService.signOut();
                // El StreamBuilder en main.dart detectará automáticamente
                // el cambio y mostrará el LoginScreen
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
