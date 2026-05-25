// Panel deslizable de chat grupal durante una noche activa: mensajes en tiempo real vía Firestore stream.
import 'dart:async';

import 'package:afterlife_projects/services/night_chat_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NightChatSheet extends StatefulWidget {
  final String nightId;
  final String senderName;

  const NightChatSheet({super.key, required this.nightId, required this.senderName});

  @override
  State<NightChatSheet> createState() => _NightChatSheetState();
}

class _NightChatSheetState extends State<NightChatSheet> {
  final NightChatService _chatService = NightChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _sub = _chatService.getMessages(widget.nightId).listen((msgs) {
      if (mounted) setState(() => _messages = msgs);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _chatService.sendMessage(widget.nightId, text, widget.senderName);
    HapticFeedback.lightImpact();
    _controller.clear();
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays > 0) return '${diff.inDays}d';
        if (diff.inHours > 0) return '${diff.inHours}h';
        if (diff.inMinutes > 0) return '${diff.inMinutes}m';
        return 'ahora';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Text('Chat del grupo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  final isMe = msg['isMe'] == true;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? AfterlifeColors.electricLilac.withValues(alpha: 0.8) : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(msg['senderName'] ?? '', style: TextStyle(fontSize: 10, color: AfterlifeColors.cyanBlue, fontWeight: FontWeight.bold)),
                          Text(msg['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                          Text(_formatTime(msg['timestamp']), style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Theme.of(context).disabledColor)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AfterlifeColors.electricLilac, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
