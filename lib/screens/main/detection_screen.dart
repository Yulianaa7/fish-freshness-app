import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../models/inspection_model.dart';
import 'history_screen.dart';

class _OL {
  static const primary = Color(0xFF003366);
  static const accent = Color(0xFF1DB37E);
  static const bg = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF64748B);
  static const danger = Color(0xFFE11D48);
  static const freshBg = Color(0xFFD1FAE5);
}

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? cameras;
  final ImagePicker _picker = ImagePicker();

  File? imageFile;
  Interpreter? interpreter;
  bool _isProcessing = false;

  String? _resultLabel;
  double? _confidence;
  bool? _isFresh;
  String _scanId = "SCAN_ID: 982-A";
  bool _savedToHistory = false;

  final List<String> classes = [
    "eye-fresh",
    "eye-non-fresh",
    "gill-fresh",
    "gill-non-fresh",
  ];

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _loadModel();
    await _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        _initializeControllerFuture = _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/fish_model.tflite');
    } catch (e) {
      debugPrint("Model Error: $e");
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _initializeControllerFuture;
      final XFile capturedImage = await _controller!.takePicture();
      imageFile = File(capturedImage.path);
      await _runInference(imageFile!);
    } catch (e) {
      debugPrint("Capture Error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _isProcessing = true;
        _resultLabel = null;
        _savedToHistory = false;
      });
      await _runInference(imageFile!);
      setState(() => _isProcessing = false);
    }
  }

  void _saveToHistory() {
    if (_resultLabel == null || imageFile == null || _savedToHistory) return;

    final isEye = _resultLabel!.contains('eye');

    final int generatedId = DateTime.now().millisecondsSinceEpoch;
    final double safeConfidence = (_confidence ?? 0.0).toDouble();
    final bool safeIsFresh = _isFresh == true;
    final String now = DateTime.now().toIso8601String();

    final newItem = InspectionModel(
      id: generatedId,
      fishName: isEye ? 'Inspeksi Mata' : 'Inspeksi Insang',
      confidence: safeConfidence,
      resultLabel: _resultLabel ?? '',
      isFresh: safeIsFresh,
      eyeImagePath: isEye ? imageFile!.path : null,
      gillImagePath: !isEye ? imageFile!.path : null,
      inspectedAt: now,
    );

    InspectionStorage.add(newItem);

    setState(() => _savedToHistory = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $_scanId berhasil disimpan ke histori'),
        backgroundColor: _OL.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _runInference(File file) async {
    if (interpreter == null) return;

    // FIX 1: Gunakan readAsBytes() (async) bukan readAsBytesSync() untuk
    // menghindari blocking UI thread
    final Uint8List imageData = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageData);

    if (originalImage == null) {
      debugPrint("Inference Error: Gagal decode gambar");
      return;
    }

    img.Image resizedImage =
        img.copyResize(originalImage, width: 224, height: 224);

    final inputList = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final outputList = List.generate(1, (_) => List.filled(4, 0.0));

    interpreter!.run(inputList, outputList);

    final List<double> scores = List<double>.from(outputList[0]);
    final double maxScore = scores.reduce((a, b) => a > b ? a : b);
    final int maxIndex = scores.indexOf(maxScore);

    setState(() {
      _resultLabel = classes[maxIndex];
      _confidence = maxScore;
      _isFresh = !_resultLabel!.contains('non');
      _scanId = "SCAN_ID: ${980 + DateTime.now().second}-A";
      _savedToHistory = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _OL.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: _OL.primary),
        title: const Text(
          "FRESHNET",
          style: TextStyle(
            color: _OL.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _resultLabel == null ? _buildCameraView() : _buildResultView(),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null) {
                return CameraPreview(_controller!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                },
                icon: const Icon(Icons.flash_on, color: Colors.white),
              ),
              GestureDetector(
                onTap: _captureAndAnalyze,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white30,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: _OL.primary)
                        : const Icon(Icons.camera_alt,
                            color: Colors.black, size: 36),
                  ),
                ),
              ),
              IconButton(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    bool fresh = _isFresh ?? true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: FileImage(imageFile!),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 15,
                  child: _badge(_scanId, Colors.black54, isSolid: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fresh ? _OL.freshBg : const Color(0xFFFFECEC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: fresh
                    ? _OL.accent.withOpacity(0.3)
                    : _OL.danger.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CURRENT STATUS",
                      style: TextStyle(
                        fontSize: 12,
                        color: _OL.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _badge("VERIFIED", fresh ? _OL.accent : _OL.danger),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fresh ? "Segar" : "Tidak Segar",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: fresh ? const Color(0xFF064E3B) : _OL.danger,
                  ),
                ),
                Text(
                  "Hasil deteksi berdasarkan analisis visual TFLite.",
                  style: TextStyle(
                    color: fresh
                        ? const Color(0xFF064E3B).withOpacity(0.7)
                        : _OL.danger.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CONFIDENCE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _OL.textPrimary,
                      ),
                    ),
                    Text(
                      "${((_confidence ?? 0) * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fresh ? const Color(0xFF064E3B) : _OL.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _confidence ?? 0,
                  backgroundColor: fresh
                      ? Colors.black12
                      : _OL.danger.withOpacity(0.1),
                  color: fresh ? _OL.accent : _OL.danger,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fresh
                  ? const Color(0xFFE6FFFA)
                  : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant,
                    color: fresh ? _OL.accent : _OL.danger),
                const SizedBox(width: 12),
                Text(
                  "REKOMENDASI: ${fresh ? "Layak Konsumsi" : "Hindari Konsumsi"}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: fresh ? const Color(0xFF064E3B) : _OL.danger,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savedToHistory ? null : _saveToHistory,
              icon: Icon(
                _savedToHistory ? Icons.check : Icons.history,
                size: 18,
              ),
              label: Text(
                _savedToHistory ? "TERSIMPAN" : "SAVE TO HISTORY",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _savedToHistory ? Colors.grey : _OL.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _resultLabel = null;
                _savedToHistory = false;
              }),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: _OL.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "RESCAN FISH",
                style: TextStyle(
                  color: _OL.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color, {bool isSolid = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSolid ? Colors.transparent : color,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSolid ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}