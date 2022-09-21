import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nn/main.dart';
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
  NeuralNetwork? nn;

  @override
  void initState() {
    _predictions = List.generate(10, (index) => 0);
    super.initState();

    loadModel();
  }

  void loadModel() async {
    ByteData bytes = await rootBundle.load(
        "lib/models/layers-[784, 1000, 10]-loss[cat_ce]-opt[adam]-1663724188699.json.gz");
    final buffer = bytes.buffer;
    List<int> compressed = buffer.asUint8List().toList();
    List<int> decompressed = gzip.decode(compressed);
    String json = utf8.decode(decompressed);
    nn = NeuralNetwork.fromJson(json);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DrawView(
                gridSize: 28,
                pixelSize: 10,
                onDraw: (vals) {
                  predict(vals);
                },
              ),
              const SizedBox(width: 50),
              SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < _predictions.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "$i: ${(_predictions[i] * 100).toStringAsPrecision(3)}%",
                          style: TextStyle(
                              color: Colors.white.withOpacity(
                                  Vector1.from(_predictions).maxIndex() == i
                                      ? 1
                                      : 0.3)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) const CircularProgressIndicator()
      ],
    );
  }

  void predict(List<List<double>> drawValues) async {
    if (nn != null) {
      // flatten array
      List<double> flatten = [];
      for (List<double> i in drawValues) {
        flatten.addAll(i);
      }
      // spawn isolate to run prediciton through network
      // List<double> predictions =
      //     await compute(nn!.getConfidenceSingle, flatten);
      List<double> predictions = nn!.getConfidenceSingle(flatten);
      setState(() {
        _predictions = predictions;
      });
    }
  }
}
