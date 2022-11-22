import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neural_network/views/draw_view.dart';
import 'package:flutter_neural_network/views/root.dart';
import 'package:neural_network/network/network.dart';
import 'dart:math' as math;
import 'package:universal_html/html.dart' as html;

import 'package:neural_network/network/utils.dart';

class MnistGuess extends StatefulWidget {
  const MnistGuess({super.key});

  @override
  State<MnistGuess> createState() => _MnistGuessState();
}

class _MnistGuessState extends State<MnistGuess> {
  List<double> _predictions = [];
  Network? _nn;

  @override
  void initState() {
    _predictions = List.generate(10, (index) => 0);
    super.initState();
    init();
  }

  void init() async {
    String filename = "../neural_network/models/mnist2.json.gz";
    Network nn = await _loadModel(filename);
    setState(() {
      _nn = nn;
    });
    debugPrint("Model loaded");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _body(context),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40),
            child: Row(
              children: [
                Expanded(
                  child: _headerCell(context, "Github", Icons.code_rounded,
                      "https://github.com/jake-landersweb"),
                ),
                Expanded(
                  child: _headerCell(context, "Blog", Icons.article_outlined,
                      "https://jakelanders.com/blog"),
                ),
                Expanded(
                  child: _headerCell(
                      context,
                      "Contact",
                      Icons.mail_outline_rounded,
                      "https://jakelanders.com/contact"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(
    BuildContext context,
    String title,
    IconData icon,
    String link,
  ) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        right: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
      )),
      child: MaterialButton(
        hoverColor: backgroundAcc,
        splashColor: themeColor,
        highlightColor: backgroundAcc.withOpacity(0.8),
        onPressed: () {
          html.window.open(link, "_self");
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (getSmallerSize(context) > 700) {
      return _largeContent(context);
    } else {
      return _smallContent(context);
    }
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
          Text(
              "Accuracy: ${((_nn?.accuracy ?? 0) * 100).toStringAsPrecision(3)}%"),
          Text("Shape: ${_nn?.shape()}"),
          const SizedBox(height: 16),
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
                        fontSize: _predictions.maxIndex() == i + j ? 22 : 18,
                        fontWeight: _predictions.maxIndex() == i + j
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: Colors.white.withOpacity(
                          _predictions.maxIndex() == i + j ? 1 : 0.3,
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            color: backgroundAcc,
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
      ),
    );
  }

  Widget _smallContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: _results(context, maxHeight: 300),
          ),
          DrawView(
            onDraw: (val) => predict(val),
            pixelSize: MediaQuery.of(context).size.height * 0.35 ~/ 28,
          ),
        ],
      ),
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
      List<double> predictions = _nn!.predict(flatten);
      setState(() {
        _predictions = predictions;
      });
    }
  }

  /// Loading model from modelName
  Future<Network> _loadModel(String filename) async {
    ByteData bytes = await rootBundle.load(filename);
    final buffer = bytes.buffer;
    List<int> compressed = buffer.asUint8List().toList();
    List<int> decompressed = gzip.decode(compressed);
    String json = utf8.decode(decompressed);
    return Network.fromJson(json);
  }

  double getSmallerSize(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return height > width ? width : height;
  }
}
