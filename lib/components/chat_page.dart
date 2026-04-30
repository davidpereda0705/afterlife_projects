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
     color: isMe ? Color(0xFFE040FB).withOpacity(0.8) : Theme.of(context).colorScheme.onSurface.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isMe
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.24)
                  : const Color(0xFFE040FB).withOpacity(0.3)),
        ),
        child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontFamily: 'Syne')),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController, // Asignamos el controlador
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              onSubmitted: (_) => _handleSend(), // Enviar al pulsar 'Intro' en el teclado
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.025),
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
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
              onPressed: _handleSend, // Llamamos a la función de enviar
            ),
          ),
        ],
      ),
    );
  }
}
