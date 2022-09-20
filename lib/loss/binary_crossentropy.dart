import 'dart:math' as math;
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/vector/vector2.dart';
import 'package:flutter_nn/vector/vector1.dart';

// TODO -- This probably does not work, verify this works in binary classififation
class LossBinaryCrossentropy extends Loss {
  @override
  Vector1 forward(Vector2 predictions, Vector1 labels) {
    // clip values between 1e-7 and 1-1e-7
    Vector2 clipped = Vector2.empty();
    clipped = clipped.replaceWhere(
      (i, j) => clipped[i][j] > 1 - 1e-7
          ? 1 - 1e-7
          : clipped[i][j] < 1e-7
              ? 1e-7
              : clipped[i][j],
    );
    // calculate samplewise loss
    var sampleLosses = ((labels * clipped.log()) +
            ((labels.replaceWhere((index) => 1 - labels[index])) *
                clipped.replaceWhere((i, j) => 1 - math.log(clipped[i][j])))) *
        -1 as Vector2;
    // take means of all vec1 in vec2
    Vector1 sampleLosses2 = Vector1.empty();
    for (Vector1 i in sampleLosses) {
      sampleLosses2.add(i.mean());
    }
    return sampleLosses2;
  }

  @override
  void backward(Vector2 dvalues, Vector1 yTrue) {
    // clip dvalues between 1-1e-7 and 1e-7
    var clippedDValues = dvalues.replaceWhere(
      (i, j) => dvalues[i][j] > 1 - 1e-7
          ? 1 - 1e-7
          : dvalues[i][j] < 1e-7
              ? 1e-7
              : dvalues[i][j],
    );

    // calculate gradient
    Vector2 dinputs = (((yTrue / clippedDValues) -
                yTrue.replaceWhere((index) => 1 - yTrue[index]) /
                    clippedDValues
                        .replaceWhere((i, j) => 1 - clippedDValues[i][j])) *
            -1) /
        dvalues[0].length as Vector2;
    this.dinputs = dinputs / dvalues.length as Vector2;
  }
}
