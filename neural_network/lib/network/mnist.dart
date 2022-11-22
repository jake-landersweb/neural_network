import 'dart:convert';
import 'dart:io';
import 'package:neural_network/network/image_processor.dart';
import 'package:neural_network/network/nnimage.dart';
import 'package:neural_network/network/utils.dart';

Future<List<NNImage>> readData(
  String filename, {
  NNImage Function(NNImage image)? modification,
}) async {
  // read file as stream because of file size
  final file = File(filename);
  Stream<String> lines = file
      .openRead()
      .transform(utf8.decoder) // Decode bytes to UTF-8.
      .transform(const LineSplitter());

  int lineCount = 0;
  List<NNImage> images = [];

  await for (var line in lines) {
    // ignore first line because it is a header line
    if (lineCount != 0) {
      // split by ',' because of csv
      List<String> values = line.split(",");
      // label is the first value in the file
      var label = int.parse(values[0]);
      // if the label failed to parse for whatever reason just ignore it
      List<double> image = [];
      // get each image as a flat array of size 28*28
      for (int i = 0; i < 28 * 28; i++) {
        // scale all pixel values between 0 and 1
        image.add(int.parse(values[i + 1]).toDouble() / 255);
      }
      if (modification == null) {
        images.add(NNImage(image: image, label: label, size: 28));
      } else {
        images.add(modification(NNImage(image: image, label: label, size: 28)));
      }
    }
    lineCount++;
  }
  return images;
}
