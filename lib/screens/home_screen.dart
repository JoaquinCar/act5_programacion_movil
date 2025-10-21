import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Obtener el nombre del usuario (parte antes del @)
    String userName = user?.email?.split('@')[0] ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Menu Principal'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const profile_page()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensaje de bienvenida
              Text(
                '¡Hola, $userName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿En qué podemos ayudarte?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              // Botones de acciones rápidas (scroll horizontal)
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función de agendar cita')),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.medical_services,
                      title: 'Consejos\nmédicos',
                      color: Colors.deepPurple,
                      onTap: () {
                        _showMedicalTipsDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Sección de Especialistas
              const Text(
                'Especialistas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              _buildSpecialistCard(
                icon: Icons.favorite,
                name: 'Dr. Carlos Ramírez',
                specialty: 'Cardiólogo',
                color: Colors.red,
              ),
              _buildSpecialistCard(
                icon: Icons.healing,
                name: 'Dra. Ana Martínez',
                specialty: 'Dermatóloga',
                color: Colors.orange,
              ),
              _buildSpecialistCard(
                icon: Icons.child_care,
                name: 'Dr. Luis Hernández',
                specialty: 'Pediatra',
                color: Colors.blue,
              ),
              _buildSpecialistCard(
                icon: Icons.remove_red_eye,
                name: 'Dra. María López',
                specialty: 'Oftalmóloga',
                color: Colors.teal,
              ),
              _buildSpecialistCard(
                icon: Icons.psychology,
                name: 'Dr. Jorge Sánchez',
                specialty: 'Neurólogo',
                color: Colors.purple,
              ),
              const SizedBox(height: 30),

              // Sección de Doctores Populares
              const Text(
                'Doctores Populares',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPopularDoctorCard(
                      icon: Icons.person,
                      name: 'Dr. Roberto Cruz',
                      specialty: 'Medicina General',
                      rating: '4.9',
                      color: Colors.purple,
                    ),
                    _buildPopularDoctorCard(
                      icon: Icons.person_outline,
                      name: 'Dra. Patricia Gómez',
                      specialty: 'Ginecóloga',
                      rating: '4.8',
                      color: Colors.pink,
                    ),
                    _buildPopularDoctorCard(
                      icon: Icons.person,
                      name: 'Dr. Fernando Ruiz',
                      specialty: 'Traumatólogo',
                      rating: '4.7',
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para botones de acción rápida
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para tarjetas de especialistas
  Widget _buildSpecialistCard({
    required IconData icon,
    required String name,
    required String specialty,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 35, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // Widget para tarjetas de doctores populares
  Widget _buildPopularDoctorCard({
    required IconData icon,
    required String name,
    required String specialty,
    required String rating,
    required Color color,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Diálogo de consejos médicos
  void _showMedicalTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.medical_services, color: Colors.purple),
              SizedBox(width: 10),
              Text('Consejos Médicos'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTipItem('Dolor de cabeza', 'Descansa en un lugar oscuro y silencioso, aplica compresas frías en la frente.'),
                _buildTipItem('Dolor de garganta', 'Haz gárgaras con agua tibia y sal, bebe líquidos calientes.'),
                _buildTipItem('Dolor muscular', 'Aplica hielo durante las primeras 48 horas, luego calor.'),
                _buildTipItem('Dolor de estómago', 'Come alimentos suaves, evita grasas y lácteos temporalmente.'),
                _buildTipItem('Fiebre leve', 'Mantente hidratado, descansa y toma baños de agua tibia.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

