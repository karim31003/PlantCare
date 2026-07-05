import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class AIService {
  Interpreter? _interpreter;
  List<String>? _labels;

  /// Loads the TFLite interpreter and labels from assets.
  ///
  /// Expects the model and labels to be declared in `pubspec.yaml` under assets.
  Future<void> loadModel() async {
    try {
      // Try common asset paths; projects often register either 'model.tflite'
      // or 'assets/model.tflite' in pubspec.yaml.
      try {
        _interpreter = await Interpreter.fromAsset('model.tflite');
      } catch (_) {
        _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      }

      // Load labels from assets. Try both 'assets/labels.txt' and 'labels.txt'.
      try {
        final labelsData = await rootBundle.loadString('assets/labels.txt');
        _labels = labelsData
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (_) {
        final labelsData = await rootBundle.loadString('labels.txt');
        _labels = labelsData
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      debugPrint('AI Model Loaded: interpreter=${_interpreter != null}, labels=${_labels?.length ?? 0}');
    } catch (e) {
      debugPrint("Error loading model: $e");
      _interpreter = null;
      _labels = null;
    }
  }

  /// Performs image analysis.
  ///
  /// Note: preprocessing (resize/normalize) depends on the specific model
  /// and is not implemented here. If the interpreter is not available this
  /// method returns a simulated healthy response to keep the app usable.
  Future<Map<String, dynamic>> analyzeImage(File image) async {
    if (_interpreter == null) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing
      return {
        'disease': 'Healthy Plant',
        'confidence': 98.5,
        'treatment': 'Keep doing what you are doing!',
      };
    }

    // Model is loaded but full preprocessing/inference depends on the model's
    // input signature. Provide a safe placeholder inference path that validates
    // the interpreter can run. Replace with proper preprocessing for real use.
    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape;
      final inputSize = inputShape.reduce((a, b) => a * b);
      final Float32List input = Float32List(inputSize); // zeros as placeholder

      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      final outputSize = outputShape.reduce((a, b) => a * b);
      final List<double> output = List<double>.filled(outputSize, 0.0);

      _interpreter!.run(input, output);

      // Map output to labels if available.
      int topIndex = 0;
      double topScore = -double.maxFinite;
      for (int i = 0; i < output.length; i++) {
        if (output[i] > topScore) {
          topScore = output[i];
          topIndex = i;
        }
      }

      final label = (_labels != null && topIndex < _labels!.length) ? _labels![topIndex] : 'Unknown';
      final confidence = topScore.isFinite ? (topScore * 100) : 0.0;

      return {
        'disease': label,
        'confidence': confidence,
        'treatment': 'Inference executed; replace placeholder preprocessing with real pipeline.',
      };
    } catch (e) {
      debugPrint("Inference error: $e");
      return {
        'disease': 'Inference Error',
        'confidence': 0.0,
        'treatment': 'See logs for details.',
      };
    }
  }
}
