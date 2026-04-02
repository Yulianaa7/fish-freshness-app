import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _editMode = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    // data dummy
    setState(() {
      _user = UserModel(
        id: 0,
        name: 'Pengguna',
        email: 'user@example.com',
      );
      _loading = false;
      _nameCtrl.text = _user!.name;
      _emailCtrl.text = _user!.email;
      _phoneCtrl.text = '';
      _addressCtrl.text = '';
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final ok = await ApiService.updateProfile({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    });
    setState(() {
      _saving = false;
      _editMode = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '✅ Profil berhasil diperbarui' : '❌ Gagal menyimpan'),
      backgroundColor: ok ? AppColors.fresh : AppColors.nonFresh,
    ));
    if (ok) _loadProfile();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Yakin ingin keluar dari akun kamu?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.nonFresh),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.clearToken();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text(
              'Profil Saya',
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            expandedHeight: 160,
            actions: [
              if (!_editMode)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _editMode = true),
                )
              else
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _editMode = false;
                    if (_user != null) {
                      _nameCtrl.text = _user!.name;
                      _phoneCtrl.text = _user!.phone ?? '';
                      _addressCtrl.text = _user!.address ?? '';
                    }
                  }),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        _user?.name.isNotEmpty == true
                            ? _user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)))
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Form card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Informasi Akun',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 16),
                                _ProfileField(
                                  label: 'Nama Lengkap',
                                  icon: Icons.person_outline,
                                  controller: _nameCtrl,
                                  enabled: _editMode,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  controller: _emailCtrl,
                                  enabled: false, // email not editable
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  label: 'No. Telepon',
                                  icon: Icons.phone_outlined,
                                  controller: _phoneCtrl,
                                  enabled: _editMode,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  label: 'Alamat',
                                  icon: Icons.location_on_outlined,
                                  controller: _addressCtrl,
                                  enabled: _editMode,
                                  maxLines: 2,
                                ),
                                if (_editMode) ...[
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: _saving ? null : _saveProfile,
                                      icon: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white))
                                          : const Icon(Icons.save),
                                      label: Text(
                                          _saving ? 'Menyimpan...' : 'Simpan Perubahan'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Other menu
                        Card(
                          child: Column(
                            children: [
                              _MenuItem(
                                icon: Icons.info_outline,
                                label: 'Tentang Aplikasi',
                                onTap: () => _showAbout(),
                              ),
                              const Divider(height: 1, indent: 56),
                              _MenuItem(
                                icon: Icons.logout,
                                label: 'Keluar',
                                color: AppColors.nonFresh,
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'FishFresh v1.0.0\n© 2026 Kelompok 6 - Telkom University Surabaya',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textGrey.withOpacity(0.6),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'FishFresh',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.set_meal, color: AppColors.primary, size: 48),
      children: [
        const Text(
            'Aplikasi deteksi kesegaran ikan menggunakan teknologi Machine Learning (CNN).\n\nDikembangkan oleh Kelompok 6 - Program Studi Teknologi Informasi, Universitas Telkom Surabaya, 2026.'),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _ProfileField({
    required this.label,
    required this.icon,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.background,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5))),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: onTap,
    );
  }
}