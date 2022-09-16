import 'package:flutter_nn/vector/root.dart';

abstract class Activation {
  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);
}
