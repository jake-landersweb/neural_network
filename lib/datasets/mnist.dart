import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_nn/extra/root.dart';

/// Get the mnist dataset containing handwritten numbers
/// in 28x28 black/white images
class Mnist {
  Future<Tuple2<List<List<double>>, List<int>>> readTrain() async {
    print("Fetching mnist training data ...");
    var data = await _readData(
        "/Users/jakelanders/code/flutter_nn/lib/datasets/raw_data/mnist/mnist_train.csv");
    print("Done fetching mnist training data.");
    return data;
  }

  Future<Tuple2<List<List<double>>, List<int>>> readTest() async {
    print("Fetching mnist testing data ...");
    var data = await _readData(
        "/Users/jakelanders/code/flutter_nn/lib/datasets/raw_data/mnist/mnist_test.csv");
    print("Done fetching mnist testing data.");
    return data;
  }

  Future<Tuple2<List<List<double>>, List<int>>> _readData(
      String filename) async {
    // read file as stream because of file size
    final file = File(filename);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter());

    int lineCount = 0;
    List<List<double>> images = [];
    List<int> labels = [];
    try {
      await for (var line in lines) {
        // ignore first line because it is a header line
        if (lineCount != 0) {
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
          images.add(image);
          labels.add(label);
        }
        lineCount++;
      }
      return Tuple2(v1: images, v2: labels);
    } catch (e, stacktrace) {
      throw "There was an issue reading the file: $e\n$stacktrace";
    }
  }
}
