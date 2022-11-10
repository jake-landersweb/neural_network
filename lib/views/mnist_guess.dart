import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nn/neural_network.dart';
import 'package:flutter_nn/vector/root.dart';
import 'package:flutter_nn/views/draw_view.dart';
import 'package:flutter_nn/views/root.dart';
import 'dart:math' as math;

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
    // String modelName = "1668055892110.json";
    NeuralNetwork nn = await _loadModel(modelName);
    setState(() {
      _nn = nn;
      _isLoading = false;
    });
    debugPrint("Model loaded");
  }

  @override
  Widget build(BuildContext context) {
    if (getSmallerSize(context) > 700) {
      return _largeContent(context);
    } else {
      return _smallContent(context);
    }
  }

  Widget _header(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await Clipboard.setData(
          const ClipboardData(
            text: "https://github.com/jake-landersweb/dart_nn",
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully copied repo link.",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Color.fromRGBO(65, 65, 160, 1),
        ));
      },
      child: const Text(
        "Check out the repository: https://github.com/jake-landersweb/dart_nn",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _results(
    BuildContext context, {
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _predictions.length / 2; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var j = i; j < i + 2; j++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${i + j}: ${(_predictions[i + j] * 100).toStringAsPrecision(3)}%",
                      style: TextStyle(
                        fontSize: Vector1.from(_predictions).maxIndex() == i + j
                            ? 22
                            : 18,
                        fontWeight:
                            Vector1.from(_predictions).maxIndex() == i + j
                                ? FontWeight.w600
                                : FontWeight.w400,
                        color: Colors.white.withOpacity(
                          Vector1.from(_predictions).maxIndex() == i + j
                              ? 1
                              : 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _largeContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                color: Colors.white.withOpacity(0.05),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: getSmallerSize(context) * 0.8,
                      width: getSmallerSize(context) * 0.8,
                      // child: const NNPainer(),
                      child: DrawView(
                        onDraw: (val) => predict(val),
                        pixelSize: getSmallerSize(context) * 0.7 ~/ 28,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _results(context,
                            maxWidth: getSmallerSize(context) * 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: _results(context, maxHeight: 300),
        ),
        Expanded(
            child: DrawView(
          onDraw: (val) => predict(val),
          pixelSize: MediaQuery.of(context).size.height * 0.35 ~/ 28,
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
          child: _header(context),
        ),
      ],
    );
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

  double getSmallerSize(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return height > width ? width : height;
  }
}
