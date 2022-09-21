import 'dart:math' as math;

import 'package:flutter_nn/extra/tuple.dart';
import 'package:flutter_nn/main.dart';

// heavily pulled from https://github.com/SebLague/Neural-Network-Experiments/blob/main/Assets/Scripts/Data+Handling/ImageProcessor.cs
class ImageProcessor {
  List<double> transformImage(
      List<double> original, TransformationSettings settings,
      {int? seed = seed}) {
    math.Random rng = math.Random();
    List<double> transformedImage = List.from(original);
    if (settings.scale != 0) {
      Tuple2<double, double> iHat = Tuple2(
        v1: math.cos(settings.angle) / settings.scale,
        v2: math.sin(settings.angle) / settings.scale,
      );
      Tuple2<double, double> jHat = Tuple2(v1: -iHat.v2, v2: iHat.v1);
      for (int y = 0; y < 28; y++) {
        for (int x = 0; x < 28; x++) {
          double u = x / (28 - 1);
          double v = y / (28 - 1);

          double uTransformed = iHat.v1 * (u - 0.5) +
              jHat.v1 * (v - 0.5) +
              0.5 -
              settings.offset.v1;
          double vTransformed = iHat.v2 * (u - 0.5) +
              jHat.v2 * (v - 0.5) +
              0.5 -
              settings.offset.v2;
          double pixelValue = sample(original, uTransformed, vTransformed);
          double noiseValue = 0;
          if (rng.nextDouble() <= settings.noiseProbability) {
            noiseValue = (rng.nextDouble() - 0.5) * settings.noiseStrength;
          }
          transformedImage[getFlatIndex(transformedImage, x, y)] =
              math.min(math.max(pixelValue + noiseValue, 0), 1);
        }
      }
    }
    return transformedImage;
  }

  double sample(List<double> image, double u, double v) {
    u = math.max(math.min(1, u), 0);
    v = math.max(math.min(1, v), 0);

    double texX = u * (28 - 1);
    double texY = v * (28 - 1);

    int indexLeft = texX.toInt();
    int indexBottom = texY.toInt();
    int indexRight = math.min(indexLeft + 1, 28 - 1);
    int indexTop = math.min(indexBottom + 1, 28 - 1);

    double blendX = texX - indexLeft;
    double blendY = texY - indexBottom;

    double bottomLeft = image[getFlatIndex(image, indexLeft, indexBottom)];
    double bottomRight = image[getFlatIndex(image, indexRight, indexBottom)];
    double topLeft = image[getFlatIndex(image, indexLeft, indexTop)];
    double topRight = image[getFlatIndex(image, indexRight, indexTop)];

    double valueBottom = bottomLeft + (bottomRight - bottomLeft) * blendX;
    double valueTop = topLeft + (topRight - topLeft) * blendX;
    double interpolatedValue = valueBottom + (valueTop - valueBottom) * blendY;
    return interpolatedValue;
  }

  int getFlatIndex(List<double> image, int x, int y) {
    return y * 28 + x;
  }
}

class TransformationSettings {
  late double angle;
  late double scale;
  late Tuple2<double, double> offset;
  late int noiseSeed;
  late double noiseProbability;
  late double noiseStrength;

  TransformationSettings({
    required this.angle,
    required this.scale,
    required this.offset,
    required this.noiseSeed,
    required this.noiseProbability,
    required this.noiseStrength,
  });

  TransformationSettings.random() {
    math.Random rng = math.Random();

    angle = rng.nextInt(50) / 100;
    if (rng.nextBool()) {
      angle = angle * -1;
    }
    scale = (rng.nextInt(50) / 100) + 0.7;
    offset = Tuple2(v1: rng.nextInt(20) / 100, v2: rng.nextInt(20) / 100);
    if (rng.nextBool()) {
      offset.v1 = offset.v1 * -1;
    }
    if (rng.nextBool()) {
      offset.v2 = offset.v2 * -1;
    }
    noiseSeed = rng.nextInt(10000);
    noiseProbability = rng.nextInt(30) / 100;
    noiseStrength = rng.nextInt(40) / 100;

    // angle = randomInNormalDistribution(rng) * 0.15;
    // scale = 1 + randomInNormalDistribution(rng) * 0.1;

    // noiseSeed = rng.nextInt(1000);
    // noiseProbability = math.min(rng.nextDouble(), rng.nextDouble()) * 0.05;
    // noiseStrength = math.min(rng.nextDouble(), rng.nextDouble());

    // int boundsMinX = 28;
    // int boundsMaxX = 0;
    // int boundsMinY = 28;
    // int boundsMaxY = 0;

    // for (int y = 0; y < 28; y++) {
    //   for (int x = 0; x < 28; x++) {
    //     if (rng.nextBool()) {
    //       boundsMinX = math.min(boundsMinX, x);
    //       boundsMaxX = math.max(boundsMaxX, x);
    //       boundsMinY = math.min(boundsMinY, y);
    //       boundsMaxY = math.max(boundsMaxY, y);
    //     }
    //   }
    // }

    // double offsetMinX = -boundsMinX / 28;
    // double offsetMaxX = (28 - boundsMaxX) / 28;
    // double offsetMinY = -boundsMinY / 28;
    // double offsetMaxY = (28 - boundsMaxY) / 28;

    // double offsetX = lerpDouble(offsetMinX, offsetMaxX, rng.nextDouble())!;
    // double offsetY = lerpDouble(offsetMinY, offsetMaxY, rng.nextDouble())!;
    // offset = Tuple2(v1: offsetX * 0.8, v2: offsetY * 0.8);
  }

  double randomInNormalDistribution(math.Random prng,
      [double mean = 0, double standardDeviation = 1]) {
    double x1 = 1 - prng.nextDouble();
    double x2 = 1 - prng.nextDouble();

    double y1 = math.sqrt(-2.0 * math.log(x1)) * math.cos(2.0 * math.pi * x2);
    return y1 * standardDeviation + mean;
  }
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}
