import 'dart:async';

import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:afterlife_projects/theme/text_theme.dart';
import 'package:afterlife_projects/components/AfterLife_Avatar.dart';
import 'package:afterlife_projects/services/chat_service.dart';
import 'package:afterlife_projects/components/friend_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  bool _showSearchBar = false;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Marcar mensajes como leídos al abrir el chat
    _chatService.markMessagesAsRead(widget.chatId);
    
    // Y seguir marcando como leídos si llegan nuevos mientras estamos dentro
    _messagesSubscription = _chatService.getMessages(widget.chatId).listen((messages) {
      if (mounted) {
        _chatService.markMessagesAsRead(widget.chatId);
      }
    });
    
    // Listener para el estado "escribiendo"
    _focusNode.addListener(() {
      _chatService.setTyping(widget.chatId, _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    // Dejar de escribir al salir
    _chatService.setTyping(widget.chatId, false);
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _chatService.sendMessage(widget.chatId, text);
    HapticFeedback.lightImpact();
    _messageController.clear();
    
    // Scroll al final
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchQuery = query;
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchMessages(query);
    });
  }

  void _searchMessages(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final results = await _chatService.searchMessages(widget.chatId, query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _closeSearchAndReturn() {
    setState(() {
      _showSearchBar = false;
      _searchQuery = '';
      _searchResults = [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendProfileScreen(
                  uid: widget.otherUserId,
                  friendName: widget.otherUserName,
                ),
              ),
            );
          },
          child: Row(
            children: [
              AfterlifeAvatar(
                initials: _getInitials(widget.otherUserName),
                status: AvatarStatus.online,
                size: 40,
                showStatusIndicator: true,
              ),
              const SizedBox(width: 12),
              Text(
                widget.otherUserName,
                style: AfterlifeTextTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchQuery = '';
                  _searchResults = [];
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda de mensajes
          if (_showSearchBar)
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Buscar en la conversación...',
                        hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                        prefixIcon: Icon(Icons.search, color: AfterlifeColors.electricLilac),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _onSearchChanged(value);
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchResults = [];
                        });
                        _searchMessages('');
                      },
                      child: Text('Limpiar', style: TextStyle(color: AfterlifeColors.cyanBlue)),
                    ),
                ],
              ),
            ),
          
          // Contenido principal
          Expanded(
            child: _showSearchBar && (_searchResults.isNotEmpty || _isSearching)
                ? _buildSearchResults()
                : _buildMessagesStream(),
          ),
          
          // Indicador "escribiendo"
          StreamBuilder<bool>(
            stream: _chatService.getTypingStatus(widget.chatId, widget.otherUserId),
            builder: (context, snapshot) {
              final isTyping = snapshot.data ?? false;
              if (!isTyping) return const SizedBox();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AfterlifeColors.cyanBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.otherUserName} está escribiendo...',
                      style: TextStyle(
                        color: AfterlifeColors.cyanBlue,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesStream() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70))));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final messages = snapshot.data!;
        
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                Text(
                  'No hay mensajes aún',
                  style: AfterlifeTextTheme.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 8),
                Text(
                  'Envía el primer mensaje a ${widget.otherUserName}',
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    String time = '';
    try {
      if (message['timestamp'] != null) {
        if (message['timestamp'] is Timestamp) {
          time = _formatTime((message['timestamp'] as Timestamp).toDate());
        }
      }
    } catch (e) {}
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? AfterlifeColors.electricLilac.withOpacity(0.8)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? AfterlifeColors.electricLilac
                : AfterlifeColors.electricPurple.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'],
              style: TextStyle(
                color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: (isMe ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.70) : Theme.of(context).disabledColor),
                    fontSize: 10,
                  ),
                ),
                if (isMe)
                  const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    message['read'] ? Icons.done_all : Icons.done,
                    size: 12, 
                    color: message['read'] ? AfterlifeColors.acidGreen : Theme.of(context).colorScheme.onPrimary.withOpacity(0.70)
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'No se encontraron mensajes',
              style: AfterlifeTextTheme.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otra palabra',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final message = _searchResults[index];
        final isMe = message['senderId'] == _chatService.currentUserId;
        DateTime? messageDate;
        try {
          final ts = message['timestamp'];
          if (ts is Timestamp) messageDate = ts.toDate();
        } catch (_) {
          messageDate = null;
        }
        final time = messageDate != null ? _formatTime(messageDate) : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AfterlifeCard(
            onTap: _closeSearchAndReturn,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isMe ? 'Tú' : widget.otherUserName,
                        style: TextStyle(
                          color: isMe ? AfterlifeColors.electricLilac : AfterlifeColors.cyanBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message['text'] ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AfterlifeColors.electricLilac.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AfterlifeColors.electricLilac,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'ahora';
  }
}
