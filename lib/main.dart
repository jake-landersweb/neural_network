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
  train(1000);
  // test a random point from a separate generation of data
  SpiralDataset datasetTest = SpiralDataset(100, 3, seed: 2);
  int randomIndex = Random(876586).nextInt(datasetTest.y.length);
  testSingle(datasetTest.X[randomIndex][0], datasetTest.X[randomIndex][1],
      datasetTest.y[randomIndex]);
}

var dense1 = LayerDense(
  2,
  64,
  activation: ActivationReLU(),
  weightRegL2: 5e-4,
  biasRegL2: 5e-4,
);
var dense2 = LayerDense(
  64,
  3,
  activation: ActivationSoftMax(),
);
var lossFxn = LossCategoricalCrossentropy();
var optimizer = OptimizerAdam(learningRate: 0.02, decay: 5e-7);

void train(int epochs) async {
  SpiralDataset dataset = SpiralDataset(100, 3);

  // train the model
  for (var epoch = 0; epoch < epochs; epoch++) {
    dense1.forward(Vector2.from(dataset.X));
    dense2.forward(dense1.output!);

    var dataLoss = lossFxn.calculate(dense2.output!, Vector1.from(dataset.y));
    var regLoss =
        lossFxn.regularizationLoss(dense1) + lossFxn.regularizationLoss(dense2);
    var loss = dataLoss + regLoss;

    // calculate accuracy
    var correct = 0;
    for (var i = 0; i < dataset.y.length; i++) {
      if (dense2.output![i].maxIndex() == dataset.y[i]) {
        correct += 1;
      }
    }
    var accuracy = correct / dataset.y.length;

    // backwards pass
    lossFxn.backward(dense2.output!, Vector1.from(dataset.y));
    dense2.backward(lossFxn.dinputs!);
    dense1.backward(dense2.dinputs!);

    if (epoch % 100 == 0) {
      print(
        "epoch: $epoch, acc: ${accuracy.toStringAsPrecision(3)}, " +
            "loss: ${loss.toStringAsPrecision(3)}, " +
            "(dataLoss: ${dataLoss.toStringAsPrecision(3)}, " +
            "regLoss: ${regLoss.toStringAsPrecision(3)}), " +
            "lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}",
      );
    }

    // update params with the optimizer
    optimizer.pre();
    optimizer.update(dense1);
    optimizer.update(dense2);
    optimizer.post();
  }
}

void testSingle(double x, double y, int correct) {
  print("Testing: ($x, $y) :: $correct");
  Vector2 datasetTest = Vector2.from([
    [x, y]
  ]);

  dense1.forward(datasetTest);
  dense2.forward(dense1.output!);

  print(
      "Predicted: ${dense2.output![0].maxIndex()} Actual: $correct, Confidence: ${(dense2.output![0].map((e) => "${(e * 100).toStringAsPrecision(4)}%"))}");
}

void testAll() {
  SpiralDataset datasetTest = SpiralDataset(100, 3, seed: 2);

  // // test the model
  dense1.forward(Vector2.from(datasetTest.X));
  dense2.forward(dense1.output!);
  var loss2 = lossFxn.calculate(dense2.output!, Vector1.from(datasetTest.y));
  var correct = 0;
  for (var i = 0; i < datasetTest.y.length; i++) {
    if (dense2.output![i].maxIndex() == datasetTest.y[i]) {
      correct += 1;
    }
  }
  var accuracy2 = correct / datasetTest.y.length;

  print(
      "validation, acc: ${accuracy2.toStringAsPrecision(3)}, loss: ${loss2.toStringAsPrecision(3)}");
}
