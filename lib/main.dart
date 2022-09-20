// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/mnist.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/extra/root.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/vector/root.dart';

const seed = 3333;

void main() {
  mnist();
}

void mnist() async {
  var mnist = Mnist();
  Tuple2<List<List<double>>, List<int>> trainingData = await mnist.readTrain();

  NeuralNetwork nn = NeuralNetwork(
    layers: [
      LayerDense(
        28 * 28,
        1000,
        activation: ActivationReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      LayerDense(1000, 10, activation: ActivationSoftMax()),
    ],
    lossFunction: LossCategoricalCrossentropy(),
    optimizer: OptimizerAdam(learningRate: 0.02, decay: 5e-7),
    // optimizer: OptimizerSGD(0.01, momentum: 0.9),
  );

  nn.train(
    epochs: 3,
    batchSize: 100,
    printEveryEpoch: 1,
    printeveryStep: 1,
    trainingData: Vector2.from(trainingData.v1.sublist(0, 1000)),
    trainingLabels: Vector1.from(trainingData.v2.sublist(0, 1000)),
  );
  Tuple2<List<List<double>>, List<int>> testingData = await mnist.readTest();
  // nn.test(
  //   printEveryStep: 1,
  //   batchSize: 1000,
  //   testingData: Vector2.from(testingData.v1.sublist(0, 6000)),
  //   testingLabels: Vector1.from(testingData.v2.sublist(0, 6000)),
  // );
  nn.testSingle(testingData.v1[3333], testingData.v2[3333]);
  nn.saveModel("/Users/jakelanders/code/flutter_nn/lib/models/mnist1.json");
}

void spiralDataset() {
  SpiralDataset trainingData = SpiralDataset.shuffle(100, 3);
  SpiralDataset testingData = SpiralDataset.shuffle(100, 3);

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
  nn.train(
    epochs: 1000,
    batchSize: 100,
    trainingData: Vector2.from(trainingData.X),
    trainingLabels: Vector1.from(trainingData.y),
    printEveryEpoch: 100,
  );
  nn.test(
    testingData: Vector2.from(testingData.X),
    testingLabels: Vector1.from(testingData.y),
    batchSize: 100,
    printEveryStep: 1,
  );
}

class NeuralNetwork {
  late List<Layer> layers;
  late Loss lossFunction;
  late Optimizer optimizer;
  late Accuracy accuracy;

  NeuralNetwork({
    required this.layers,
    required this.lossFunction,
    required this.optimizer,
  }) : assert(layers.isNotEmpty, "Layers cannot be an empty list") {
    accuracy = Accuracy();
  }

  /// train the data with the supplied data
  void train({
    required int epochs,
    required Vector2 trainingData,
    required Vector1 trainingLabels,
    int? printEveryEpoch,
    int? printeveryStep,
    int? batchSize,
  }) {
    late int actBatchSize;
    if (batchSize == null) {
      actBatchSize = trainingData.shape[0];
    } else {
      actBatchSize = batchSize;
    }
    // calculate step number
    int steps = (trainingData.shape[0] / actBatchSize).round();
    // include any stragling data
    if (steps * actBatchSize < trainingData.shape[0]) {
      steps += 1;
    }
    print("# Beginning training of network:");

    for (int epoch = 0; epoch < epochs; epoch++) {
      // reset accumulated values
      lossFunction.newPass();
      accuracy.newPass();

      for (int step = 0; step < steps; step++) {
        Vector2 batchData = trainingData.subVector(
            step * actBatchSize, (step + 1) * actBatchSize) as Vector2;
        Vector1 batchLabels = trainingLabels.subVector(
            step * actBatchSize, (step + 1) * actBatchSize) as Vector1;

        // run forward pass
        var predictions = _forward(batchData);

        var dataLoss = lossFunction.calculate(
          layers.last.output!,
          batchLabels,
        );

        // calculate accuracy
        var acc = accuracy.calculate(predictions, batchLabels);

        // backwards pass
        _backward(predictions, batchLabels);

        // optimize
        optimizer.pre();
        for (int i = 0; i < layers.length; i++) {
          optimizer.update(layers[i]);
        }
        optimizer.post();

        // print a summary
        if (printeveryStep != null && step % printeveryStep == 0) {
          print(
              "step: ${step + 1}, acc: ${acc.toStringAsPrecision(3)}, loss: ${dataLoss.toStringAsPrecision(3)}, lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}");
        }
      }

      // get and print an epoch summary
      var epochLoss = lossFunction.calculateAccumulated();
      var epochAcc = accuracy.calculateAccumulated();
      if (printEveryEpoch != null &&
          (epoch % printEveryEpoch == 0 || epoch == epochs - 1)) {
        print(
            "# [epoch: ${epoch + 1}, acc: ${epochAcc.toStringAsPrecision(3)}, loss: ${epochLoss.toStringAsPrecision(3)}, lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}]");
      }
    }
  }

  Vector2 _forward(Vector2 trainingData) {
    // pass through layers
    for (int i = 0; i < layers.length; i++) {
      if (i == 0) {
        layers[i].forward(trainingData);
      } else {
        layers[i].forward(layers[i - 1].output!);
      }
    }

    return layers.last.output!;
  }

  void _backward(Vector2 predictions, Vector1 trainingLabels) {
    // backwards pass
    lossFunction.backward(predictions, trainingLabels);
    // loop backwards through all layers
    for (int i = layers.length - 1; i > -1; i--) {
      if (i == layers.length - 1) {
        layers[i].backward(lossFunction.dinputs!);
      } else {
        layers[i].backward(layers[i + 1].dinputs!);
      }
    }
  }

  /// Test a sequence of data in batches
  void test({
    required Vector2 testingData,
    required Vector1 testingLabels,
    int? batchSize,
    int? printEveryStep,
  }) {
    late int actBatchSize;
    if (batchSize == null) {
      actBatchSize = testingData.shape[0];
    } else {
      actBatchSize = batchSize;
    }

    // calculate step number
    int steps = (testingData.shape[0] / actBatchSize).round();
    // include any stragling data
    if (steps * actBatchSize < testingData.shape[0]) {
      steps += 1;
    }

    for (int step = 0; step < steps; step++) {
      Vector2 batchData = testingData.subVector(
          step * actBatchSize, (step + 1) * actBatchSize) as Vector2;
      Vector1 batchLabels = testingLabels.subVector(
          step * actBatchSize, (step + 1) * actBatchSize) as Vector1;

      // run through the model
      for (int i = 0; i < layers.length; i++) {
        if (i == 0) {
          layers[i].forward(batchData);
        } else {
          layers[i].forward(layers[i - 1].output!);
        }
      }

      // calulate loss
      var loss = lossFunction.calculate(layers.last.output!, batchLabels);
      var correct = 0;
      for (var i = 0; i < batchLabels.length; i++) {
        if (layers.last.output![i].maxIndex() == batchLabels[i]) {
          correct += 1;
        }
      }
      var accuracy = correct / batchLabels.length;

      if (printEveryStep != null &&
          (step % printEveryStep == 0 || step == steps - 1)) {
        print(
            "validation, acc: ${accuracy.toStringAsPrecision(3)}, loss: ${loss.toStringAsPrecision(3)}");
      }
    }
  }

  /// test a single data point against the network
  void testSingle(List<double> data, int label) {
    var prediction = _forward(Vector2.from([data]));
    print("Predicted: ${prediction[0].maxIndex()}, Actual: $label");
    String conf = "";
    for (int i = 0; i < prediction.shape[1]; i++) {
      var pred = prediction[0][i] * 100;
      conf += "[$i] = ${pred.toStringAsPrecision(4)}%, ";
    }
    print("Confidences:\n$conf");
  }

  void saveModel(String filename) async {
    List<Map<String, dynamic>> layerMaps = [];
    for (Layer layer in layers) {
      layerMaps.add(layer.toMap());
    }
    Map<String, dynamic> model = {
      "layers": layerMaps,
      "lossFunction": lossFunction.name(),
      "optimizer": optimizer.name(),
    };
    File file = File(filename);
    file = await file.create();
    await file.writeAsString(jsonEncode(model));
  }
}
