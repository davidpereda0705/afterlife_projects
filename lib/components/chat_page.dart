import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ChatPage extends StatelessWidget {
  final String userName;
  const ChatPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0B2E),
        title: Text(userName, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0B2E), Color(0xFF4A148C), Color(0xFF880E4F)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _chatBubble("¿Sales hoy?", false),
                  _chatBubble("¡Claro! En 10 min estoy listo", true),
                  _chatBubble("Dale, invita al resto al squad", false),
                ],
              ),
            ),
            // BARRA DE ESCRIBIR
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE040FB).withOpacity(0.8) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isMe ? Colors.white24 : const Color(0xFFE040FB).withOpacity(0.3)),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black26,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFFE040FB),
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () {}),
          ),
        ],
      ),
    );
  }
}