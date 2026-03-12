import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget { // Cambiado a StatefulWidget
  final String userName;
  const ChatPage({super.key, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 1. Controlador para capturar el texto del input
  final TextEditingController _messageController = TextEditingController();

  // 2. Lista de mensajes iniciales
  final List<Map<String, dynamic>> _messages = [
    {"text": "¿Sales hoy?", "isMe": false},
    {"text": "¡Claro! En 10 min estoy listo", "isMe": true},
    {"text": "Dale, invita al resto al squad", "isMe": false},
  ];

  // 3. Función para enviar el mensaje
  void _handleSend() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "text": _messageController.text,
          "isMe": true,
        });
      });
      _messageController.clear(); // Limpia el buscador al enviar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0B2E),
        title: Text(widget.userName, // Se usa widget.userName al ser Stateful
            style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold)),
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
            // LISTA DINÁMICA DE MENSAJES
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _chatBubble(
                    _messages[index]["text"], 
                    _messages[index]["isMe"]
                  );
                },
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
          border: Border.all(
              color: isMe
                  ? Colors.white24
                  : const Color(0xFFE040FB).withOpacity(0.3)),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white, fontFamily: 'Syne')),
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
              controller: _messageController, // Asignamos el controlador
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _handleSend(), // Enviar al pulsar 'Intro' en el teclado
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFFE040FB),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _handleSend, // Llamamos a la función de enviar
            ),
          ),
        ],
      ),
    );
  }
}