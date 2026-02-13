import 'package:flutter/material.dart';
import 'package:project/services/dm_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DmMessage {
  final String id;
  final String content;
  final bool isFromMe;
  final DateTime? createdAt;

  DmMessage({
    required this.id,
    required this.content,
    required this.isFromMe,
    this.createdAt,
  });
}

class DirectMessageScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const DirectMessageScreen({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final List<DmMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  io.Socket? _socket;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final data = await DmService.getConversation(widget.peerId);
      final list = data["messages"] as List<dynamic>? ?? [];
      await DmService.markConversationRead(widget.peerId);
      if (mounted) {
        setState(() {
          _messages.clear();
          for (final m in list) {
            final map = m as Map<String, dynamic>;
            _messages.add(DmMessage(
              id: map["id"]?.toString() ?? "",
              content: map["content"]?.toString() ?? "",
              isFromMe: map["isFromMe"] == true,
              createdAt: map["createdAt"] != null
                  ? DateTime.tryParse(map["createdAt"].toString())
                  : null,
            ));
          }
          _loading = false;
        });
      }
      await _connectSocket();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _loading = false;
        });
      }
    }
  }

  Future<void> _connectSocket() async {
    final socket = await DmService.connectSocket();
    _socket = socket;

    socket.on("new_message", (data) {
      if (data is! Map) return;
      final receiverId = data["receiverId"]?.toString();
      final senderId = data["senderId"]?.toString();
      if (receiverId != widget.peerId && senderId != widget.peerId) return;

      if (mounted) {
        setState(() {
          _messages.add(DmMessage(
            id: data["id"]?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            content: data["content"]?.toString() ?? "",
            isFromMe: data["isFromMe"] == true,
            createdAt: data["createdAt"] != null
                ? DateTime.tryParse(data["createdAt"].toString())
                : DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });

    socket.on("message_error", (data) {
      if (mounted && data is Map) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"]?.toString() ?? "Error")),
        );
      }
    });

    socket.onConnectError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection error")),
        );
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _socket?.emit("send_message", {
      "to": widget.peerId,
      "content": text,
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.peerName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.peerName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _init();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F5F5),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(DmMessage msg) {
    return Align(
      alignment: msg.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isFromMe ? Colors.black : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(msg.isFromMe ? 12 : 4),
            bottomRight: Radius.circular(msg.isFromMe ? 4 : 12),
          ),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: msg.isFromMe ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
