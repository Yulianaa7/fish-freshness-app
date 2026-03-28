import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fish Freshness Detection",
      debugShowCheckedModeBanner: false,
      home: FishDetector(),
    );
  }
}

class FishDetector extends StatefulWidget {
  @override
  _FishDetectorState createState() => _FishDetectorState();
}

class _FishDetectorState extends State<FishDetector> {
  File? imageFile;
  Interpreter? interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;

  String result = "Upload gambar ikan";

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

  Future<void> loadModel() async {
    try {
      setState(() {
        result = "Memuat model...";
      });

      // Copy asset ke temporary file
      final byteData = await rootBundle.load('assets/fish_model.tflite');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/fish_model.tflite');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      interpreter = await Interpreter.fromFile(tempFile);

      setState(() {
        _isModelLoaded = true;
        result = "Upload gambar ikan";
      });

      print("✅ Model berhasil dimuat");
    } catch (e) {
      setState(() {
        result = "❌ Gagal memuat model: $e";
      });
      print("Error detail: $e");
    }
  }

  Future<void> pickImage() async {
    if (!_isModelLoaded) {
      setState(() {
        result = "Model belum siap, tunggu sebentar...";
      });
      return;
    }

    if (_isProcessing) return;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      imageFile = File(pickedFile.path);
      result = "Memproses gambar...";
      _isProcessing = true;
    });

    await runModel();
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

  Future<void> runModel() async {
    if (imageFile == null || interpreter == null) {
      setState(() {
        result = "Model atau gambar belum siap";
        _isProcessing = false;
      });
      return;
    }

    try {
      Float32List input = await Future(() => preprocessImage(imageFile!));

      var output = List.generate(1, (index) => List.filled(4, 0.0));

      interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      print("Output model: $output");

      double maxScore = output[0][0];
      int maxIndex = 0;

      for (int i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }

      setState(() {
        result =
            "Prediksi: ${classes[maxIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        result = "❌ Error saat memproses: $e";
        _isProcessing = false;
      });
      print("Error runModel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fish Freshness Detection"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageFile != null
                  ? Image.file(imageFile!, height: 250)
                  : Text(
                      "Belum ada gambar",
                      style: TextStyle(fontSize: 18),
                    ),

              SizedBox(height: 30),

              _isProcessing
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isModelLoaded ? pickImage : null,
                      child: Text("Upload Gambar"),
                    ),

              SizedBox(height: 30),

              Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}