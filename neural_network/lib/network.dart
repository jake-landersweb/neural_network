import 'package:neural_network/network/adam.dart';
import 'package:neural_network/network/cat_crossentropy.dart';
import 'package:neural_network/network/layer.dart';
import 'package:neural_network/network/mnist.dart';
import 'package:neural_network/network/relu.dart';
import 'package:neural_network/network/sgd.dart';
import 'package:neural_network/network/softmax.dart';
import 'package:neural_network/network/utils.dart';

void mnist() async {
  // load data
  var train = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist_train.csv");

  var layer1 = Layer(
    inputs: train.v2.first.length,
    neurons: 200,
    activation: ReLU(),
    weightRegL2: 5e-4,
    biasRegL2: 5e-4,
  );
  var layer2 = Layer(inputs: 200, neurons: 10, activation: Softmax());

  var lossFxn = CategoricalCrossentropy();

  var optimizer = Adam(learningRate: 0.005, decay: 5e-4);

  int epochs = 1;
  int batchSize = 100;
  int steps = train.v1.length ~/ batchSize;
  if (steps * batchSize < train.v1.length) {
    steps += 1;
  }

  print("--TRAINING MODEL: EPOCHS = $epochs STEPS = $steps--");

  for (int epoch = 0; epoch < epochs; epoch++) {
    for (int step = 0; step < steps; step++) {
      var batchData =
          train.v2.sublist(step * batchSize, (step + 1) * batchSize);
      var batchLabels =
          train.v1.sublist(step * batchSize, (step + 1) * batchSize);

      // forward pass
      layer1.forward(batchData);
      layer2.forward(layer1.outputs!);

      // calculate accuracy
      var loss = lossFxn.calculate(layer2.outputs!, batchLabels);
      int correct = 0;
      for (int i = 0; i < batchLabels.length; i++) {
        if (layer2.outputs![i].maxIndex() == batchLabels[i]) {
          correct += 1;
        }
      }
      var accuracy = correct / batchLabels.length;

      // backwards pass
      var lossOut = lossFxn.backward(layer2.outputs!, batchLabels);
      layer2.backward(lossOut);
      layer1.backward(layer2.dinputs!);

      // run optimizer
      optimizer.pre();
      optimizer.update(layer1);
      optimizer.update(layer2);
      optimizer.post();

      if (step % 100 == 0) {
        print("EPOCH: $epoch STEP: $step LOSS: $loss, ACC: $accuracy");
      }
    }
  }

  // test the network
  var test = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist_test.csv");

  steps = test.v1.length ~/ batchSize;

  print("--TESTING MODEL: STEPS = $steps--");

  for (int step = 0; step < steps; step++) {
    var batchData = test.v2.sublist(step * batchSize, (step + 1) * batchSize);
    var batchLabels = test.v1.sublist(step * batchSize, (step + 1) * batchSize);

    // forward pass
    layer1.forward(batchData);
    layer2.forward(layer1.outputs!);

    // calculate accuracy
    var loss = lossFxn.calculate(layer2.outputs!, batchLabels);
    int correct = 0;
    for (int i = 0; i < batchLabels.length; i++) {
      if (layer2.outputs![i].maxIndex() == batchLabels[i]) {
        correct += 1;
      }
    }
    var accuracy = correct / batchLabels.length;

    if (step % 10 == 0) {
      print("TEST - STEP: $step LOSS: $loss, ACC: $accuracy");
    }
  }
}
