import 'package:flutter_nn/vector/root.dart';

abstract class Loss {
  Vector1 forward(Vector2 predictions, Vector1 labels);
  void backward(Vector2 dvalues, Vector1 yTrue);

  double calculate(Vector2 predictions, Vector1 labels) {
    // get each sample loss value
    Vector1 loss = forward(predictions, labels);
    // return the mean of the loss values
    return loss.mean().toDouble();
  }
}
