import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/inspection_model.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<InspectionModel> _recentItems = [];
  bool _loading = true;
  String _userName = 'M2L2';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = await ApiService.getCachedUser();
    setState(() {
      _userName = user?.name.split(' ').first ?? 'Ian';
      _recentItems = [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(child: _buildHeader()),
            // ─── Hero Card ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildHeroCard(),
              ),
            ),
            // ─── Stats ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildStatsRow(),
              ),
            ),
            // ─── Recent Results ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _buildSectionHeader(),
              ),
            ),
            // ─── List ───
            _loading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    ),
                  )
                : _recentItems.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: _buildFishCard(_recentItems[i]),
                          ),
                          childCount: _recentItems.length,
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.set_meal,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'FRESHNET',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          // Welcome text
          Text(
            'Welcome, $_userName.',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"Ikan segar adalah kunci kesehatan dan kelezatan hidangan."',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero scan card ───
  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004E6E), Color(0xFF006994)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top icon row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.biotech,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Freshness Scanner',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Siap untuk analisis?\nMulai deteksi kesegaran.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan CNN untuk mendeteksi kesegaran ikan dari foto mata atau insang secara real-time.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final state = context.findAncestorStateOfType<DashboardHostState>();
              state?.jumpToScan();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.document_scanner,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  const Text(
                    'MULAI SCAN BARU',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats row ───
  Widget _buildStatsRow() {
    final total = _recentItems.length;
    final fresh = _recentItems.where((e) => e.isFresh).length;
    final precision = total > 0
        ? ((_recentItems
                        .where((e) => e.confidence >= 0.8)
                        .length /
                    total) *
                100)
            .toStringAsFixed(1)
        : '—';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'TOTAL SCAN',
            value: total.toString(),
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'SEGAR',
            value: fresh.toString(),
            icon: Icons.check_circle_outline,
            valueColor: AppColors.fresh,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'AKURASI',
            value: total > 0 ? '$precision%' : '—',
            icon: Icons.bar_chart,
            valueColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ─── Section header ───
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'METADATA TERBARU',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hasil Analisis Terkini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            final state = context.findAncestorStateOfType<DashboardHostState>();
            state?.jumpToHistory();
          },
          child: Row(children: [
            Text(
              'LIHAT SEMUA',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 16),
          ]),
        ),
      ],
    );
  }

  // ─── Fish result card ───
  Widget _buildFishCard(InspectionModel item) {
    final isFresh = item.isFresh;
    final statusColor = isFresh ? AppColors.fresh : AppColors.nonFresh;
    final statusLabel = isFresh ? 'SEGAR' : 'TIDAK SEGAR';
    final indexScore =
        (item.confidence * 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder or actual image
                  item.eyeImagePath != null || item.gillImagePath != null
                      ? Image.file(
                          File(item.eyeImagePath ??
                              item.gillImagePath ?? ''),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.fishName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time + part
                Row(children: [
                  Icon(Icons.access_time,
                      size: 12, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(item.inspectedAt),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    item.partLabel.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ]),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Index score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INDEX SCORE',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textGrey,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          indexScore,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    if (!isFresh)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.nonFreshLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'GENERATE REPORT',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.nonFresh,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right,
                          color: AppColors.textGrey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF0D1B2A),
      child: Center(
        child: Icon(Icons.set_meal,
            color: Colors.white.withOpacity(0.2), size: 56),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.set_meal,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada hasil analisis',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Mulai scan ikan pertamamu sekarang!',
            style:
                TextStyle(color: AppColors.textGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return iso;
    }
  }
}

// Stat Card widget
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? valueColor;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class DashboardHostState<T extends StatefulWidget> extends State<T> {
  void jumpToScan();
  void jumpToHistory();
}