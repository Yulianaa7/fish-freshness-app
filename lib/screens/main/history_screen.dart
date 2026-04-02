import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/inspection_model.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<InspectionModel> _items = [];
  bool _loading = true;
  String _filter = 'all'; // all | fresh | non-fresh

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Saat backend belum siap, tampilkan data kosong
    // TODO: Ganti dengan ApiService.getInspections() saat backend siap
    setState(() {
      _items = [];
      _loading = false;
    });
  }

  List<InspectionModel> get _filtered {
    if (_filter == 'fresh') return _items.where((e) => e.isFresh).toList();
    if (_filter == 'non-fresh')
      return _items.where((e) => !e.isFresh).toList();
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
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.nonFresh),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await ApiService.deleteInspection(item.id!);
      if (ok) _load();
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          if (!_loading) _buildSummary(),
          // Filter chips
          _buildFilterBar(),
          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) =>
                              _buildCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final fresh = _items.where((e) => e.isFresh).length;
    final nonFresh = _items.length - fresh;
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _SummaryChip(
              label: 'Total', value: _items.length.toString(), icon: Icons.list),
          const SizedBox(width: 8),
          _SummaryChip(
              label: 'Segar',
              value: fresh.toString(),
              icon: Icons.check_circle,
              color: Colors.greenAccent),
          const SizedBox(width: 8),
          _SummaryChip(
              label: 'Tidak Segar',
              value: nonFresh.toString(),
              icon: Icons.cancel,
              color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _FilterChip(
              label: 'Semua',
              active: _filter == 'all',
              onTap: () => setState(() => _filter = 'all')),
          const SizedBox(width: 8),
          _FilterChip(
              label: 'Segar',
              active: _filter == 'fresh',
              color: AppColors.fresh,
              onTap: () => setState(() => _filter = 'fresh')),
          const SizedBox(width: 8),
          _FilterChip(
              label: 'Tidak Segar',
              active: _filter == 'non-fresh',
              color: AppColors.nonFresh,
              onTap: () => setState(() => _filter = 'non-fresh')),
        ],
      ),
    );
  }

  Widget _buildCard(InspectionModel item) {
    final color = item.isFresh ? AppColors.fresh : AppColors.nonFresh;
    final bgColor =
        item.isFresh ? AppColors.freshLight : AppColors.nonFreshLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image or icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.eyeImagePath != null || item.gillImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.eyeImagePath ?? item.gillImagePath ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.set_meal, color: color, size: 32),
                        ),
                      )
                    : Icon(Icons.set_meal, color: color, size: 32),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.fishName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.freshnessLabel,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text('• ${item.partLabel}',
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.inspectedAt),
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Confidence + delete
              Column(
                children: [
                  Text(
                    '${(item.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _delete(item),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.textGrey, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(InspectionModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(item.fishName,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 16),
              _DetailRow('Status', item.freshnessLabel),
              _DetailRow('Bagian Diperiksa', item.partLabel),
              _DetailRow('Confidence',
                  '${(item.confidence * 100).toStringAsFixed(2)}%'),
              _DetailRow('Layak Konsumsi', item.isFresh ? 'Ya ✅' : 'Tidak ❌'),
              _DetailRow('Tanggal Periksa', _formatDate(item.inspectedAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history,
              size: 72, color: AppColors.textGrey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Belum ada riwayat pemeriksaan',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _load,
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryChip(
      {required this.label,
      required this.value,
      required this.icon,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.active,
      required this.onTap,
      this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: active ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}