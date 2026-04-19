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
    setState(() {
      _user = UserModel(
        id: 0,
        name: 'Ian Sopian',
        email: 'ian.sopian@telkom.id',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '✅ Profil berhasil diperbarui' : '❌ Gagal menyimpan',
        ),
        backgroundColor: ok ? const Color(0xFF0A7A5A) : const Color(0xFFCC2929),
      ),
    );
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2929),
            ),
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
      backgroundColor: const Color(0xFFEEF2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F8),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.waves, color: Color(0xFF0D1B3E), size: 22),
        ),
        title: const Text(
          'FRESHNET',
          style: TextStyle(
            color: Color(0xFF0D1B3E),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D1B3E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildSystemSettings(),
                  const SizedBox(height: 28),
                  _buildLogout(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'VERSION 4.8.2-FRESHNET',
                      style: TextStyle(
                        color: Color(0xFF8A9BB5),
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo
        // Photo
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            height: 220,
            color: const Color(0xFF1A2E5A),
            child: Image.asset(
              'assets/images/profile_photo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.person, size: 80, color: Colors.white38),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Label
        const Text(
          'PROFIL PENGGUNA',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF8A9BB5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        // Name
        Text(
          _user?.name ?? 'Pengguna',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B3E),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const SizedBox(height: 18),
        // Edit button
        GestureDetector(
          onTap: () =>
              _editMode ? _saveProfile() : setState(() => _editMode = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B3E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _editMode ? Icons.save_outlined : Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _editMode ? 'Simpan Profil' : 'Edit Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Edit form — muncul saat editMode
        if (_editMode) ...[const SizedBox(height: 20), _buildEditForm()],
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileField(
            label: 'Nama Lengkap',
            icon: Icons.person_outline,
            controller: _nameCtrl,
            enabled: true,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Email',
            icon: Icons.email_outlined,
            controller: _emailCtrl,
            enabled: false,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'No. Telepon',
            icon: Icons.phone_outlined,
            controller: _phoneCtrl,
            enabled: true,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Alamat',
            icon: Icons.location_on_outlined,
            controller: _addressCtrl,
            enabled: true,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => setState(() => _editMode = false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF8A9BB5)),
            ),
          ),
        ],
      ),
    );
  }

  // ── System Settings ──

  Widget _buildSystemSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SYSTEM SETTINGS',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF8A9BB5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFDDE8F8),
                iconColor: const Color(0xFF1A4FA0),
                title: 'Account Security',
                subtitle: 'Two-factor authentication and keys',
                onTap: () {},
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconBg: const Color(0xFFDDE8F8),
                iconColor: const Color(0xFF1A4FA0),
                title: 'Notification Preferences',
                subtitle: 'Push, email, and scan alerts',
                onTap: () {},
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.help_outline,
                iconBg: const Color(0xFFDDE8F8),
                iconColor: const Color(0xFF1A4FA0),
                title: 'Help & Support',
                subtitle: 'Documentation and live assistant',
                onTap: () => _showAbout(),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    color: Color(0xFFF0F4FA),
    indent: 72,
  );

  // ── Logout ──

  Widget _buildLogout() {
    return Center(
      child: GestureDetector(
        onTap: _logout,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout, color: Color(0xFFCC2929), size: 18),
            SizedBox(width: 8),
            Text(
              'LOGOUT',
              style: TextStyle(
                color: Color(0xFFCC2929),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'FRESHNET',
      applicationVersion: '4.8.2-FRESHNET',
      applicationIcon: const Icon(
        Icons.waves,
        color: Color(0xFF0D1B3E),
        size: 48,
      ),
      children: [
        const Text(
          'Aplikasi deteksi kesegaran ikan menggunakan teknologi Machine Learning (CNN).\n\nDikembangkan oleh Kelompok 6 - Program Studi Teknologi Informasi, Universitas Telkom Surabaya, 2026.',
        ),
      ],
    );
  }
}


class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(0),
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1B3E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A9BB5),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCD5E3), size: 20),
          ],
        ),
      ),
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
      style: const TextStyle(fontSize: 14, color: Color(0xFF0D1B3E)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A9BB5)),
        prefixIcon: Icon(icon, color: const Color(0xFF1A4FA0), size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF4F6FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE3EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A4FA0), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEF2F8)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
