import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:neural_network/activation/root.dart';
import 'package:neural_network/constants.dart';
import 'package:neural_network/datasets/mnist.dart';
import 'package:neural_network/datasets/nnimage.dart';
import 'package:neural_network/datasets/spiral.dart';
import 'package:neural_network/extra/root.dart';
import 'package:neural_network/layers/root.dart';
import 'package:neural_network/loss/root.dart';
import 'package:neural_network/optimizer/root.dart';
import 'package:neural_network/vector/root.dart';

class NeuralNetwork {
  /// list of layers that the model will run through. The first
  /// layer size should accept the size of your input, and the last
  /// layer should be your output layer giving your output.
  late List<Layer> layers;

  /// The loss function to use. The available functions are:
  /// [LossBinaryCrossentropy] and [LossCategoricalCrossentropy].
  late Loss lossFunction;

  /// Which optimizer to use. This will usually be adam, but other
  /// loss functions are available. This includes: [OptimizerAdaGrad],
  /// [OptimizerAdam], [OptimizerRMSProp], and [OptimizerSGD].
  late Optimizer optimizer;

  /// An accuracy class to use. There is only one option: [Accuracy].
  late Accuracy accuracy;

  /// The batch size to split the training or testing data into.
  /// using larger batch sizes will usually result in better
  /// network performance, up to a certain limit. A good number
  /// for this is 128. The default is 1.
  int? batchSize;

  /// The seed used to generate any data, will be saved in the model
  /// output for you to reference later.
  late int seed;

  /// The name of the dataset used. This is not used anywhere except
  /// when saving the model, required to make sure you keep
  /// proper track of what data your network was trained on.
  late String dataset;

  /// A description to describe any random information that you may
  /// want to reference later when a model is saved
  late String metadata;

  /// Create a neural network with the list of Layers in [layers],
  /// a [lossFunction], and an [optimizer]. There are some other
  /// parameters that are required in order to properly generate
  /// an output. These consist of [seed], [dataset], and [metadata].
  NeuralNetwork({
    required this.layers,
    required this.lossFunction,
    required this.optimizer,
    required this.seed,
    required this.dataset,
    required this.metadata,
    this.batchSize,
  }) : assert(layers.isNotEmpty, "Layers cannot be an empty list") {
    accuracy = Accuracy();
  }

  /// Load a network state from a valid model filepath.
  /// Will throw exceptions if the file is not formatted properly.
  /// Use the `saveModel()` function to properly save the state of a model.
  NeuralNetwork.fromFile(String filename) {
    print("# [Loading model from file: $filename]");
    File file = File(filename);
    // decompress and decode file
    List<int> compressed = file.readAsBytesSync();
    List<int> decompressed = gzip.decode(compressed);
    String json = utf8.decode(decompressed);
    _setJsonValues(json);
    accuracy = Accuracy();
  }

  /// Load a model state from a valid json string. This is used when
  /// you do not have access to the saved model file, and need to
  /// load it in some other way. (In Flutter for example).
  NeuralNetwork.fromJson(dynamic json) {
    _setJsonValues(json);
    accuracy = Accuracy();
  }

  void _setJsonValues(dynamic json) {
    Map<String, dynamic> values = jsonDecode(json);
    print("# [Loading model from json]");
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
    if (values.containsKey("accuracy")) {
      print(
          "Model Accuracy: ${(values['accuracy'] * 100.0).toStringAsPrecision(4)}%");
    }
  }

