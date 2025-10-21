import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Logo/Icono de la app
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 100,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 30),

            // Nombre de la app
            const Text(
              'MediApp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tu salud, nuestra prioridad',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 40),

            // Sección de Misión
            _buildInfoCard(
              icon: Icons.flag,
              iconColor: Colors.blue,
              title: 'Nuestra Misión',
              content:
                  'Proporcionar acceso fácil y rápido a servicios de salud de calidad a través de la tecnología. Conectamos pacientes con profesionales médicos capacitados para mejorar la experiencia en el cuidado de la salud.',
            ),

            // Sección de Visión
            _buildInfoCard(
              icon: Icons.visibility,
              iconColor: Colors.green,
              title: 'Nuestra Visión',
              content:
                  'Ser la plataforma líder en servicios de telemedicina en Latinoamérica, revolucionando la manera en que las personas acceden a la atención médica.',
            ),

            // Sección de Valores
            _buildInfoCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Nuestros Valores',
              content:
                  '• Compromiso con la salud del paciente\n'
                  '• Innovación tecnológica constante\n'
                  '• Confidencialidad y privacidad\n'
                  '• Accesibilidad para todos\n'
                  '• Excelencia médica',
            ),

            // Sección de Contacto
            _buildInfoCard(
              icon: Icons.contact_mail,
              iconColor: Colors.purple,
              title: 'Contáctanos',
              content:
                  'Email: contacto@mediapp.com\n'
                  'Teléfono: +52 55 1234 5678\n'
                  'Horario: Lun - Vie 8:00 AM - 8:00 PM\n'
                  'Sáb - Dom 9:00 AM - 5:00 PM',
            ),

            const SizedBox(height: 30),

            // Información del equipo
            const Text(
              'Desarrollado con ❤️ por el equipo de MediApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '© 2025 MediApp. Todos los derechos reservados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 30),

            // Botones de redes sociales
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.facebook, Colors.blue[800]!),
                const SizedBox(width: 15),
                _buildSocialButton(Icons.mail, Colors.red),
                const SizedBox(width: 15),
                _buildSocialButton(Icons.language, Colors.teal),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
