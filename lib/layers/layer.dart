import 'package:flutter_nn/vector/root.dart';

abstract class Layer {
  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);
}
