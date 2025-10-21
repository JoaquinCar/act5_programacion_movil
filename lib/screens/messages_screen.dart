import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMessageTile(
            context,
            name: 'Dr. Carlos Ramírez',
            message: 'Tu cita está confirmada para mañana a las 10:00 AM',
            time: '9:30 AM',
            avatarColor: Colors.red,
            icon: Icons.favorite,
            unreadCount: 2,
          ),
          _buildMessageTile(
            context,
            name: 'Dra. Ana Martínez',
            message: 'Los resultados de tu examen están listos',
            time: 'Ayer',
            avatarColor: Colors.orange,
            icon: Icons.healing,
            unreadCount: 1,
          ),
          _buildMessageTile(
            context,
            name: 'Dr. Luis Hernández',
            message: '¿Cómo se ha sentido el niño después de la consulta?',
            time: 'Lun',
            avatarColor: Colors.blue,
            icon: Icons.child_care,
            unreadCount: 0,
          ),
          _buildMessageTile(
            context,
            name: 'Dra. María López',
            message: 'Recuerda usar tus gotas cada 8 horas',
            time: 'Dom',
            avatarColor: Colors.teal,
            icon: Icons.remove_red_eye,
            unreadCount: 0,
          ),
          _buildMessageTile(
            context,
            name: 'Dr. Jorge Sánchez',
            message: 'Gracias por asistir a tu consulta',
            time: 'Sáb',
            avatarColor: Colors.purple,
            icon: Icons.psychology,
            unreadCount: 0,
          ),
          _buildMessageTile(
            context,
            name: 'Clínica San Rafael',
            message: 'Recordatorio: Tienes una cita pendiente',
            time: 'Vie',
            avatarColor: Colors.indigo,
            icon: Icons.local_hospital,
            unreadCount: 0,
          ),
          _buildMessageTile(
            context,
            name: 'Dr. Roberto Cruz',
            message: 'Tu receta médica está lista para recoger',
            time: 'Jue',
            avatarColor: Colors.deepPurple,
            icon: Icons.person,
            unreadCount: 0,
          ),
          _buildMessageTile(
            context,
            name: 'Dra. Patricia Gómez',
            message: 'Todo salió bien en tu última revisión',
            time: '12/10',
            avatarColor: Colors.pink,
            icon: Icons.person_outline,
            unreadCount: 0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de nuevo mensaje')),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required Color avatarColor,
    required IconData icon,
    required int unreadCount,
  }) {
    return InkWell(
      onTap: () {
        _openChatScreen(context, name, avatarColor, icon);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Icon(icon, color: avatarColor, size: 28),
            ),
            const SizedBox(width: 12),
            // Contenido del mensaje
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? Colors.purple
                              : Colors.grey.shade600,
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0
                                ? Colors.black87
                                : Colors.grey.shade600,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatScreen(
      BuildContext context, String name, Color color, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          name: name,
          avatarColor: color,
          icon: icon,
        ),
      ),
    );
  }
}

// Pantalla de chat individual
class ChatScreen extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final IconData icon;

  const ChatScreen({
    Key? key,
    required this.name,
    required this.avatarColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Icon(icon, color: avatarColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReceivedMessage(
                  'Hola, ¿cómo estás?',
                  '10:30 AM',
                ),
                _buildSentMessage(
                  'Hola Doctor, estoy bien gracias',
                  '10:32 AM',
                ),
                _buildReceivedMessage(
                  'Me alegra escucharlo. ¿En qué puedo ayudarte hoy?',
                  '10:33 AM',
                ),
                _buildSentMessage(
                  'Quería consultar sobre los resultados de mi último examen',
                  '10:35 AM',
                ),
                _buildReceivedMessage(
                  'Claro, déjame revisar tu expediente. Todo salió bien en los resultados.',
                  '10:36 AM',
                ),
                _buildSentMessage(
                  'Excelente, muchas gracias Doctor',
                  '10:38 AM',
                ),
                _buildReceivedMessage(
                  'Para cualquier duda, no dudes en escribirme',
                  '10:39 AM',
                ),
              ],
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all,
                  size: 14,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.purple),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.purple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de enviar mensaje')),
              );
            },
          ),
        ],
      ),
    );
  }
}
