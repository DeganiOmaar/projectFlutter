

import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomC = TextEditingController();
  final prenomC = TextEditingController();
  final ageC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  String msg = "";
  bool loading = false;
  bool hidePassword = true;

  Future<void> doRegister() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      msg = "";
    });

    try {
      await AuthService.register(
        nom: nomC.text.trim(),
        prenom: prenomC.text.trim(),
        age: int.parse(ageC.text),
        email: emailC.text.trim(),
        password: passC.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created ")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nomC.dispose();
    prenomC.dispose();
    ageC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
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
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Fill your information to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: nomC,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Nom", Icons.badge_outlined),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: prenomC,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Prenom", Icons.person_outline),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: ageC,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Age", Icons.numbers_outlined),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: passC,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => loading ? null : doRegister(),
                  decoration: _inputDecoration(
                    "Password",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                if (msg.isNotEmpty)
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : doRegister,
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
                            "Create account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
