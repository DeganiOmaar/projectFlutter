import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  String msg = "";
  bool loading = false;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();

    if (newPasswordC.text.isEmpty || confirmPasswordC.text.isEmpty) {
      setState(() => msg = "Please fill all fields");
      return;
    }

    if (newPasswordC.text != confirmPasswordC.text) {
      setState(() => msg = "Passwords do not match");
      return;
    }

    if (newPasswordC.text.length < 6) {
      setState(() => msg = "Password must be at least 6 characters");
      return;
    }

    setState(() {
      loading = true;
      msg = "";
    });

    try {
      await AuthService.resetPassword(
        email: widget.email,
        code: widget.code,
        newPassword: newPasswordC.text,
        confirmPassword: confirmPasswordC.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully! Please login."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() => msg = e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    newPasswordC.dispose();
    confirmPasswordC.dispose();
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
                const SizedBox(height: 40),

                const Text(
                  "Reset Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your new password",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: newPasswordC,
                  obscureText: hideNewPassword,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    "New Password",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        hideNewPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => hideNewPassword = !hideNewPassword),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: confirmPasswordC,
                  obscureText: hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => loading ? null : resetPassword(),
                  decoration: _inputDecoration(
                    "Confirm Password",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        hideConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                    ),
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
                    onPressed: loading ? null : resetPassword,
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
                            "Reset Password",
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
      ),
    );
  }
}
