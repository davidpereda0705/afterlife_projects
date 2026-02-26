import 'package:afterlife_projects/components/AfterButton.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'chat_page.dart'; // <--- Importante para que funcione el salto al chat

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo degradado Afterlife
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0B2E), Color(0xFF4A148C), Color(0xFF880E4F)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Text(
              'AMIGOS',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            
            // Lista de Amigos que ahora son botones para chatear
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _friendItem(context, 'Marc_After', true),
                  _friendItem(context, 'Elena_Night', true),
                  _friendItem(context, 'Pau_Vibes', false),
                  _friendItem(context, 'Alex_Party', true),
                ],
              ),
            ),

            // Botón inferior para crear la noche
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: AfterButton(
                label: 'CREAR NOCHE',
                size: 160,
                color: AfterlifeColors.electricLilac,
                onPressed: () => print("Nueva noche creada"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de cada amigo con detector de toques para ir al chat
  Widget _friendItem(BuildContext context, String name, bool online) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage(userName: name)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: online ? const Color(0xFFE040FB).withOpacity(0.3) : Colors.transparent
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: online ? const Color(0xFFE040FB) : Colors.grey[900],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Text(
              name, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            // Indicador de "listo para la fiesta"
            if (online) 
              const Icon(Icons.flash_on, color: Color(0xFFE040FB), size: 18),
          ],
        ),
      ),
    );
  }
}