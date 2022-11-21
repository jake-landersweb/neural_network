import 'package:neural_network/layers/root.dart';

abstract class Optimizer {
  late double learningRate;
  late double currentLearningRate;
  late double decay;
  late int iterations;

  // constructors
  Optimizer();
  Optimizer.fromMap(Map<String, dynamic> values);

  /// To be called before each layer has been optimized
  void pre();

  /// Update the layer with the specified optimizer function
  void update(Layer layer);

  /// To be called after all layers have been optimized
  void post();

  // basic name
  String name();

  /// to convert the optimizer to a map for json storage
  Map<String, dynamic> toMap();
}
