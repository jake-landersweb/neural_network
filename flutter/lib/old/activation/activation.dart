import 'package:flutter_neural_network/old/vector/root.dart';

abstract class Activation {
  Vector2? inputs;
  Vector2? output;
  Vector2? dinputs;

  void forward(Vector2 inputs);
  void backward(Vector2 dvalues);

  String name();
}
