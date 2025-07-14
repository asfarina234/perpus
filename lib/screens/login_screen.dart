import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/anggota_dashboard.dart';
import 'wave_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String username = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _authService.login(username.trim(), password);

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      final user = result['data']['user'] ?? result['user'];
      final role = user['role'] as String;
      final userId = user['id'].toString();
      final userName = user['name'];

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => AdminDashboard(
                  userId: int.parse(userId), // konversi String ke int
                  userName: userName,
                ),
          ),
        );
      } else if (role == 'anggota') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    AnggotaDashboardScreen(userId: userId, userName: userName),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Role tidak dikenali';
        });
      }
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Login gagal';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BottomWave(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 260),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Color(0xFF1565C0)),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Username harus diisi'
                                  : null,
                      onChanged: (val) => username = val,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xFF1565C0)),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator:
                          (val) =>
                              val == null || val.length < 6
                                  ? 'Password minimal 6 karakter'
                                  : null,
                      onChanged: (val) => password = val,
                    ),
                    const SizedBox(height: 24),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Belum punya akun? Register',
                        style: TextStyle(color: Color(0xFF1565C0)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
