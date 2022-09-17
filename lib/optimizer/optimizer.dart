import 'package:flutter_nn/layers/root.dart';

abstract class Optimizer {
  /// To be called before each layer has been optimized
  void pre();

  /// Update the layer with the specified optimizer function
  void update(Layer layer);

  /// To be called after all layers have been optimized
  void post();
}
