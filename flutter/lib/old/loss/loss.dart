import 'package:flutter_neural_network/old/layers/root.dart';
import 'package:flutter_neural_network/old/vector/root.dart';

abstract class Loss {
  Vector1? loss;
  Vector2? dinputs;
  num accumulatedSum = 0;
  int accumulatedCount = 0;

  Vector1 forward(Vector2 predictions, Vector1 labels);
  void backward(Vector2 dvalues, Vector1 yTrue);

  double calculate(Vector2 predictions, Vector1 labels) {
    // get each sample loss value
    loss = forward(predictions, labels);

    // add accumulated sum of losses and sample count
    accumulatedSum += loss!.sum();
    accumulatedCount += loss!.length;

    // return the mean of the loss values
    return loss!.mean().toDouble();
  }

  double regularizationLoss(Layer layer) {
    double regLoss = 0;

    // only calculate all values if the reg > 0

    // l1 weights
    if (layer.weightRegL1 > 0) {
      regLoss += layer.weightRegL1 * (layer.weights.abs().sum() as num);
    }

    // l2 weights
    if (layer.weightRegL2 > 0) {
      regLoss += layer.weightRegL2 * layer.weights.pow(2).sum();
    }

    // l1 biases
    if (layer.biasRegL1 > 0) {
      regLoss += layer.biasRegL1 * (layer.biases.abs().sum() as num);
    }

    // l2 biases
    if (layer.biasRegL2 > 0) {
      regLoss += layer.biasRegL2 * layer.weights.pow(2).sum();
    }

    return regLoss;
  }

  /// get accumulated loss value
  double calculateAccumulated() {
    var loss = accumulatedSum / accumulatedCount;
    return loss;
  }

  /// reset the accumulated values after each pass
  void newPass() {
    accumulatedSum = 0;
    accumulatedCount = 0;
  }

  String name();
}
