// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
import 'dart:math';
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/vector/root.dart';

const seed = 0;

void main() {
  SpiralDataset trainingData = SpiralDataset(100, 3);
  SpiralDataset testingData = SpiralDataset(100, 3, seed: 2);
  NeuralNetwork nn = NeuralNetwork(
    layers: [
      LayerDense(
        2,
        64,
        activation: ActivationReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      LayerDense(64, 3, activation: ActivationSoftMax()),
    ],
    lossFunction: LossCategoricalCrossentropy(),
    optimizer: OptimizerAdam(learningRate: 0.02, decay: 5e-7),
  );
  nn.forward(
    epochs: 1000,
    trainingData: Vector2.from(trainingData.X),
    trainingLabels: Vector1.from(trainingData.y),
  );
  nn.test(
    testingData: Vector2.from(testingData.X),
    testingLabels: Vector1.from(testingData.y),
  );
}

class NeuralNetwork {
  late List<Layer> layers;
  late Loss lossFunction;
  late Optimizer optimizer;

  NeuralNetwork({
    required this.layers,
    required this.lossFunction,
    required this.optimizer,
  }) : assert(layers.isNotEmpty, "Layers cannot be an empty list");

  void forward({
    required int epochs,
    required Vector2 trainingData,
    required Vector1 trainingLabels,
    int printEvery = 100,
    int? stepSize,
  }) {
    for (int epoch = 0; epoch < epochs; epoch++) {
      // pass through layers
      for (int i = 0; i < layers.length; i++) {
        if (i == 0) {
          layers[i].forward(trainingData);
        } else {
          layers[i].forward(layers[i - 1].output!);
        }
      }
      // run through loss
      var dataLoss =
          lossFunction.calculate(layers.last.output!, trainingLabels);
      double regLoss = 0;
      for (int i = 0; i < layers.length; i++) {
        regLoss += lossFunction.regularizationLoss(layers[i]);
      }
      var loss = dataLoss + regLoss;

      // calculate accuracy
      var correct = 0;
      for (var i = 0; i < trainingLabels.length; i++) {
        if (layers.last.output![i].maxIndex() == trainingLabels[i]) {
          correct += 1;
        }
      }
      var accuracy = correct / trainingLabels.length;

      // print when specified
      if (epoch % printEvery == 0) {
        print(
          "epoch: $epoch, acc: ${accuracy.toStringAsPrecision(3)}, " +
              "loss: ${loss.toStringAsPrecision(3)}, " +
              "(dataLoss: ${dataLoss.toStringAsPrecision(3)}, " +
              "regLoss: ${regLoss.toStringAsPrecision(3)}), " +
              "lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}",
        );
      }

      // backwards pass
      lossFunction.backward(layers.last.output!, trainingLabels);
      // loop backwards through all layers
      for (int i = layers.length - 1; i > -1; i--) {
        if (i == layers.length - 1) {
          layers[i].backward(lossFunction.dinputs!);
        } else {
          layers[i].backward(layers[i + 1].dinputs!);
        }
      }

      // run optimizer
      optimizer.pre();
      for (int i = 0; i < layers.length; i++) {
        optimizer.update(layers[i]);
      }
      optimizer.post();
    }
  }

  void test({required Vector2 testingData, required Vector1 testingLabels}) {
    // run through the model
    for (int i = 0; i < layers.length; i++) {
      if (i == 0) {
        layers[i].forward(testingData);
      } else {
        layers[i].forward(layers[i - 1].output!);
      }
    }

    // calulate loss
    var loss2 = lossFunction.calculate(layers.last.output!, testingLabels);
    var correct = 0;
    for (var i = 0; i < testingLabels.length; i++) {
      if (layers.last.output![i].maxIndex() == testingLabels[i]) {
        correct += 1;
      }
    }
    var accuracy2 = correct / testingLabels.length;

    print(
        "validation, acc: ${accuracy2.toStringAsPrecision(3)}, loss: ${loss2.toStringAsPrecision(3)}");
  }
}
