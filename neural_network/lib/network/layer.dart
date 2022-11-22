import 'package:neural_network/network/activation.dart';
import 'package:neural_network/network/utils.dart';

class Layer {
  late List<List<double>> weights;
  // neuron values
  late List<double> bias;
  late Activation activation;

  // forward pass values
  List<List<double>>? inputs;
  List<List<double>>? outputs;

  // backward pass values
  List<List<double>>? dinputs;
  List<List<double>>? dweights;
  List<double>? dbias;

  // momentum values
  List<List<double>>? weightMomentums;
  List<double>? biasMomentums;

  // weight cache values
  List<List<double>>? weightCache;
  List<double>? biasCache;

  // regularization values
  late double weightRegL2;
  late double biasRegL2;

  Layer({
    required int inputs,
    required int neurons,
    required this.activation,
    int? seed,
    this.weightRegL2 = 0,
    this.biasRegL2 = 0,
  }) {
    weights = randomList2D(inputs, neurons, seed: seed);
    bias = randomList1D(neurons, seed: seed);
  }

  void forward(List<List<double>> inputs) {
    assert(inputs.first.length == weights.length);
    this.inputs = inputs;

    var dotprod = inputs.dot2D(weights);
    dotprod = dotprod.replaceWhere((i, j) => dotprod[i][j] + bias[j]);
    activation.forward(dotprod);
    outputs = activation.outputs;
  }

  void backward(List<List<double>> dvalues) {
    // gradient on activation
    activation.backward(dvalues);

    // gradient on params
    dweights = inputs!.T.dot2D(activation.dinputs!);
    dbias = activation.dinputs!.T.sum();

    // gradients on regularization
    if (weightRegL2 > 0) {
      dweights = dweights!.replaceWhere(
          (i, j) => dweights![i][j] + (weights[i][j] * (2 * weightRegL2)));
    }
    if (biasRegL2 > 0) {
      dbias =
          dbias!.replaceWhere((i) => dbias![i] + (bias[i] * (2 * biasRegL2)));
    }

    // gradient on values
    dinputs = activation.dinputs!.dot2D(weights.T);
  }
}
