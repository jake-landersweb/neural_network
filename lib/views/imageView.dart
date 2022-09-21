import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nn/datasets/image_processor.dart';
import 'package:flutter_nn/datasets/mnist.dart';
import 'package:flutter_nn/extra/tuple.dart';

class ImageView extends StatefulWidget {
  final int imageSize;
  final int pixelSize;
  const ImageView({
    super.key,
    this.imageSize = 28,
    this.pixelSize = 10,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  late List<double> _currentImage;
  late List<double> _randomizedImage;
  List<List<double>>? _availableImages;

  @override
  void initState() {
    _currentImage =
        List.generate(widget.imageSize * widget.imageSize, (_) => 0.0);
    _randomizedImage =
        List.generate(widget.imageSize * widget.imageSize, (_) => 0.0);
    super.initState();
    getImages();
  }

  void getImages() async {
    String file = await rootBundle
        .loadString("lib/datasets/raw_data/mnist/mnist_train.csv");
    List<String> lines = file.split("\n");
    List<List<double>> images = [];
    for (int i = 1; i < lines.length; i++) {
      List<double> temp = [];
      List<String> contents = lines[i].split(",");
      for (int j = 1; j < contents.length; j++) {
        temp.add(double.parse(contents[j]));
      }
      images.add(temp);
    }
    print("Loaded Images");
    _availableImages = images;
    setState(() {
      _currentImage = _scaleImage(images[404]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.imageSize; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int j = 0; j < widget.imageSize; j++)
                          Container(
                            height: widget.pixelSize.toDouble(),
                            width: widget.pixelSize.toDouble(),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                  _currentImage[(i * widget.imageSize) + j]),
                              border:
                                  Border.all(color: Colors.black, width: 0.5),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.imageSize; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int j = 0; j < widget.imageSize; j++)
                          Container(
                            height: widget.pixelSize.toDouble(),
                            width: widget.pixelSize.toDouble(),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                  _randomizedImage[(i * widget.imageSize) + j]),
                              border:
                                  Border.all(color: Colors.black, width: 0.5),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  if (_availableImages != null) {
                    setState(() {
                      _currentImage = _scaleImage(
                          _availableImages![Random().nextInt(60000)]);
                    });
                  }
                },
                child: const Text(
                  "New Image",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  _handle();
                },
                child: const Text(
                  "Randomize",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handle() {
    if (_availableImages != null) {
      setState(() {
        _randomizedImage = ImageProcessor()
            .transformImage(_currentImage, TransformationSettings.random());
      });
    }
  }

  List<double> _scaleImage(List<double> input) {
    List<double> scaled = [];
    for (var i in input) {
      scaled.add(i / 255);
    }
    return scaled;
  }
}
