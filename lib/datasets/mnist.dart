// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:neural_network/datasets/nnimage.dart';

// data from: https://www.kaggle.com/datasets/oddrationale/mnist-in-csv?resource=download

/// Get the mnist dataset containing handwritten numbers
/// in 28x28 black/white images
class Mnist {
  Future<List<NNImage>> readTrain() async {
    print("Loading mnist training data ...");
    var data = await _readData(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_train.csv");
    print("Done fetching mnist training data.");
    return data;
  }

  Future<List<NNImage>> readTest() async {
    print("Loading mnist testing data ...");
    var data = await _readData(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_test.csv");
    print("Done fetching mnist testing data.");
    return data;
  }

  Future<List<NNImage>> readTrainRandom() async {
    print("Loading mnist training data randomized ...");
    var data = await _readDataRandom(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_train.csv");
    print("Done fetching mnist training data.");
    return data;
  }

  Future<List<NNImage>> readTestRandom() async {
    print("Loading mnist testing data randomized ...");
    var data = await _readDataRandom(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_test.csv");
    print("Done fetching mnist testing data.");
    return data;
  }

  Future<List<NNImage>> readTrainToDrawStyle() async {
    print("Loading mnist training data to draw style ...");
    var data = await _readDataToDrawStyle(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_train.csv");
    print("Done fetching mnist training draw style data.");
    return data;
  }

  Future<List<NNImage>> readTestRandomToDrawStyle() async {
    print("Loading mnist testing data to draw style ...");
    var data = await _readDataToDrawStyle(
        "/Users/jakelanders/code/dart_nn/lib/datasets/raw_data/mnist/mnist_test.csv");
    print("Done fetching mnist testing draw style data.");
    return data;
  }

  Future<List<NNImage>> readGenerated() async {
    print("Loading generated mnist data ...");
    var data = await _readData(
        "/Users/jakelanders/code/dart_nn/lib/datasets/generated_data/mnist/dataset-707.csv");
    print("Done fetching generated mnist data");
    return data;
  }

  Future<List<NNImage>> _readData(String filename) async {
    // read file as stream because of file size
    final file = File(filename);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter());

    int lineCount = 0;
    List<NNImage> images = [];
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
          images.add(NNImage(image: image, label: label, size: 28));
        }
        lineCount++;
      }
      return images;
    } catch (e, stacktrace) {
      throw "There was an issue reading the file: $e\n$stacktrace";
    }
  }

  Future<List<NNImage>> _readDataRandom(String filename) async {
    // read file as stream because of file size
    final file = File(filename);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter());

    int lineCount = 0;
    List<NNImage> images = [];
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
          images
              .add(NNImage(image: image, label: label, size: 28).randomized());
        }
        lineCount++;
      }
      return images;
    } catch (e, stacktrace) {
      throw "There was an issue reading the file: $e\n$stacktrace";
    }
  }

  Future<List<NNImage>> _readDataToDrawStyle(String filename) async {
    // read file as stream because of file size
    final file = File(filename);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter());

    int lineCount = 0;
    List<NNImage> images = [];
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
          images
              .add(NNImage(image: image, label: label, size: 28).toDrawStyle());
        }
        lineCount++;
      }
      return images;
    } catch (e, stacktrace) {
      throw "There was an issue reading the file: $e\n$stacktrace";
    }
  }

  // to make images more similar to how the drawing program works
  List<double> _drawify(List<double> input) {
    List<double> scaled = [];
    for (var i in input) {
      if (i > 0.7) {
        scaled.add(1);
      } else if (i > 0.1) {
        scaled.add(0.3);
      } else {
        scaled.add(0);
      }
    }
    return scaled;
  }
}
