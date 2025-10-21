import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';



class profile_page extends StatelessWidget {
  const profile_page({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
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
                // El StreamBuilder en main.dart detectará automáticamente
                // el cambio y mostrará el LoginScreen
              },
            ),
          ],
        ),

      body: Center(
        child: Text
          ("Nombre del usuario: " + FirebaseAuth.instance.currentUser!.email!,
          style: TextStyle(fontSize: 20))
      )

    );
  }
}
