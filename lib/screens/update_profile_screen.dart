import 'package:flutter/material.dart';
import 'package:project/services/user_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late final TextEditingController nomC;
  late final TextEditingController prenomC;
  late final TextEditingController ageC;
  late final TextEditingController emailC;

  bool loading = false;
  String msg = "";

  @override
  void initState() {
    super.initState();
    nomC = TextEditingController(text: widget.user['nom'] ?? '');
    prenomC = TextEditingController(text: widget.user['prenom'] ?? '');
    ageC = TextEditingController(text: (widget.user['age'] ?? '').toString());
    emailC = TextEditingController(text: widget.user['email'] ?? '');
  }

  @override
  void dispose() {
    nomC.dispose();
    prenomC.dispose();
    ageC.dispose();
    emailC.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();

    if (nomC.text.trim().isEmpty ||
        prenomC.text.trim().isEmpty ||
        ageC.text.trim().isEmpty) {
      setState(() => msg = "Please fill all fields");
      return;
    }

    final age = int.tryParse(ageC.text.trim());
    if (age == null || age < 1) {
      setState(() => msg = "Please enter a valid age");
      return;
    }

    setState(() {
      loading = true;
      msg = "";
    });

    try {
      await UserService.updateProfile(
        nom: nomC.text.trim(),
        prenom: prenomC.text.trim(),
        age: age,
      );
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              TextField(
                controller: nomC,
                decoration: _inputDecoration("Nom", Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prenomC,
                decoration: _inputDecoration("Prenom", Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageC,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Age", Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email is non-editable
                decoration: _inputDecoration("Email", Icons.email_outlined).copyWith(
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              if (msg.isNotEmpty)
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Update Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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
