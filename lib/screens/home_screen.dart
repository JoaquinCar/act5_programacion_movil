import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'create_appointment_screen.dart';
import 'appointments_screen.dart';

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
        title: const Text(
          'Menú Principal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade600, Colors.blue.shade600],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, size: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const profile_page()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con degradado
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade600, Colors.blue.shade600],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $userName!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¿En qué podemos ayudarte hoy?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateAppointmentScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.event_note,
                      title: 'Mis\nCitas',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
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
        width: 145,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSpecialistInfoDialog(name, specialty, color, icon),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
          ),
        ),
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

  // Diálogo de información del especialista
  void _showSpecialistInfoDialog(String name, String specialty, Color color, IconData icon) {
    // Información personalizada para cada especialista
    Map<String, Map<String, dynamic>> specialistInfo = {
      'Dr. Carlos Ramírez': {
        'experiencia': '15 años de experiencia',
        'educacion': 'Universidad Nacional de Colombia',
        'horario': 'Lunes a Viernes: 8:00 AM - 4:00 PM',
        'servicios': ['Electrocardiogramas', 'Ecocardiogramas', 'Pruebas de esfuerzo', 'Consulta preventiva'],
      },
      'Dra. Ana Martínez': {
        'experiencia': '12 años de experiencia',
        'educacion': 'Universidad de los Andes',
        'horario': 'Lunes a Sábado: 9:00 AM - 5:00 PM',
        'servicios': ['Tratamiento de acné', 'Cirugía dermatológica', 'Tratamientos láser', 'Consulta de lunares'],
      },
      'Dr. Luis Hernández': {
        'experiencia': '10 años de experiencia',
        'educacion': 'Universidad Javeriana',
        'horario': 'Lunes a Viernes: 7:00 AM - 3:00 PM',
        'servicios': ['Control de niño sano', 'Vacunación', 'Consulta pediátrica', 'Desarrollo infantil'],
      },
      'Dra. María López': {
        'experiencia': '18 años de experiencia',
        'educacion': 'Universidad del Rosario',
        'horario': 'Martes a Sábado: 10:00 AM - 6:00 PM',
        'servicios': ['Examen visual completo', 'Cirugía de cataratas', 'Tratamiento de glaucoma', 'Adaptación de lentes'],
      },
      'Dr. Jorge Sánchez': {
        'experiencia': '20 años de experiencia',
        'educacion': 'Universidad Nacional de Colombia',
        'horario': 'Lunes a Jueves: 9:00 AM - 5:00 PM',
        'servicios': ['Electroencefalograma', 'Tratamiento de migraña', 'Evaluación neurológica', 'Trastornos del sueño'],
      },
    };

    final info = specialistInfo[name] ?? {
      'experiencia': 'Información no disponible',
      'educacion': 'Información no disponible',
      'horario': 'Información no disponible',
      'servicios': ['Consulta general'],
    };

    showDialog(
      context: context as BuildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoItem(Icons.school, 'Educación', info['educacion'], color),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.work, 'Experiencia', info['experiencia'], color),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.access_time, 'Horario', info['horario'], color),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.medical_services, color: color, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Servicios',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  (info['servicios'] as List).length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 28, bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info['servicios'][index],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

