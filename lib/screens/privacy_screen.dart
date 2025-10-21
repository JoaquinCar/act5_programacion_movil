import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Privacidad'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono principal
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.privacy_tip,
                  size: 80,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Título
            const Center(
              child: Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                'Última actualización: Octubre 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Secciones de información
            _buildSection(
              title: '1. Información que Recopilamos',
              content:
                  'Recopilamos información personal que nos proporcionas directamente, como tu nombre, correo electrónico, edad, lugar de nacimiento y padecimientos médicos. Esta información es necesaria para brindarte un servicio personalizado y seguro.',
            ),

            _buildSection(
              title: '2. Uso de la Información',
              content:
                  'Utilizamos tu información para:\n'
                  '• Proporcionar y mejorar nuestros servicios médicos\n'
                  '• Comunicarnos contigo sobre citas y consultas\n'
                  '• Personalizar tu experiencia en la aplicación\n'
                  '• Enviar notificaciones importantes sobre tu salud',
            ),

            _buildSection(
              title: '3. Protección de Datos',
              content:
                  'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal. Utilizamos encriptación y almacenamiento seguro mediante Firebase Authentication y bases de datos protegidas.',
            ),

            _buildSection(
              title: '4. Compartir Información',
              content:
                  'No vendemos ni compartimos tu información personal con terceros, excepto cuando sea necesario para proporcionar nuestros servicios médicos o cuando la ley lo requiera.',
            ),

            _buildSection(
              title: '5. Tus Derechos',
              content:
                  'Tienes derecho a:\n'
                  '• Acceder a tu información personal\n'
                  '• Corregir datos inexactos\n'
                  '• Solicitar la eliminación de tus datos\n'
                  '• Revocar consentimientos otorgados',
            ),

            _buildSection(
              title: '6. Cookies y Tecnologías Similares',
              content:
                  'Utilizamos cookies y tecnologías similares para mejorar tu experiencia, analizar el uso de la aplicación y personalizar el contenido.',
            ),

            _buildSection(
              title: '7. Contacto',
              content:
                  'Si tienes preguntas sobre nuestra política de privacidad, puedes contactarnos a través de:\n'
                  'Email: privacidad@mediapp.com\n'
                  'Teléfono: +52 55 1234 5678',
            ),

            const SizedBox(height: 30),

            // Botón de aceptar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendido',
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
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
