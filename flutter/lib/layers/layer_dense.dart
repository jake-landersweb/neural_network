import 'package:neural_network/activation/root.dart';
import 'package:neural_network/constants.dart';
import 'package:neural_network/layers/root.dart';
import 'package:neural_network/vector/root.dart';

class LayerDense extends Layer {
  LayerDense(
    int inputs,
    int neurons, {
    required Activation activation,
    int seed = seed,
    double weightRegL1 = 0,
    double weightRegL2 = 0,
    double biasRegL1 = 0,
    double biasRegL2 = 0,
  }) {
    weights = Vector2.random(inputs, neurons, scaleFactor: 0.01, seed: seed);
    biases = Vector2.from([Vector1(neurons, fill: 0).val]);
    this.activation = activation;
    this.weightRegL1 = weightRegL1;
    this.weightRegL2 = weightRegL2;
    this.biasRegL1 = biasRegL1;
    this.biasRegL2 = biasRegL2;
    inputSize = inputs;
    numNeurons = neurons;
  }

  @override
  LayerDense.fromMap(Map<String, dynamic> map) {
    Vector2 w = Vector2.empty();
    for (var i in map['weights']) {
      Vector1 temp = Vector1.empty();
      for (var j in i) {
        temp.add(j);
      }
      w.add(temp);
    }
    Vector2 b = Vector2.empty();
    for (var i in map['biases']) {
      Vector1 temp = Vector1.empty();
      for (var j in i) {
        temp.add(j);
      }
      b.add(temp);
    }
    weights = w;
    biases = b;
    switch (map['activation']) {
      case "relu":
        activation = ActivationReLU();
        break;
      case "sigmoid":
        activation = ActivationSigmoid();
        break;
      case "softmax":
        activation = ActivationSoftMax();
        break;
      default:
        throw "Invalid activation function ${map['activation']}";
    }
    weightRegL1 = map['weightRegL1'];
    weightRegL2 = map['weightRegL2'];
    biasRegL1 = map["biasRegL1"];
    biasRegL2 = map["biasRegL2"];
  }

  @override
  void forward(Vector2 inputs) {
    assert(inputs[0].length == weights.length,
        "The elements inside of inputs need to be of the same length as the weights");
    // save the inputs for backprop
    this.inputs = inputs;
    // run forward pass
    // output = (dot(inputs, weights) + biases) as Vector2;

    // send though activation function
    activation.forward((dot(inputs, weights) + biases) as Vector2);
    output = activation.output;
  }

  @override
  void backward(Vector2 dvalues) {
    assert(inputs != null, "inputs is null, run forward() first");
    // send through activation function
    activation.backward(dvalues);

    // gradients on params
    dweights = dot(inputs!.T, activation.dinputs!) as Vector2;
    dbiases = activation.dinputs!.sum(axis: 0, keepDims: true) as Vector2;

    // gradients on regularization
    if (weightRegL1 > 0) {
      var dL1 = Vector2.like(weights, fill: 1);
      dL1 = dL1.replaceWhere((i, j) => weights[i][j] < 0 ? -1 : dL1[i][j]);
      dweights = dweights! + (dL1 * weightRegL1) as Vector2;
    }
    if (weightRegL2 > 0) {
      dweights = dweights! + (weights * (2 * weightRegL2)) as Vector2;
    }
    if (biasRegL1 > 0) {
      var dL1 = Vector2.like(biases, fill: 1);
      dL1 = dL1.replaceWhere((i, j) => biases[i][j] < 0 ? -1 : dL1[i][j]);
      dbiases = dbiases! + (dL1 * biasRegL1) as Vector2;
    }
    if (biasRegL2 > 0) {
      dbiases = dbiases! + (biases * (2 * biasRegL2)) as Vector2;
    }

    // gradients on values
    dinputs = dot(activation.dinputs!, weights.T) as Vector2;
  }
}
