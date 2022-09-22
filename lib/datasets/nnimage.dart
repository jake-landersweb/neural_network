import 'package:flutter_nn/datasets/image_processor.dart';
import 'package:flutter_nn/extra/tuple.dart';
import 'package:flutter_nn/vector/root.dart';

/// Wrapper to hold image data along with a label
class NNImage {
  late List<double> image;
  late int label;
  late int size;

  NNImage({
    required this.image,
    required this.label,
    required this.size,
  });

  /// make a copy of an image
  NNImage.from(NNImage image) {
    this.image = List.from(image.image);
    label = image.label;
    size = image.size;
  }

  /// Randomize the image position, andgle, noise, and scale
  NNImage randomized() {
    ImageProcessor imageProcessor = ImageProcessor();
    return imageProcessor.transformImage(
      this,
      TransformationSettings.random(),
    );
  }

  /// Convert to a format that looks closer to the
  /// draw style. Pixels are either 1, 0.3, or 0
  NNImage toDrawStyle() {
    List<double> values = [];
    for (var i in this.image) {
      if (i > .9) {
        values.add(1);
      } else if (i >= .3) {
        values.add(0.3);
      } else {
        values.add(0);
      }
    }
    return NNImage(image: values, label: label, size: size);
  }
}

/// Convert list of images to format suitable
/// to be trained on network
Tuple2<Vector2, Vector1> imagesToVectors(List<NNImage> images) {
  Vector2 data = Vector2.empty();
  Vector1 labels = Vector1.empty();

  for (NNImage i in images) {
    data.add(Vector1.from(i.image));
    labels.add(i.label);
  }
  return Tuple2(v1: data, v2: labels);
}
