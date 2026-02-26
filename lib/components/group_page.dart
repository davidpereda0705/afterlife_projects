import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import '../components/AfterButton.dart';
import 'chat_page.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aplicamos el fondo negro puro de tu paleta
      backgroundColor: AfterlifeColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Usamos tu nuevo gradiente eléctrico oficial
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Text(
              'AMIGOS',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AfterlifeColors.textPrimary, // Blanco oficial
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            
            // Lista de Amigos con efectos neón actualizados
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

            // Botón inferior con tu nuevo Lila Eléctrico
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: AfterButton(
                label: 'CREAR NOCHE',
                size: 160,
                color: AfterlifeColors.electricLilac, // Usando tu lila 0xFF7B1FA2
                onPressed: () => print("Nueva noche creada"),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          // Usamos superficie oscura de tu paleta
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
            CircleAvatar(
              backgroundColor: online 
                  ? AfterlifeColors.electricPurple 
                  : AfterlifeColors.textDisabled.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Text(
              name, 
              style: TextStyle(
                color: AfterlifeColors.textPrimary, 
                fontWeight: FontWeight.bold
              )
            ),
            const Spacer(),
            if (online) 
              Icon(
                Icons.flash_on, 
                color: AfterlifeColors.electricPurple, 
                size: 18
              ),
          ],
        ),
      ),
    );
  }
}