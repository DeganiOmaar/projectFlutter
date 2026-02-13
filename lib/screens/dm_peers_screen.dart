import 'package:flutter/material.dart';
import 'package:project/screens/direct_message_screen.dart';
import 'package:project/services/dm_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DmPeersScreen extends StatefulWidget {
  const DmPeersScreen({super.key});

  @override
  State<DmPeersScreen> createState() => _DmPeersScreenState();
}

class _DmPeersScreenState extends State<DmPeersScreen> {
  List<Map<String, dynamic>> _peers = [];
  bool _loading = true;
  String _error = "";
  io.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _loadPeers();
  }

  Future<void> _loadPeers() async {
    setState(() {
      _loading = true;
      _error = "";
    });
    try {
      final peers = await DmService.getPeers();
      if (mounted) {
        setState(() {
          _peers = peers;
          _loading = false;
        });
        _connectSocketIfNeeded();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _loading = false;
        });
      }
    }
  }

  Future<void> _connectSocketIfNeeded() async {
    if (_socket != null && _socket!.connected) return;
    try {
      final socket = await DmService.connectSocket();
      _socket = socket;

      socket.on("new_message", (data) {
        if (data is! Map) return;
        final receiverId = data["receiverId"]?.toString();
        final senderId = data["senderId"]?.toString();
        if (receiverId == null || senderId == null) return;
        final isForMe = receiverId != senderId;
        if (!isForMe) return;
        if (mounted) {
          setState(() {
            final i = _peers.indexWhere((p) => p["id"]?.toString() == senderId);
            if (i >= 0) {
              _peers[i] = {..._peers[i], "unreadCount": ((_peers[i]["unreadCount"] ?? 0) as int) + 1};
            }
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPeers,
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
                )
              : _peers.isEmpty
                  ? const Center(
                      child: Text(
                        "No other users yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPeers,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: _peers.length,
                        itemBuilder: (context, i) {
                          final p = _peers[i];
                          final name = "${p["prenom"] ?? ""} ${p["nom"] ?? ""}".trim();
                          final unread = (p["unreadCount"] ?? 0) as int;
                          return _PeerTile(
                            name: name.isNotEmpty ? name : p["email"] ?? "User",
                            email: p["email"] ?? "",
                            unreadCount: unread,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DirectMessageScreen(
                                    peerId: p["id"] ?? "",
                                    peerName: name.isNotEmpty ? name : p["email"] ?? "User",
                                  ),
                                ),
                              );
                              _loadPeers();
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _PeerTile extends StatelessWidget {
  final String name;
  final String email;
  final int unreadCount;
  final VoidCallback onTap;

  const _PeerTile({
    required this.name,
    required this.email,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black87,
                  child: Text(
                    (name.isNotEmpty ? name[0] : "?").toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? "99+" : "$unreadCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
