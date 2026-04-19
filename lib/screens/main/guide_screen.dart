import 'package:flutter/material.dart';

// --- Design Tokens (Oceanic Lens) ---
class _OLColors {
  static const primary = Color(0xFF003366);
  static const accent = Color(0xFF1DB37E);
  static const bg = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF0D1B2A);
  static const textGrey = Color(0xFF64748B);
  static const danger = Color(0xFFE11D48);
  static const cardBg = Colors.white;
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _OLColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: const Icon(Icons.menu, color: _OLColors.primary),
        title: const Text("FRESHNET", 
          style: TextStyle(color: _OLColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            // child: CircleAvatar(radius: 15, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=meisya')),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildVisualStandardCard(
              title: "Eye Clarity & Convexity",
              imagePath: "assets/images/fish_eye_guide.jpeg", 
              description: "Ikan segar harus memiliki mata yang jernih, cerah, dan menonjol. Kornea yang keruh menandakan aktivitas bakteri.",
              target: "Crystal Clear. Pupil harus hitam pekat dengan kornea jernih.",
              warning: "Opacity. Warna putih susu atau abu menandakan penurunan kualitas.",
            ),
            _buildVisualStandardCard(
              title: "Gill Coloration",
              imagePath: "assets/images/fish_gill_guide.jpeg",
              description: "Insang harus berwarna merah cerah atau pink tua. Warna abu atau cokelat menandakan deplesi oksigen.",
              target: "Bright Cherry Red. Tekstur bersih tanpa lendir berlebih.",
              warning: "Faded Grey. Aroma amis menyengat dan warna pudar.",
            ),
            _buildVisualStandardCard(
              title: "Muscle Texture",
              imagePath: "assets/images/fish_meat_guide.jpeg",
              description: "Tekan daging dengan jari. Jika kembali ke bentuk semula dengan cepat, struktur jaringan masih optimal.",
              target: "Firm & Elastic. Daging menempel kuat pada tulang.",
              warning: "Soft Texture. Meninggalkan bekas lekukan permanen saat ditekan.",
            ),
            _buildPreservationSection(),
            const SizedBox(height: 100), // Spasi untuk bottom nav
          ],
        ),
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _OLColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: const Text("EDUCATION MODULE", style: TextStyle(color: _OLColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text("Integritas Kesegaran \nStandar Visual", 
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _OLColors.textDark, height: 1.1)),
          const SizedBox(height: 12),
          const Text(
            "Pelajari standar 'Precision Vitality' kami untuk mengenali kesegaran melalui observasi marker fisiologis.",
            style: TextStyle(color: _OLColors.textGrey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualStandardCard({
    required String title,
    required String imagePath,
    required String description,
    required String target,
    required String warning,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _OLColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Box
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[300],
            child: Image.asset(imagePath, fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _OLColors.textDark)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: _OLColors.textGrey, fontSize: 13, height: 1.5)),
                const SizedBox(height: 16),
                
                _buildLogicBadge(Icons.check_circle, "Target: $target", _OLColors.accent),
                const SizedBox(height: 8),
                // Warning Logic Badge
                _buildLogicBadge(Icons.cancel, "Warning: $warning", _OLColors.danger),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogicBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // --- Preservation Tips Section ---
  Widget _buildPreservationSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preservation Tips", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _OLColors.textDark)),
          const SizedBox(height: 20),
          _buildTipItem("01", "Thermal Velocity", "Transportasi ikan dalam 'slurry ice' (90% es, 10% air laut) untuk menjaga suhu jaringan."),
          _buildTipItem("02", "Odor Calibration", "Ikan segar tidak berbau amis menyengat; aromanya cenderung seperti air laut atau mentimun."),
          _buildTipItem("03", "Skin Slime Integrity", "Lendir tipis dan transparan adalah tanda proteksi alami ikan yang baru ditangkap."),
        ],
      ),
    );
  }

  Widget _buildTipItem(String number, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: _OLColors.primary, shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _OLColors.textDark)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: _OLColors.textGrey, fontSize: 12, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}