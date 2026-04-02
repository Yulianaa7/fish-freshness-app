import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';
import '../../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result =
        await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);

    if (!mounted) return;

    if (result['token'] != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Login gagal'),
        backgroundColor: AppColors.nonFresh,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.set_meal, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FishFresh',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk ke akun kamu',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            // Card form
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Selamat Datang 👋',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 28),
                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.primary),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email wajib diisi';
                            if (!v.contains('@')) return 'Email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        // Login Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white))
                                : const Text('Masuk'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun?',
                                style: TextStyle(color: AppColors.textGrey)),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/register'),
                              child: const Text('Daftar',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}