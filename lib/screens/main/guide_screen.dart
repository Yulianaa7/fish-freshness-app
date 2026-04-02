import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class GuideScreen extends StatelessWidget {
  final List<_GuideCategory> categories = [
    _GuideCategory(
      icon: Icons.visibility,
      title: 'Ciri-Ciri Mata Ikan Segar',
      color: Color(0xFF1565C0),
      items: [
        _GuideItem('Mata Jernih & Menonjol',
            'Mata ikan segar tampak jernih, cerah, dan sedikit menonjol ke luar. Tidak ada kekeruhan pada kornea.'),
        _GuideItem('Pupil Hitam Pekat',
            'Pupil mata berwarna hitam pekat dan tidak pudar. Ikan yang tidak segar akan memiliki pupil yang tampak keabu-abuan atau putih.'),
        _GuideItem('Tidak Cekung',
            'Mata ikan segar tidak cekung ke dalam. Jika mata sudah mulai cekung, artinya ikan mulai mengalami penurunan kualitas.'),
      ],
    ),
    _GuideCategory(
      icon: Icons.water,
      title: 'Warna & Kondisi Insang',
      color: Color(0xFFC62828),
      items: [
        _GuideItem('Merah Cerah atau Merah Muda',
            'Insang ikan segar berwarna merah cerah atau merah muda segar. Warna menunjukkan kandungan oksigen yang baik dalam darah ikan.'),
        _GuideItem('Tidak Berlendir Berlebih',
            'Insang yang segar tidak memiliki lendir berlebihan. Lendir yang banyak dapat menandakan ikan sudah mulai membusuk.'),
        _GuideItem('Tidak Berbau Amis Menyengat',
            'Bau insang ikan segar seperti bau laut yang segar. Bau busuk atau amis yang sangat menyengat menandakan ikan sudah tidak segar.'),
      ],
    ),
    _GuideCategory(
      icon: Icons.touch_app,
      title: 'Tekstur Daging Ikan',
      color: Color(0xFF2E7D32),
      items: [
        _GuideItem('Kenyal saat Ditekan',
            'Tekan daging ikan dengan jari — jika kembali ke bentuk semula dengan cepat, ikan masih segar. Daging yang lembek dan tidak kembali menandakan ikan sudah lama.'),
        _GuideItem('Tidak Mudah Lepas dari Tulang',
            'Ikan segar dagingnya masih menempel kuat pada tulang. Daging yang mudah terlepas dari tulang adalah tanda ikan sudah tidak segar.'),
        _GuideItem('Warna Daging Cerah',
            'Daging ikan segar berwarna cerah sesuai jenisnya — putih bersih, merah muda, atau oranye. Hindari daging yang sudah kecokelatan atau kusam.'),
      ],
    ),
    _GuideCategory(
      icon: Icons.store,
      title: 'Tips Memilih di Pasar',
      color: Color(0xFFF57F17),
      items: [
        _GuideItem('Perhatikan Suhu Penyimpanan',
            'Ikan segar harus disimpan di atas es atau di lemari pendingin. Hindari membeli ikan yang dibiarkan di suhu ruangan terlalu lama.'),
        _GuideItem('Beli di Pagi Hari',
            'Waktu terbaik membeli ikan adalah pagi hari saat pasokan ikan baru tiba. Kualitas ikan di pasar cenderung menurun menjelang siang.'),
        _GuideItem('Perhatikan Sisik Ikan',
            'Sisik ikan segar menempel kuat dan mengkilap. Sisik yang mudah lepas atau kusam bisa menandakan ikan sudah tidak fresh.'),
        _GuideItem('Hindari Bau Menyengat',
            'Bau ikan segar seperti aroma laut yang bersih. Aroma amis atau busuk yang kuat adalah tanda ikan sudah tidak layak dikonsumsi.'),
      ],
    ),
  ];

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
              'Panduan Kesegaran Ikan',
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primaryLight.withOpacity(0.08)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pelajari cara mengenali ikan segar secara visual untuk mendukung hasil deteksi AI.',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Categories
                  ...categories.map((cat) => _CategoryCard(cat)).toList(),
                  const SizedBox(height: 8),
                  // Freshness scale
                  _buildFreshnessScale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessScale() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skala Kesegaran Ikan',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 15)),
          const SizedBox(height: 16),
          _ScaleRow(
            color: AppColors.fresh,
            level: 'Sangat Segar',
            desc: 'Baru ditangkap, < 24 jam. Mata jernih, insang merah cerah.',
          ),
          const Divider(height: 16),
          _ScaleRow(
            color: AppColors.warning,
            level: 'Mulai Menurun',
            desc: '1–2 hari. Mata mulai keruh, insang mulai pudar.',
          ),
          const Divider(height: 16),
          _ScaleRow(
            color: AppColors.nonFresh,
            level: 'Tidak Segar',
            desc: '> 2 hari tanpa pendinginan. Tidak layak dikonsumsi.',
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _GuideCategory category;
  const _CategoryCard(this.category);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.category.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.category.icon,
                        color: widget.category.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.category.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),
          ),
          // Items
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.category.items.asMap().entries.map((entry) {
              final isLast = entry.key == widget.category.items.length - 1;
              return _GuideItemWidget(
                  entry.value, widget.category.color, isLast);
            }).toList(),
          ],
        ],
      ),
    );
  }
}

class _GuideItemWidget extends StatelessWidget {
  final _GuideItem item;
  final Color color;
  final bool isLast;
  const _GuideItemWidget(this.item, this.color, this.isLast);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(item.desc,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 36),
      ],
    );
  }
}

class _ScaleRow extends StatelessWidget {
  final Color color;
  final String level, desc;
  const _ScaleRow(
      {required this.color, required this.level, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(desc,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideCategory {
  final IconData icon;
  final String title;
  final Color color;
  final List<_GuideItem> items;
  _GuideCategory(
      {required this.icon,
      required this.title,
      required this.color,
      required this.items});
}

class _GuideItem {
  final String title, desc;
  _GuideItem(this.title, this.desc);
}