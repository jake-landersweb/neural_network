abstract class Activation {
  List<List<double>>? inputs;
  List<List<double>>? outputs;
  List<List<double>>? dinputs;

  void forward(List<List<double>> inputs);
  void backward(List<List<double>> dvalues);

  String name();
}
