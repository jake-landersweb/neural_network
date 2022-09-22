import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nn/neural_network.dart';
import 'package:flutter_nn/vector/root.dart';
import 'package:flutter_nn/views/draw_view.dart';

class MnistGuess extends StatefulWidget {
  const MnistGuess({super.key});

  @override
  State<MnistGuess> createState() => _MnistGuessState();
}

class _MnistGuessState extends State<MnistGuess> {
  bool _isLoading = true;
  List<double> _predictions = [];
  NeuralNetwork? _nn;

  @override
  void initState() {
    _predictions = List.generate(10, (index) => 0);
    super.initState();
    init();
  }

  void init() async {
    String modelName = "mnist.json";
    NeuralNetwork nn = await _loadModel(modelName);
    setState(() {
      _nn = nn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Neural network implemented in Dart with no packages. Visual representation in Flutter.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Check out the repository: ",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  MediaQuery.of(context).size.width < 700
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _content(context, true),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _content(context, false),
                        ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const CircularProgressIndicator()
      ],
    );
  }

  List<Widget> _content(BuildContext context, bool isVerical) {
    return [
      DrawView(
        gridSize: 28,
        pixelSize:
            (MediaQuery.of(context).size.width * (isVerical ? 0.9 : 0.5)) ~/ 28,
        onDraw: (vals) {
          predict(vals);
        },
      ),
      MediaQuery.of(context).size.width < 700
          ? const SizedBox(height: 16)
          : const SizedBox(width: 50),
      SizedBox(
        width: 300,
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
          ),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int i = 0; i < _predictions.length; i++)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Text(
                    "$i: ${(_predictions[i] * 100).toStringAsPrecision(3)}%",
                    style: TextStyle(
                      fontSize:
                          Vector1.from(_predictions).maxIndex() == i ? 22 : 18,
                      fontWeight: Vector1.from(_predictions).maxIndex() == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: Colors.white.withOpacity(
                        Vector1.from(_predictions).maxIndex() == i ? 1 : 0.3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  void predict(List<List<double>> drawValues) async {
    if (_nn != null) {
      // flatten array
      List<double> flatten = [];
      for (List<double> i in drawValues) {
        for (var j in i) {
          flatten.add(j);
        }
      }
      // get the prediction based on the flattened array
      List<double> predictions = _nn!.getConfidenceSingle(flatten);
      setState(() {
        _predictions = predictions;
      });
    }
  }

  /// Loading model from modelName
  Future<NeuralNetwork> _loadModel(String modelName) async {
    ByteData bytes = await rootBundle.load("lib/models/$modelName");
    final buffer = bytes.buffer;
    List<int> compressed = buffer.asUint8List().toList();
    // List<int> decompressed = gzip.decode(compressed);
    String json = utf8.decode(compressed);
    return NeuralNetwork.fromJson(json);
  }
}
