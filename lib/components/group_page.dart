// lib/screens/group_page.dart
import 'package:afterlife_projects/Menu_Noches.dart';
import 'package:afterlife_projects/components/chat_page.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import '../components/AfterButton.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        centerTitle: true, // Título centrado para un look más pro
        title: Text(
          'COMUNIDAD', // Cambiado a algo más global
          style: TextStyle(
            color: AfterlifeColors.textPrimary,
            fontFamily: 'Syne', // Usando tu fuente local
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AfterlifeColors.electricPurple),
            onPressed: () {
              // Aquí podrías añadir lógica para buscar nuevos amigos
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- NUEVA SECCIÓN DE GRUPOS RÁPIDOS ---
            _buildSectionHeader('GRUPOS DE LA NOCHE'),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _groupAvatar('VIP After', Icons.star),
                  _groupAvatar('Razzmatazz', Icons. whatshot),
                  _groupAvatar('Pacha Crew', Icons. music_note),
                  _groupAvatar('Techno Loft', Icons. graphic_eq),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _buildSectionHeader('AMIGOS CONECTADOS'),
            
            // --- LISTA DE CHATS ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _friendItem(context, 'Marc_After', true, '¡Mañana se sale! 🔥'),
                  _friendItem(context, 'Elena_Night', true, '¿A qué hora quedamos?'),
                  _friendItem(context, 'Pau_Vibes', false, 'Visto hace 2h'),
                  _friendItem(context, 'Alex_Party', true, 'Enviando audio...'),
                  _friendItem(context, 'Laura_Nox', true, '¡Ese sitio es top!'),
                  _friendItem(context, 'David_Fiesta', false, 'Ayer'),
                ],
              ),
            ),

            // BOTÓN DE ACCIÓN
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: AfterButton(
                label: 'CREAR NOCHE',
                color: AfterlifeColors.electricLilac,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NightSelectionScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Títulos de sección para organizar mejor el menú
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AfterlifeColors.textDisabled,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // Círculos de grupos para la parte superior
  Widget _groupAvatar(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AfterlifeColors.surfaceDark.withOpacity(0.6),
            child: Icon(icon, color: AfterlifeColors.electricPurple),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  // Elemento de amigo mejorado con subtítulo (último mensaje)
  Widget _friendItem(BuildContext context, String name, bool online, String lastMsg) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage(userName: name)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AfterlifeColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: online 
                ? AfterlifeColors.electricPurple.withOpacity(0.3) 
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Stack( // Stack para poner el punto verde de online
              children: [
                CircleAvatar(
                  backgroundColor: online 
                      ? AfterlifeColors.electricPurple 
                      : AfterlifeColors.textDisabled.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                if (online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AfterlifeColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  style: TextStyle(
                    color: AfterlifeColors.textPrimary, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Syne',
                  )
                ),
                Text(
                  lastMsg,
                  style: TextStyle(
                    color: AfterlifeColors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (online) 
              Icon(
                Icons.chevron_right, // Icono de flecha para indicar que puedes entrar
                color: AfterlifeColors.textDisabled, 
                size: 20
              ),
          ],
        ),
      ),
    );
  }
}