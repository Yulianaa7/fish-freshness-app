import 'dart:io'; // ✅ FIX: diperlukan untuk File(path) di thumbnail & detail
import 'package:flutter/material.dart';
import '../../models/inspection_model.dart';

class InspectionStorage {
  static final List<InspectionModel> _data = [];

  static void add(InspectionModel item) => _data.insert(0, item);
  static List<InspectionModel> getAll() => List.unmodifiable(_data);
  static void remove(int id) => _data.removeWhere((e) => e.id == id);
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<InspectionModel> _items = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    setState(() {
      _items = InspectionStorage.getAll().toList();
      _loading = false;
    });
  }

  List<InspectionModel> get _filtered {
    if (_filter == 'fresh') return _items.where((e) => e.isFresh).toList();
    if (_filter == 'non-fresh') return _items.where((e) => !e.isFresh).toList();
    return _items;
  }

  Future<void> _delete(InspectionModel item) async {
    if (item.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus data ${item.fishName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      InspectionStorage.remove(item.id!);
      _load();
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "FRESHNET",
          style: TextStyle(
            color: Color(0xFF0D1B3E),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const SizedBox(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D1B3E)),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatCards(),
                        const SizedBox(height: 24),
                        _buildFilterBar(),
                        const SizedBox(height: 16),
                        if (_filtered.isEmpty)
                          _buildEmpty()
                        else
                          ..._filtered.map((item) => _buildCard(item)).toList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat\nPemeriksaan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B3E),
            height: 1.2,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF0D1B3E),
              size: 20,
            ),
            onPressed: _load,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final fresh = _items.where((e) => e.isFresh).length;
    final nonFresh = _items.length - fresh;
    final freshPct = _items.isEmpty ? 0 : ((fresh / _items.length) * 100).round();
    final nonFreshPct = _items.isEmpty ? 0 : 100 - freshPct;

    return Column(
      children: [
        _StatCard(
          label: 'TOTAL',
          value: _items.length.toString(),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.archive_outlined,
              color: Color(0xFF8A9BB5),
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'SEGAR',
          value: fresh.toString(),
          valueColor: const Color(0xFF0A7A5A),
          background: const Color(0xFFF0FBF7),
          trailing: _PctBadge(
            percent: '$freshPct%',
            bgColor: const Color(0xFFD6F5E9),
            textColor: const Color(0xFF0A7A5A),
          ),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'TIDAK SEGAR',
          value: nonFresh.toString(),
          valueColor: const Color(0xFFCC2929),
          background: const Color(0xFFFDF2F2),
          trailing: _PctBadge(
            percent: '$nonFreshPct%',
            bgColor: const Color(0xFFFAD4D4),
            textColor: const Color(0xFFCC2929),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        _FilterPill(
          label: 'Semua',
          active: _filter == 'all',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'all'),
        ),
        const SizedBox(width: 10),
        _FilterPill(
          label: 'Segar',
          active: _filter == 'fresh',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'fresh'),
        ),
        const SizedBox(width: 10),
        _FilterPill(
          label: 'Tidak Segar',
          active: _filter == 'non-fresh',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'non-fresh'),
        ),
      ],
    );
  }

  Widget _buildCard(InspectionModel item) {
    final isFresh = item.isFresh;
    final badgeColor = isFresh ? const Color(0xFF0A7A5A) : const Color(0xFFCC2929);
    final badgeBg = isFresh ? const Color(0xFFD6F5E9) : const Color(0xFFFAD4D4);

    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Fish image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72,
                  height: 72,
                  color: const Color(0xFF0D1220),
                  child: _buildThumbnail(item),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.fishName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B3E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(item.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D1B3E),
                              ),
                            ),
                            const Text(
                              'CONFIDENCE',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8A9BB5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.freshnessLabel.toUpperCase(),
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatDate(item.inspectedAt),
                            style: const TextStyle(
                              color: Color(0xFF8A9BB5),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCCD5E3),
                    size: 22,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _delete(item),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFCCD5E3),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(InspectionModel item) {
    final path = item.eyeImagePath ?? item.gillImagePath;
    if (path == null) {
      return const Icon(Icons.set_meal, color: Colors.white54, size: 32);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.set_meal, color: Colors.white54, size: 32),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.set_meal, color: Colors.white54, size: 32),
      );
    }
  }

  void _showDetail(InspectionModel item) {
    final isFresh = item.isFresh;
    final badgeColor = isFresh ? const Color(0xFF0A7A5A) : const Color(0xFFCC2929);
    final badgeBg = isFresh ? const Color(0xFFD6F5E9) : const Color(0xFFFAD4D4);
    final path = item.eyeImagePath ?? item.gillImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE3EF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Preview gambar
                if (path != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: path.startsWith('http')
                          ? Image.network(path, fit: BoxFit.cover)
                          : Image.file(File(path), fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.fishName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B3E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.freshnessLabel.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailDivider(),
                _DetailRow('Bagian Diperiksa', item.partLabel),
                _detailDivider(),
                _DetailRow(
                  'Confidence',
                  '${(item.confidence * 100).toStringAsFixed(2)}%',
                ),
                _detailDivider(),
                _DetailRow('Layak Konsumsi', item.isFresh ? 'Ya ✅' : 'Tidak ❌'),
                _detailDivider(),
                _DetailRow('Tanggal Periksa', _formatDate(item.inspectedAt)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailDivider() =>
      const Divider(color: Color(0xFFEEF2F8), thickness: 1, height: 1);

  Widget _buildEmpty() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: Color(0xFF8A9BB5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat pemeriksaan',
              style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D1B3E),
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color background;
  final Widget trailing;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trailing,
    this.valueColor = const Color(0xFF0D1B3E),
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A9BB5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _PctBadge extends StatelessWidget {
  final String percent;
  final Color bgColor;
  final Color textColor;

  const _PctBadge({
    required this.percent,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        percent,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF8A9BB5),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A9BB5), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B3E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}