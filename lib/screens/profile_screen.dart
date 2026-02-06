import 'package:flutter/material.dart';
import 'package:project/services/user_service.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/screens/login_screen.dart';
import 'package:project/screens/update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final userData = await UserService.getProfile();
      setState(() {
        user = userData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!, width: 3),
      ),
      child: Stack(
        children: [
          // Static SVG-like profile picture using CustomPaint
          CustomPaint(
            painter: _ProfileIconPainter(),
            size: const Size(120, 120),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildProfilePicture(),
                        const SizedBox(height: 24),
                        if (user != null) ...[
                          Text(
                            "${user!['prenom']} ${user!['nom']}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user!['email'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Age: ${user!['age']}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        Container(
                          color: Colors.grey[100],
                          child: Column(
                            children: [
                              _buildListTile(
                                icon: Icons.edit,
                                title: "Update Profile",
                                onTap: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UpdateProfileScreen(
                                        user: user!,
                                      ),
                                    ),
                                  );
                                  if (updated == true) {
                                    _loadProfile();
                                  }
                                },
                              ),
                              Divider(height: 1, color: Colors.grey[300]),
                              _buildListTile(
                                icon: Icons.settings,
                                title: "Parameters",
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Parameters screen coming soon"),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: Colors.grey[300]),
                              _buildListTile(
                                icon: Icons.info_outline,
                                title: "A propos de l'application",
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("A propos de l'application"),
                                      content: const Text(
                                        "Version: 1.0.0\n\n"
                                        "This is a Flutter application with Node.js backend.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: Colors.grey[300]),
                              _buildListTile(
                                icon: Icons.logout,
                                title: "Logout",
                                iconColor: Colors.red,
                                onTap: _handleLogout,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Custom painter for static SVG-like profile icon
class _ProfileIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw circle for head
    canvas.drawCircle(center, radius, paint);

    // Draw body (simplified person icon)
    final bodyPath = Path()
      ..moveTo(center.dx - radius * 0.6, center.dy + radius * 0.3)
      ..lineTo(center.dx - radius * 0.3, center.dy + radius * 1.2)
      ..lineTo(center.dx + radius * 0.3, center.dy + radius * 1.2)
      ..lineTo(center.dx + radius * 0.6, center.dy + radius * 0.3)
      ..close();

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
