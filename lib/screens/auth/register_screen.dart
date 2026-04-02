import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';
import '../../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await ApiService.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (result['token'] != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Registrasi gagal'),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Form card
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
                          'Daftar Sekarang 🐟',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text('Isi data diri kamu untuk membuat akun',
                            style: TextStyle(color: AppColors.textGrey)),
                        const SizedBox(height: 28),
                        // Nama
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.primary),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
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
                            if (v!.isEmpty) return 'Email wajib diisi';
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
                            if (v!.isEmpty) return 'Password wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscure,
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Password',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.primary),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'Konfirmasi password wajib diisi';
                            if (v != _passCtrl.text)
                              return 'Password tidak cocok';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white))
                                : const Text('Daftar'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun?',
                                style: TextStyle(color: AppColors.textGrey)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Masuk',
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