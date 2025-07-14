import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? userProfile;
  String? errorMessage;
  bool isLoading = true;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController phoneController;
  late TextEditingController birthdateController;

  String? genderValue;

  // ✅ GUNAKAN BASE URL YANG KONSISTEN
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // Alternatif kalau pakai Laravel di localhost:
  // static const String baseUrl = 'http://localhost:8000/api';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    phoneController = TextEditingController();
    birthdateController = TextEditingController();
    fetchProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Token tidak ditemukan, silakan login ulang';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final userData = jsonData['user'] ?? jsonData;

        setState(() {
          userProfile = userData;
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          genderValue = userData['gender'];
          birthdateController.text = userData['birthdate'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat profil. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      setState(() {
        errorMessage = 'Token tidak ditemukan, silakan login ulang';
        isLoading = false;
      });
      return;
    }

    Map<String, dynamic> data = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'gender': genderValue,
      'birthdate': birthdateController.text.trim(),
      'phone': phoneController.text.trim(),
    };

    if (passwordController.text.isNotEmpty) {
      data['password'] = passwordController.text;
      data['password_confirmation'] = confirmPasswordController.text;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        final res = jsonDecode(response.body);
        setState(() {
          errorMessage = res['message'] ?? 'Gagal update profil';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Nama wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(val)) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: genderValue,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Kelamin',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pria',
                              child: Text('Pria'),
                            ),
                            DropdownMenuItem(
                              value: 'wanita',
                              child: Text('Wanita'),
                            ),
                            DropdownMenuItem(
                              value: 'lainnya',
                              child: Text('Lainnya'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              genderValue = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: birthdateController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                            hintText: 'Contoh: 1990-05-20',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (val) {
                            if (val == null || val.isEmpty) return null;
                            try {
                              DateTime.parse(val);
                            } catch (_) {
                              return 'Format tanggal tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'No. Telepon',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.isEmpty) return null;
                            if (val.length < 9) {
                              return 'Nomor telepon terlalu pendek';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Kata Sandi Baru',
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val != null &&
                                val.isNotEmpty &&
                                val.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Kata Sandi',
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (passwordController.text.isNotEmpty &&
                                val != passwordController.text) {
                              return 'Konfirmasi password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : updateProfile,
                          child: const Text('Simpan Perubahan'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar Akun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
