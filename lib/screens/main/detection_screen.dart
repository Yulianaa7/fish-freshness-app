import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/inspection_model.dart';
import '../../services/api_service.dart';

class DetectionScreen extends StatefulWidget {
  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? imageFile;
  Interpreter? interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  bool _isSaving = false;

  String? _resultLabel;
  double? _confidence;
  bool? _isFresh;

  final _fishNameCtrl = TextEditingController();

  final List<String> classes = [
    "eye-fresh",
    "eye-non-fresh",
    "gill-fresh",
    "gill-non-fresh"
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    _fishNameCtrl.dispose();
    super.dispose();
  }

  Future<void> loadModel() async {
    try {
      final byteData = await rootBundle.load('assets/fish_model.tflite');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/fish_model.tflite');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      interpreter = await Interpreter.fromFile(tempFile);
      if (mounted) setState(() => _isModelLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat model: $e'),
          backgroundColor: AppColors.nonFresh,
        ));
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (!_isModelLoaded || _isProcessing) return;
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (pickedFile == null) return;

    setState(() {
      imageFile = File(pickedFile.path);
      _resultLabel = null;
      _confidence = null;
      _isFresh = null;
      _isProcessing = true;
    });
    await _runModel();
  }

  Float32List preprocessImage(File file) {
    img.Image image = img.decodeImage(file.readAsBytesSync())!;
    img.Image resized = img.copyResize(image, width: 224, height: 224);
    Float32List input = Float32List(1 * 224 * 224 * 3);
    int index = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        img.Pixel pixel = resized.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }
    return input;
  }

  Future<void> _runModel() async {
    if (imageFile == null || interpreter == null) {
      setState(() => _isProcessing = false);
      return;
    }
    try {
      Float32List input = await Future(() => preprocessImage(imageFile!));
      var output = List.generate(1, (_) => List.filled(4, 0.0));
      interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      double maxScore = output[0][0];
      int maxIndex = 0;
      for (int i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }

      setState(() {
        _resultLabel = classes[maxIndex];
        _confidence = maxScore;
        _isFresh = !_resultLabel!.contains('non');
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saat memproses: $e'),
          backgroundColor: AppColors.nonFresh,
        ));
      }
    }
  }

  Future<void> _saveResult() async {
    if (_resultLabel == null || imageFile == null) return;

    // Show name dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Simpan Hasil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _fishNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nama Ikan',
            hintText: 'cth: Ikan Nila, Ikan Lele...',
            prefixIcon: Icon(Icons.set_meal),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _doSave();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _doSave() async {
    if (_resultLabel == null) return;
    setState(() => _isSaving = true);

    // TODO: Ganti dengan ApiService.saveInspection() saat backend siap
    await Future.delayed(const Duration(seconds: 1)); // simulasi loading
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('⚠️ Backend belum tersambung. Data tidak disimpan.'),
      backgroundColor: AppColors.warning,
    ));
  }

  void _reset() => setState(() {
        imageFile = null;
        _resultLabel = null;
        _confidence = null;
        _isFresh = null;
        _fishNameCtrl.clear();
      });

  // ─── UI helpers ─────────────────────────────────────
  String get _partLabel {
    if (_resultLabel == null) return '';
    if (_resultLabel!.startsWith('eye')) return 'Mata Ikan';
    return 'Insang Ikan';
  }

  String get _freshnessLabel {
    if (_resultLabel == null) return '';
    return _isFresh! ? 'Segar' : 'Tidak Segar';
  }

  Color get _freshnessColor =>
      (_isFresh ?? false) ? AppColors.fresh : AppColors.nonFresh;

  Color get _freshnessBg =>
      (_isFresh ?? false) ? AppColors.freshLight : AppColors.nonFreshLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text(
              'Deteksi Kesegaran Ikan',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loading indicator model
                  if (!_isModelLoaded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(children: [
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.warning)),
                        const SizedBox(width: 12),
                        const Text('Memuat model AI...',
                            style: TextStyle(color: AppColors.warning)),
                      ]),
                    ),

                  if (!_isModelLoaded) const SizedBox(height: 16),

                  // Image area
                  GestureDetector(
                    onTap: _isModelLoaded
                        ? () => _showImageSourceSheet()
                        : null,
                    child: Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: imageFile != null
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.divider,
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      child: _isProcessing
                          ? _buildProcessing()
                          : imageFile != null
                              ? _buildImagePreview()
                              : _buildEmptyState(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  if (_resultLabel == null)
                    Row(children: [
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.photo_camera,
                          label: 'Kamera',
                          color: AppColors.primary,
                          onTap: _isModelLoaded
                              ? () => pickImage(ImageSource.camera)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.photo_library,
                          label: 'Galeri',
                          color: AppColors.primaryLight,
                          onTap: _isModelLoaded
                              ? () => pickImage(ImageSource.gallery)
                              : null,
                        ),
                      ),
                    ]),

                  // Result card
                  if (_resultLabel != null) ...[
                    _buildResultCard(),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Deteksi Lagi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveResult,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_alt),
                          label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                        ),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 24),

                  // Tips card
                  _buildTipsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 64, color: AppColors.textGrey.withOpacity(0.5)),
        const SizedBox(height: 12),
        Text('Ambil atau pilih gambar mata/insang ikan',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Klik di sini untuk memilih',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildProcessing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('Menganalisis gambar...',
            style:
                TextStyle(color: AppColors.textGrey, fontSize: 14)),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(imageFile!, fit: BoxFit.cover),
          if (_resultLabel != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _freshnessColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_freshnessLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _freshnessBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _freshnessColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isFresh! ? Icons.check_circle : Icons.cancel,
                  color: _freshnessColor, size: 28),
              const SizedBox(width: 10),
              Text(
                _freshnessLabel,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _freshnessColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Bagian Ikan', value: _partLabel),
          const SizedBox(height: 6),
          _InfoRow(
              label: 'Confidence',
              value: '${(_confidence! * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 6),
          _InfoRow(
              label: 'Status',
              value: _isFresh!
                  ? 'Layak dikonsumsi ✅'
                  : 'Tidak layak dikonsumsi ❌'),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
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
          Row(children: [
            const Icon(Icons.lightbulb_outline,
                color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            const Text('Tips Pengambilan Gambar',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 12),
          _TipItem('Ambil gambar dengan pencahayaan yang cukup'),
          _TipItem('Pastikan mata atau insang ikan terlihat jelas'),
          _TipItem('Hindari gambar yang buram atau terlalu jauh'),
          _TipItem('Fokuskan pada satu bagian: mata atau insang saja'),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Sumber Gambar',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceOption(
                    icon: Icons.photo_camera,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    }),
                _SourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textGrey, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark)),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(color: AppColors.primary, fontSize: 16)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 13))),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}