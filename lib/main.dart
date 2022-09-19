// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/vector/root.dart';

const seed = 0;

// class NeuralNetwork {
//   late List<Layer> layers;
//   late Loss lossFxn;
//   late Optimizer optimizer;
//   late Vector2 trainingData;
//   late Vector1 trainingLabels;
//   late Vector2 testingData;
//   late Vector1 testingLabels;

//   NeuralNetwork({
//     required this.layers,
//     required this.lossFxn,
//     required this.optimizer,
//     required this.trainingData,
//     required this.trainingLabels,
//     required this.testingData,
//     required this.testingLabels,
//   });

//   void train(int epochs, {int printEvery = 100}) {
//     for (var epoch = 0; epoch < epochs; epoch++) {
//       // run through all layers
//       for (int i = 0; i < layers.length; i++) {
//         if (i == 0) {
//           // use data
//           layers[i].forward(trainingData);
//         } else {
//           layers[i].forward(layers[i - 1].output!);
//         }
//       }

//       var dataLoss = lossFxn.calculate(layers.last.output!, trainingLabels);
//       var regLoss = 0.0;
//       for (var layer in layers) {
//         regLoss += lossFxn.regularizationLoss(layer);
//       }
//       var loss = dataLoss + regLoss;

//       // calculate accuracy
//       var correct = 0;
//       for (var i = 0; i < trainingLabels.length; i++) {
//         if (layers.last.output![i].maxIndex() == trainingLabels[i]) {
//           correct += 1;
//         }
//       }
//       var accuracy = correct / trainingData.length;

//       if (epoch % printEvery == 0) {
//         print(
//           "epoch: $epoch, acc: ${accuracy.toStringAsPrecision(3)}, " +
//               "loss: ${loss.toStringAsPrecision(3)}, " +
//               "(dataLoss: ${dataLoss.toStringAsPrecision(3)}, " +
//               "regLoss: ${regLoss.toStringAsPrecision(3)}), " +
//               "lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}",
//         );
//       }

//       // backward pass
//       lossFxn.backward(layers.last.output!, trainingLabels);

//       // reverse for loop
//       for (int i = layers.length - 1; i > -1; i--) {
//         if (i == layers.length - 1) {
//           layers[i].backward(lossFxn.dinputs!);
//         } else {
//           layers[i].backward(layers[i + 1].dinputs!);
//         }
//       }

//       // run through optimizer
//       optimizer.pre();
//       for (var layer in layers) {
//         optimizer.update(layer);
//       }
//       optimizer.post();
//     }
//   }

//   void test() {
//     for (int i = 0; i < layers.length; i++) {
//       if (i == 0) {
//         // use data
//         layers[i].forward(testingData);
//       } else {
//         layers[i].forward(layers[i - 1].output!);
//       }
//     }
//     var dataLoss = lossFxn.calculate(layers.last.output!, testingLabels);
//     var regLoss = 0.0;
//     for (var layer in layers) {
//       regLoss += lossFxn.regularizationLoss(layer);
//     }
//     var loss = dataLoss + regLoss;

//     // calculate accuracy
//     var correct = 0;
//     for (var i = 0; i < testingLabels.length; i++) {
//       if (layers.last.output![i].maxIndex() == testingLabels[i]) {
//         correct += 1;
//       }
//     }
//     var accuracy = correct / testingLabels.length;
//     print("validation, acc: ${accuracy.toStringAsPrecision(3)}, " +
//         "loss: ${loss.toStringAsPrecision(3)}, " +
//         "(dataLoss: ${dataLoss.toStringAsPrecision(3)}, " +
//         "regLoss: ${regLoss.toStringAsPrecision(3)})");
//   }
// }

void main() {
  // SpiralDataset training = SpiralDataset(100, 3);
  // SpiralDataset testing = SpiralDataset(100, 3);
  // NeuralNetwork nn = NeuralNetwork(
  //   layers: [
  //     LayerDense(2, 64, activation: ActivationReLU()),
  //     LayerDense(64, 32, activation: ActivationReLU()),
  //     LayerDense(32, 3, activation: ActivationSoftMax()),
  //   ],
  //   lossFxn: LossCategoricalCrossentropy(),
  //   optimizer: OptimizerAdam(learningRate: 0.02, decay: 5e-7),
  //   trainingData: Vector2.from(training.X),
  //   trainingLabels: Vector1.from(training.y),
  //   testingData: Vector2.from(testing.X),
  //   testingLabels: Vector1.from(testing.y),
  // );
  // nn.train(500);
  // nn.test();

  train(1000);
  test();
}

SpiralDataset dataset = SpiralDataset(100, 3);

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

void test() {
  SpiralDataset datasetTest = SpiralDataset(100, 3);

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
