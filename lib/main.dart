import 'package:flutter_nn/act_loss_combined/root.dart';
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/vector/root.dart';

const SEED = 10;

void main() {
  // passed in gradient from the next layer
  // List<List<double>> dvalues = [
  //   [1.0, 1.0, 1.0],
  //   [2, 2, 2],
  //   [3, 3, 3],
  // ];

  // // 3 samples
  // List<List<double>> inputs = [
  //   [1, 2, 3, 2.5],
  //   [2, 5, -1, 2],
  //   [-1.5, 2.7, 3.3, -0.8],
  // ];

  // // 3 sets of weights for each neuron
  // List<List<double>> weights = [
  //   [0.2, 0.8, -0.5, 1],
  //   [0.5, -0.91, 0.26, -0.5],
  //   [-0.26, -0.27, 0.17, 0.87],
  // ];

  // // biases for each group of inputs
  // List<double> biases = [2, 3, 0.5];

  // // forward pass
  // var layerOutputs =
  //     vectorSum2D1D(dot2D2D(inputs, weights.transpose()), biases);
  // List<List<double>> reluOutputs = [];
  // // for relu activation, simulating backprop with relu
  // // this is not useful at all, just to help brain dump
  // List<List<double>> drelu = [];

  // for (var i in layerOutputs) {
  //   List<double> tempRelu = [];
  //   List<double> tempdrelu = [];

  //   for (var j in i) {
  //     if (j < 0) {
  //       tempRelu.add(0);
  //       tempdrelu.add(0);
  //     } else {
  //       tempRelu.add(j);
  //       tempdrelu.add(1);
  //     }
  //   }
  //   reluOutputs.add(tempRelu);
  //   drelu.add(tempdrelu);
  // }

  // // inputs
  // var dinputs = dot2D2D(drelu, weights);
  // // derivative weights
  // var dweights = dot2D2D(inputs.transpose(), drelu);

  // // biases all summed
  // List<double> dbiases = [];
  // for (var i in drelu) {
  //   dbiases.add(i.sum().toDouble());
  // }

  // // update the params
  // weights = vectorSum2D2D(weights, dweights.multiply0D(-0.001).transpose());
  // biases = vectorSum1D1D(
  //     biases, dbiases.multiply(-0.001).map((e) => e.toDouble()).toList());

  // print(weights.transpose().pretty());
  // print(biases);

  // List<List<double>> dinputs = dot2D2D(dvalues, weights);

  // print(dinputs.pretty());

  // -----

  // SpiralDataset dataset = SpiralDataset(500, 3);

  // LayerDense layer1 = LayerDense(
  //   inputs: 2,
  //   neurons: 3,
  //   activation: ActivationReLU(),
  // );
  // LayerDense outLayer = LayerDense(
  //   inputs: 3,
  //   neurons: 3,
  //   activation: ActivationSoftMax(),
  // );
  // Loss lossFunction = LossCategoricalCrossentropy();

  // layer1.forward(dataset.X);
  // outLayer.forward(layer1.output);
  // var loss = lossFunction.calculate(outLayer.output, dataset.y);

  // // calculate accuracy
  // int correct = 0;
  // for (var i = 0; i < dataset.y.length; i++) {
  //   if (outLayer.output[i].maxIndex() == dataset.y[i]) {
  //     correct += 1;
  //   }
  // }
  // double accuracy = correct / dataset.y.length;

  // print(outLayer.output.sublist(0, 10).pretty());
  // print("Loss: $loss");
  // print("Accuracy = $accuracy");

  // -----

  // var softmaxOutputs = [
  //   [0.7, 0.1, 0.2],
  //   [0.1, 0.5, 0.4],
  //   [0.02, 0.9, 0.08]
  // ];
  // var classTargets = [0, 1, 1];

  // final stopwatch = Stopwatch()..start();
  // var softmaxLoss = ActivationSoftmaxLossCategoricalCrossentropy();
  // var dvalues1 = softmaxLoss.backward(softmaxOutputs, classTargets);
  // print(dvalues1.pretty());
  // print("Finished in ${stopwatch.elapsed}");

  // final stopwatch2 = Stopwatch()..start();
  // var activation = ActivationSoftMax();
  // activation.output = softmaxOutputs;
  // var loss = LossCategoricalCrossentropy();
  // var lossDInputs = loss.backward(softmaxOutputs, classTargets);
  // var actDInputs = activation.backward(lossDInputs);
  // print(actDInputs.pretty());
  // print("Finished in ${stopwatch2.elapsed}");

  // -----

  // var dataset = SpiralDataset(100, 3);

  // var dense1 = LayerDense(inputs: 2, neurons: 3);
  // var activation1 = ActivationReLU();
  // var dense2 = LayerDense(inputs: 3, neurons: 3);
  // var activation2 = ActivationSoftMax();
  // LossCategoricalCrossentropy lossFunction = LossCategoricalCrossentropy();

  // // run through the network
  // dense1.forward(dataset.X);
  // activation1.forward(dense1.output());
  // dense2.forward(activation1.inputs());
  // activation2.forward(dense2.output());
  // var loss = lossFunction.calculate(activation2.inputs(), dataset.y);

  // print(activation2.inputs().sublist(0, 5).pretty());

  // print("Loss: $loss");

  // // calculate accuracy
  // int correct = 0;
  // for (var i = 0; i < dataset.y.length; i++) {
  //   if (activation2.inputs()[i].maxIndex() == dataset.y[i]) {
  //     correct += 1;
  //   }
  // }
  // double accuracy = correct / dataset.y.length;

  // print("Accuracy: $accuracy");

  // // backwards pass
  // var lossOut = lossFunction.backward(activation2.inputs(), dataset.y);
  // dense2.backward(lossOut);
  // dense1.backward(dense2.dinputs());

  // print(dense1.dweights().sublist(0, 2).pretty());
  // print(dense1.dbiases().sublist(0, 2));
  // print(dense2.dweights().sublist(0, 2).pretty());
  // print(dense2.dbiases().sublist(0, 2));

  // -----

  // Vector2 vec1 = Vector2.from([
  //   [7.6, 2.3, 5.5],
  //   [3.4, 2.2, 9.8],
  //   [1.7, 5.2, 7.1]
  // ]);
  // Vector2 vec2 = Vector2.from([
  //   [7.6, 4.3, 5.5],
  //   [3.4, 8.2, 9.2],
  //   [5.1, 5.2, 3.2]
  // ]);
  // Vector1 vec3 = Vector1.from([3.6, 9.9, 7.4]);
  // print(vec2 + 5);
  // print(vec3 + 5);

  // ----- Test softmax functions

  // var softmaxOutputs = Vector2.from([
  //   [0.7, 0.1, 0.2],
  //   [0.1, 0.5, 0.4],
  //   [0.02, 0.9, 0.08]
  // ]);

  // var classTargets = Vector1.from([0, 1, 1]);

  // var softmaxLoss = ActivationSoftmaxLossCategoricalCrossentropy();
  // softmaxLoss.backward(softmaxOutputs, classTargets);
  // var dvalues1 = softmaxLoss.dinputs!;

  // var activation = ActivationSoftMax();
  // activation.output = softmaxOutputs;
  // var loss = LossCategoricalCrossentropy();
  // loss.backward(softmaxOutputs, classTargets);
  // activation.backward(loss.dinputs!);
  // var dvalues2 = activation.dinputs!;

  // print("Gradients: combined loss and activation:\n$dvalues1");
  // print("Gradients: separate loss and activation:\n$dvalues2");

  // ---- run comparative test

  // SpiralDataset dataset = SpiralDataset(100, 3);

  // var dense1 = LayerDense(2, 3);
  // var activation1 = ActivationReLU();
  // var dense2 = LayerDense(3, 3);
  // var activation2 = ActivationSoftMax();
  // var lossFunction = LossCategoricalCrossentropy();

  // dense1.forward(Vector2.from(dataset.X));
  // activation1.forward(dense1.output!);
  // dense2.forward(activation1.output!);
  // activation2.forward(dense2.output!);

  // var loss =
  //     lossFunction.calculate(activation2.output!, Vector1.from(dataset.y));

  // // calculate accuracy
  // int correct = 0;
  // for (var i = 0; i < dataset.y.length; i++) {
  //   if (activation2.output![i].maxIndex() == dataset.y[i]) {
  //     correct += 1;
  //   }
  // }
  // double accuracy = correct / dataset.y.length;

  // print("Forward Out:\n${activation2.output!}");
  // print("Loss: $loss");
  // print("Accuracy = $accuracy");

  // // run tiered backprop
  // lossFunction.backward(activation2.output!, Vector1.from(dataset.y));
  // activation2.backward(lossFunction.dinputs!);
  // dense2.backward(activation2.dinputs!);
  // activation1.backward(dense2.dinputs!);
  // dense1.backward(activation1.dinputs!);
  // print("Tiered Backprop Out:\n${dense1.dinputs!}");

  // // Combined version
  // var lossActivation = ActivationSoftmaxLossCategoricalCrossentropy();
  // loss = lossActivation.forward(dense2.output!, Vector1.from(dataset.y));
  // print("LossActivation Out:\n${lossActivation.output!}");
  // print("Loss: $loss");

  // // calculate accuracy
  // correct = 0;
  // for (var i = 0; i < dataset.y.length; i++) {
  //   if (lossActivation.output![i].maxIndex() == dataset.y[i]) {
  //     correct += 1;
  //   }
  // }
  // accuracy = correct / dataset.y.length;
  // print("Accuracy: $accuracy");

  // // run combined backprop
  // lossActivation.backward(lossActivation.output!, Vector1.from(dataset.y));
  // dense2.backward(lossActivation.dinputs!);
  // activation1.backward(dense2.dinputs!);
  // dense1.backward(activation1.dinputs!);

  // print("Tiered Backprop Out:\n${dense1.dinputs!}");

  // test passed

  // ---- full code as of page 243

  SpiralDataset dataset = SpiralDataset(100, 3);

  var dense1 = LayerDense(2, 3);
  var activation1 = ActivationReLU();
  var dense2 = LayerDense(3, 3);
  var lossActivation = ActivationSoftmaxLossCategoricalCrossentropy();

  dense1.forward(Vector2.from(dataset.X));
  activation1.forward(dense1.output!);
  dense2.forward(activation1.output!);

  var loss = lossActivation.forward(dense2.output!, Vector1.from(dataset.y));

  print(lossActivation.output!.subVector(0, 5));

  print("loss: $loss");

  // calculate accuracy
  var correct = 0;
  for (var i = 0; i < dataset.y.length; i++) {
    if (lossActivation.output![i].maxIndex() == dataset.y[i]) {
      correct += 1;
    }
  }
  var accuracy = correct / dataset.y.length;
  print("acc: $accuracy");

  // backwards pass
  lossActivation.backward(lossActivation.output!, Vector1.from(dataset.y));
  dense2.backward(lossActivation.dinputs!);
  activation1.backward(dense2.dinputs!);
  dense1.backward(activation1.dinputs!);

  // print all gradients
  print(dense1.dweights!);
  print(dense1.dbiases);
  print(dense2.dweights);
  print(dense2.dbiases);
}
