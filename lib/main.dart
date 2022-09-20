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

const seed = 123;

void main() {
  // mnist();
  mnistLoadFromFile();
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
  nn.testSingle(testingData.v1[123], testingData.v2[123]);
  nn.saveModel();
}

void mnistLoadFromFile() async {
  var mnist = Mnist();
  NeuralNetwork nn = NeuralNetwork.fromFile(
    "/Users/jakelanders/code/flutter_nn/lib/models/1663694682093.json.gz",
  );
  Tuple2<List<List<double>>, List<int>> testingData = await mnist.readTest();
  // test all the labels
  for (int i = 0; i < testingData.v1.length; i++) {
    nn.testSingle(testingData.v1[i], testingData.v2[i]);
  }
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

  /// Create a neural network with the list of Layers in [layers],
  /// a [lossFunction], and an [optimizer].
  NeuralNetwork({
    required this.layers,
    required this.lossFunction,
    required this.optimizer,
  }) : assert(layers.isNotEmpty, "Layers cannot be an empty list") {
    accuracy = Accuracy();
  }

  /// Load a network state from a valid model filepath.
  /// Will throw exceptions if the file is not formatted properly.
  /// Use the `saveModel()` function to properly save the state of a model.
  NeuralNetwork.fromFile(String filename) {
    // add gzip extension if not passed, because this is how it saves
    if (!filename.endsWith(".gz")) {
      filename = filename + ".gz";
    }
    File file = File(filename);
    // decompress and decode file
    List<int> compressed = file.readAsBytesSync();
    List<int> decompressed = gzip.decode(compressed);
    String json = utf8.decode(decompressed);
    // read as json
    Map<String, dynamic> values = jsonDecode(json);
    layers = [];
    for (var i in values['layers']) {
      layers.add(LayerDense.fromMap(i));
    }
    switch (values['lossFunction']) {
      case "binary_ce":
        lossFunction = LossBinaryCrossentropy();
        break;
      case "cat_ce":
        lossFunction = LossCategoricalCrossentropy();
        break;
      default:
        throw "Invalid loss function passed ${values['lossFunction']}";
    }
    switch (values['optimizer']['name']) {
      case "ada":
        optimizer = OptimizerAdaGrad.fromMap(values['optimizer']);
        break;
      case "adam":
        optimizer = OptimizerAdam.fromMap(values['optimizer']);
        break;
      case "rms":
        optimizer = OptimizerRMSProp.fromMap(values['optimizer']);
        break;
      case "sgd":
        optimizer = OptimizerSGD.fromMap(values['optimizer']);
        break;
      default:
        throw "Invalid optimizer passed: ${values['optimizer']}";
    }
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

  /// test a single data point against the network. This will
  /// print out the predicted label, the actual label, and the
  /// percent confidence. You can optionally show all confidences
  /// by setting [printAllConfidences] to true.
  void testSingle(
    List<double> data,
    int label, {
    bool printAllConfidences = false,
  }) {
    var prediction = _forward(Vector2.from([data]));
    String out =
        "Predicted: ${prediction[0].maxIndex()}, Actual: $label, Confidence: ${(prediction[0].max() * 100).toStringAsPrecision(4)}%";
    // add an incorrect label to easily identify mistakes
    if (prediction[0].maxIndex() != label) {
      out += " [INCORRECT]";
    }
    print(out);
    if (printAllConfidences) {
      String conf = "";
      for (int i = 0; i < prediction.shape[1]; i++) {
        var pred = prediction[0][i] * 100;
        conf += "[$i] = ${pred.toStringAsPrecision(4)}%, ";
      }
      print("Confidences:\n$conf");
    }
  }

  /// Save the model to a file. This file is encoded into json
  /// format then encoded and written to a file. This file can be
  /// used as an input to `NeuralNetwork.fromFile()`
  Future<bool> saveModel() async {
    try {
      String filename =
          "/Users/jakelanders/code/flutter_nn/lib/models/${DateTime.now().millisecondsSinceEpoch}.json.gz";
      List<Map<String, dynamic>> layerMaps = [];
      for (Layer layer in layers) {
        layerMaps.add(layer.toMap());
      }
      Map<String, dynamic> model = {
        "layers": layerMaps,
        "lossFunction": lossFunction.name(),
        "optimizer": optimizer.toMap(),
      };
      // convert to json
      String json = jsonEncode(model);
      // encode to utf-8
      List<int> encoded = utf8.encode(json);
      // compress
      List<int> compressed = gzip.encode(encoded);
      // create the file
      File file = File(filename);
      file = await file.create();
      await file.writeAsBytes(compressed);
      print("Successfully saved model to: $filename");
      return true;
    } catch (error, stacktrace) {
      print("There was an issue saving the model: $e\n$stacktrace");
      return false;
    }
  }
}
