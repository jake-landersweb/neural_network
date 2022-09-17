import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_nn/act_loss_combined/root.dart';
import 'package:flutter_nn/activation/root.dart';
import 'package:flutter_nn/datasets/spiral.dart';
import 'package:flutter_nn/layers/root.dart';
import 'package:flutter_nn/loss/root.dart';
import 'package:flutter_nn/optimizer/root.dart';
import 'package:flutter_nn/optimizer/sgd.dart';
import 'package:flutter_nn/vector/root.dart';

const SEED = 0;
const epochs = 10001;

void main() {
  SpiralDataset dataset = SpiralDataset(100, 3);

  var dense1 = LayerDense(2, 64);
  var activation1 = ActivationReLU();
  var dense2 = LayerDense(64, 3);
  var activation2 = ActivationSoftMax();
  var lossFxn = LossCategoricalCrossentropy();
  // var optimizer = OptimizerSGD(LR, decay: DECAY, momentum: MOMENTUM);
  // var optimizer = OptimizerAdaGrad(1, decay: 1e-4);
  // var optimizer = OptimizerRMSProp(learningRate: 0.02, decay: 1e-5, rho: 0.999);
  var optimizer = OptimizerAdam(learningRate: 0.02, decay: 1e-5);

  for (var epoch = 0; epoch < epochs; epoch++) {
    var temp = Vector2.from(dataset.X);
    dense1.forward(temp);
    activation1.forward(dense1.output!);
    dense2.forward(activation1.output!);
    activation2.forward(dense2.output!);

    var loss = lossFxn.calculate(activation2.output!, Vector1.from(dataset.y));

    // calculate accuracy
    var correct = 0;
    for (var i = 0; i < dataset.y.length; i++) {
      if (activation2.output![i].maxIndex() == dataset.y[i]) {
        correct += 1;
      }
    }
    var accuracy = correct / dataset.y.length;

    // backwards pass
    lossFxn.backward(activation2.output!, Vector1.from(dataset.y));
    activation2.backward(lossFxn.dinputs!);
    dense2.backward(activation2.dinputs!);
    activation1.backward(dense2.dinputs!);
    dense1.backward(activation1.dinputs!);

    if (epoch % 100 == 0) {
      print(
          "epoch: $epoch, acc: ${accuracy.toStringAsPrecision(3)}, loss: ${loss.toStringAsPrecision(3)}, lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}");
      // print("d1f ${dense1.output!.subVector(0, 3)}");
      // print("a1f ${activation1.output!.subVector(0, 3)}");
      // print("d2f ${dense2.output!.subVector(0, 3)}");
      // print("a2f ${activation2.output!.subVector(0, 3)}");
      // print("lfb ${lossFxn.dinputs!.subVector(0, 3)}");
      // print("a2b ${activation2.dinputs!.subVector(0, 3)}");
      // print("d2b ${dense2.dinputs!.subVector(0, 3)}");
      // print("a1b ${activation1.dinputs!.subVector(0, 3)}");
      // print("d1b ${dense1.dinputs!.subVector(0, 3)}");
      // print(" ");
    }

    // update params with the optimizer
    optimizer.pre();
    optimizer.update(dense1);
    optimizer.update(dense2);
    optimizer.post();
  }

  // print("d1f ${dense1.output!.subVector(0, 3)}");
  // print("a1f ${activation1.output!.subVector(0, 3)}");
  // print("d2f ${dense2.output!.subVector(0, 3)}");
  // print("a2f ${activation2.output!.subVector(0, 3)}");
  // print("lfb ${lossFxn.dinputs!.subVector(0, 3)}");
  // print("a2b ${activation2.dinputs!.subVector(0, 3)}");
  // print("d2b ${dense2.dinputs!.subVector(0, 3)}");
  // print("a1b ${activation1.dinputs!.subVector(0, 3)}");
  // print("d1b ${dense1.dinputs!.subVector(0, 3)}");
}
