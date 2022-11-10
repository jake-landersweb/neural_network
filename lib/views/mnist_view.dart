import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nn/datasets/nnimage.dart';
import 'package:flutter_nn/views/root.dart';

class MnistView extends StatefulWidget {
  const MnistView({super.key});

  @override
  State<MnistView> createState() => _MnistViewState();
}

class _MnistViewState extends State<MnistView> {
  List<NNImage>? _images;
  int _index = 0;
  NNImage? _randomImage;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    print("# Reading mnist data");
    // String bytes = await rootBundle
    //     .loadString("lib/datasets/raw_data/mnist/mnist_test.csv");
    String bytes = await rootBundle
        .loadString("lib/datasets/raw_data/mnist/mnist_test.csv");

    // fetch images in separate thread to prevent
    // ui stuttering.
    List<NNImage> imgs = await compute(_getImages, bytes);
    print("# Successfully loaded mnist images");
    setState(() {
      _images = imgs;
      _randomImage = NNImage.from(imgs[_index]).randomized();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_images == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Label: ${_images![_index].label}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NNImageView(
                  image: _images![_index],
                  pixelSize: 15,
                ),
                if (_randomImage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: NNImageView(
                      image: _randomImage!,
                      pixelSize: 15,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _index = Random().nextInt(_images!.length);
                  }),
                  child: const Text("Next Image"),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _randomImage = NNImage.from(_images![_index]).randomized();
                  }),
                  child: const Text("Randomize"),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

/// static function for fetching images, used
/// in an isolate to prevent ui stuttering
Future<List<NNImage>> _getImages(String bytes) async {
  List<String> lines = bytes.split("\n");

  int lineCount = 0;
  List<NNImage> images = [];
  for (var line in lines) {
    // ignore first line because it is a header line
    if (lineCount != 0 && lineCount != lines.length - 1) {
      // split by ',' because of csv
      List<String> values = line.split(",");
      // label is the first value in the file
      int label = int.parse(values[0]);
      // if the label failed to parse for whatever reason just ignore it
      List<double> image = [];
      // get each image as a flat array of size 28*28
      for (int i = 0; i < 28 * 28; i++) {
        // scale all pixel values between 0 and 1
        image.add(int.parse(values[i + 1]).toDouble() / 255);
      }
      images.add(NNImage(image: image, label: label, size: 28));
    }
    lineCount++;
  }
  return images;
}