  /// Train the model with the supplied [trainingData]. Accuracy
  /// will be measured when compared against [trainingLabels]. You
  /// can optionally set when you want information to be printed
  /// to the standard out with [printEveryEpoch] and [printEveryStep].
  void train({
    required int epochs,
    required Vector2 trainingData,
    required Vector1 trainingLabels,
    int? printEveryEpoch,
    int? printeveryStep,
  }) {
    batchSize ??= trainingData.shape[0];
    // calculate step number
    int steps = (trainingData.shape[0] / batchSize!).round();
    // include any stragling data
    if (steps * batchSize! < trainingData.shape[0]) {
      steps += 1;
    }
    print("# Beginning training of model:");
    print("# epochs: $epochs, batch size: $batchSize, steps: $steps");

    for (int epoch = 0; epoch < epochs; epoch++) {
      // reset accumulated values
      lossFunction.newPass();
      accuracy.newPass();

      for (int step = 0; step < steps; step++) {
        Vector2 batchData = trainingData.subVector(
            step * batchSize!, (step + 1) * batchSize!) as Vector2;
        Vector1 batchLabels = trainingLabels.subVector(
            step * batchSize!, (step + 1) * batchSize!) as Vector1;

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
          // print(
          //     "step: ${step + 1}, acc: ${acc.toStringAsPrecision(3)}, loss: ${dataLoss.toStringAsPrecision(3)}, lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}");
          print(
              "${step + 1},${acc.toStringAsPrecision(3)},${dataLoss.toStringAsPrecision(3)},${optimizer.currentLearningRate.toStringAsPrecision(3)}");
        }
      }

      // get and print an epoch summary
      var epochLoss = lossFunction.calculateAccumulated();
      var epochAcc = accuracy.calculateAccumulated();
      if (printEveryEpoch != null &&
          (epoch % printEveryEpoch == 0 || epoch == epochs - 1)) {
        // print(
        //     "# [epoch: ${epoch + 1}, acc: ${epochAcc.toStringAsPrecision(3)}, loss: ${epochLoss.toStringAsPrecision(3)}, lr: ${optimizer.currentLearningRate.toStringAsPrecision(3)}]");
        print(
            "${epoch + 1},${epochAcc.toStringAsPrecision(3)},${epochLoss.toStringAsPrecision(3)},${optimizer.currentLearningRate.toStringAsPrecision(3)}");
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

  /// Test the model against a list of inputs. The shape
  /// must match that of your training data and the input
  /// layer of the model. You can optionally print data to
  /// the console every x steps with [printEveryStep].
  double test({
    required Vector2 testingData,
    required Vector1 testingLabels,
    int? printEveryStep,
  }) {
    print("# Beggining tesing of model:");
    batchSize ??= testingData.shape[0];

    // calculate step number
    int steps = (testingData.shape[0] / batchSize!).round();
    // include any stragling data
    if (steps * batchSize! < testingData.shape[0]) {
      steps += 1;
    }

    double totalAccuracy = 0;

    for (int step = 0; step < steps; step++) {
      Vector2 batchData = testingData.subVector(
          step * batchSize!, (step + 1) * batchSize!) as Vector2;
      Vector1 batchLabels = testingLabels.subVector(
          step * batchSize!, (step + 1) * batchSize!) as Vector1;

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
      totalAccuracy += accuracy;

      if (printEveryStep != null &&
          (step % printEveryStep == 0 || step == steps - 1)) {
        // print(
        //     "validation, acc: ${accuracy.toStringAsPrecision(3)}, loss: ${loss.toStringAsPrecision(3)}");
        print(
            "${accuracy.toStringAsPrecision(3)},${loss.toStringAsPrecision(3)}");
      }
    }
    double totalAcc = totalAccuracy / steps;
    print("# [Total accuracy: ${(totalAcc * 100).toStringAsPrecision(4)}%]");
    return totalAcc;
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

  /// Pass a single datapoint through the network to get a
  /// list of confidences cooresponding to what the network
  /// 'thinks' the inputted [data] is.
  List<double> getConfidenceSingle(List<double> data) {
    var prediction = _forward(Vector2.from([data]));
    List<double> preds = [];
    for (num i in prediction[0]) {
      preds.add(i.toDouble());
    }
    return preds;
  }

  /// Save the model to a file. This file is encoded into json
  /// format then encoded and written to a file. This file can be
  /// used as an input to `NeuralNetwork.fromFile()`. You can optionally
  /// save the [accuracy] by setting the accuracy to reference later.
  Future<bool> saveModel({double? accuracy}) async {
    try {
      String modelPath = "/Users/jakelanders/code/dart_nn/lib/models";
      int millSinceEpoch = DateTime.now().millisecondsSinceEpoch;
      String filename = "$modelPath/$millSinceEpoch.json.gz";
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

      // save comprehensive summary about network
      String summaryName = "$modelPath/$millSinceEpoch.stats.json";

      Map<String, dynamic> summary = {
        "date": DateTime.now().toString(),
        "dataset": "all_data",
        "shape": shape(),
        "layers": layers.map((e) => e.stats()).toList(),
        "batchSize": batchSize ?? "Not reported",
        "accuracy": accuracy ?? "Not reported",
        "lossFunction": lossFunction.name(),
        "optimizer": optimizer.toMap(),
        "seed": seed,
        "metadata": metadata,
      };

      String summaryJson = jsonEncode(summary);
      List<int> summaryEncoded = utf8.encode(summaryJson);
      File summaryFile = File(summaryName);
      summaryFile = await summaryFile.create();
      await summaryFile.writeAsBytes(summaryEncoded);
      print(
        "Successfully saved comprehensive summary of model to: $summaryName",
      );

      return true;
    } catch (error, stacktrace) {
      print("There was an issue saving the model: $e\n$stacktrace");
      return false;
    }
  }

  /// Get the shape of the model in the form of a list
  /// of the layer shapes.
  List<List<int>> shape() {
    List<List<int>> out = [];
    for (var i in layers) {
      out.add(i.shape());
    }
    return out;
  }
}

void mnist() async {
  var mnist = Mnist();

  // get generated images
  List<NNImage> generatedImages = await mnist.readGenerated();
  // randomize the images
  generatedImages.shuffle();

  // get training images
  List<NNImage> t1 = await mnist.readTrain();
  List<NNImage> t2 = await mnist.readTrainRandom();
  List<NNImage> t3 = await mnist.readTrainToDrawStyle();
  List<NNImage> trainingImages = [];
  trainingImages.addAll(t1);
  trainingImages.addAll(t2);
  trainingImages.addAll(t3);
  trainingImages.shuffle();

  // add first 800 generated images
  trainingImages.addAll(generatedImages.sublist(0, 800));

  // convert images into vectors
  Tuple2<Vector2, Vector1> trainingData = imagesToVectors(trainingImages);

  NeuralNetwork nn = NeuralNetwork(
    layers: [
      LayerDense(
        trainingImages[0].image.length,
        200,
        activation: ActivationReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      LayerDense(200, 10, activation: ActivationSoftMax()),
    ],
    lossFunction: LossCategoricalCrossentropy(),
    optimizer: OptimizerAdam(learningRate: 0.005, decay: 5e-4),
    batchSize: 128,
    seed: seed,
    dataset: "mnist",
    metadata:
        "Model uses all of the mnist data variations, used to show how improvements in data prep can lower models performace in testing, but make it better at generalizing to actual hand written digits.",
  );

  // train the network
  nn.train(
    epochs: 2,
    printEveryEpoch: 1,
    printeveryStep: 50,
    trainingData: trainingData.v1,
    trainingLabels: trainingData.v2,
  );

  // get tesing images
  List<NNImage> tt1 = await mnist.readTest();
  List<NNImage> tt2 = await mnist.readTestRandom();
  List<NNImage> tt3 = await mnist.readTestRandomToDrawStyle();
  List<NNImage> testingImages = [];
  testingImages.addAll(tt1);
  testingImages.addAll(tt2);
  testingImages.addAll(tt3);

  // add last 200 generated images
  testingImages.addAll(generatedImages.sublist(800, 1000));

  // convert images to vectors
  Tuple2<Vector2, Vector1> testingData = imagesToVectors(testingImages);

  // test the network
  var totalAccuracy = nn.test(
    printEveryStep: 50,
    testingData: testingData.v1,
    testingLabels: testingData.v2,
  );

  // save the model to a file
  nn.saveModel(accuracy: totalAccuracy);
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
    batchSize: 100,
    seed: seed,
    dataset: "spiral",
    metadata: "Generic spiral dataset with 3 options",
  );
  nn.train(
    epochs: 1000,
    trainingData: Vector2.from(trainingData.X),
    trainingLabels: Vector1.from(trainingData.y),
    printEveryEpoch: 100,
  );
  nn.test(
    testingData: Vector2.from(testingData.X),
    testingLabels: Vector1.from(testingData.y),
    printEveryStep: 1,
  );
}

// USED FOR YOUTUBE VIDEO
void mnist2() async {
  var mnist = Mnist();

  List<NNImage> trainingImages = await mnist.readTrain();

  NeuralNetwork nn = NeuralNetwork(
    layers: [
      LayerDense(
        trainingImages[0].image.length,
        200,
        activation: ActivationReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      LayerDense(200, 10, activation: ActivationSoftMax()),
    ],
    lossFunction: LossCategoricalCrossentropy(),
    optimizer: OptimizerAdam(learningRate: 0.005, decay: 5e-4),
    batchSize: 128,
    seed: seed,
    dataset: "mnist",
    metadata:
        "Used in the first part of youtube tutorial to show what the performance is like before image processing",
  );

  Tuple2<Vector2, Vector1> trainingData = imagesToVectors(trainingImages);

  nn.train(
    epochs: 2,
    printEveryEpoch: 1,
    printeveryStep: 50,
    trainingData: trainingData.v1,
    trainingLabels: trainingData.v2,
  );

  List<NNImage> testingImages = await mnist.readTest();

  Tuple2<Vector2, Vector1> testingData = imagesToVectors(testingImages);

  var totalAccuracy = nn.test(
    printEveryStep: 50,
    testingData: testingData.v1,
    testingLabels: testingData.v2,
  );

  nn.saveModel(accuracy: totalAccuracy);
}
