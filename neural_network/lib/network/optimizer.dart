import 'package:neural_network/network/root.dart';

abstract class Optimizer {
  void pre();
  void update(Layer layer);
  void post();
  Map<String, dynamic> toMap();
}
