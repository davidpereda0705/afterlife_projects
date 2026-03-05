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
        title: Text(
          'AMIGOS',
          style: TextStyle(
            color: AfterlifeColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AfterlifeColors.electricLilacGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _friendItem(context, 'Marc_After', true),
                  _friendItem(context, 'Elena_Night', true),
                  _friendItem(context, 'Pau_Vibes', false),
                  _friendItem(context, 'Alex_Party', true),
                  _friendItem(context, 'Laura_Nox', true),
                  _friendItem(context, 'David_Fiesta', false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: AfterButton(
                label: 'CREAR NOCHE',
                size: 160,
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