import 'package:afterlife_projects/components/group_page.dart';
import 'package:afterlife_projects/theme/AfterlifeTheme.dart';
import 'package:flutter/material.dart';
import 'theme/colors.dart';

void main() => runApp(const AfterlifeApp());

class AfterlifeApp extends StatelessWidget {
  const AfterlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AfterlifeTheme.darkTheme, // Tu tema lila/negro
      home: const GroupPage(), // Arranca directo en la lista de amigos
    );
  }
}