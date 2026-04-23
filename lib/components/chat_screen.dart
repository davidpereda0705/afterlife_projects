import 'package:afterlife_projects/components/AfterLifeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // Marcar mensajes como leídos al abrir el chat
    _chatService.markMessagesAsRead(widget.chatId);
    
    // Y seguir marcando como leídos si llegan nuevos mientras estamos dentro
    _chatService.getMessages(widget.chatId).listen((messages) {
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

  void _searchMessages(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _chatService.searchMessages(widget.chatId, query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfterlifeColors.background,
      appBar: AppBar(
        backgroundColor: AfterlifeColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AfterlifeColors.textPrimary),
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
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: AfterlifeColors.textPrimary),
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
              color: AfterlifeColors.surfaceDark,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(color: AfterlifeColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Buscar en la conversación...',
                        hintStyle: TextStyle(color: AfterlifeColors.textDisabled),
                        prefixIcon: Icon(Icons.search, color: AfterlifeColors.electricLilac),
                        filled: true,
                        fillColor: AfterlifeColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _searchMessages(value);
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
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white70)));
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
                Icon(Icons.chat_bubble_outline, size: 60, color: AfterlifeColors.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No hay mensajes aún',
                  style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Envía el primer mensaje a ${widget.otherUserName}',
                  style: TextStyle(color: AfterlifeColors.textDisabled),
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
              : AfterlifeColors.surfaceDark,
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
                color: isMe ? Colors.white : AfterlifeColors.textPrimary,
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
                    color: (isMe ? Colors.white70 : AfterlifeColors.textDisabled),
                    fontSize: 10,
                  ),
                ),
                if (isMe)
                  const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    message['read'] ? Icons.done_all : Icons.done,
                    size: 12, 
                    color: message['read'] ? AfterlifeColors.acidGreen : Colors.white70
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
            Icon(Icons.search_off, size: 60, color: AfterlifeColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No se encontraron mensajes',
              style: AfterlifeTextTheme.bodyLarge.copyWith(color: AfterlifeColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otra palabra',
              style: TextStyle(color: AfterlifeColors.textDisabled),
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
        final time = message['timestamp'] != null
            ? _formatTime(message['timestamp'].toDate())
            : '';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AfterlifeCard(
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
                        style: TextStyle(color: AfterlifeColors.textDisabled, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message['text'],
                    style: const TextStyle(color: AfterlifeColors.textPrimary, fontSize: 14),
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
        color: AfterlifeColors.surfaceDark,
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
              style: const TextStyle(color: AfterlifeColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: AfterlifeColors.textDisabled),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AfterlifeColors.background,
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
              child: const Icon(Icons.send, color: Colors.white, size: 20),
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