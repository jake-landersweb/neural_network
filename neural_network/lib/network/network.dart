import 'dart:convert';
import 'dart:io';
import 'package:neural_network/network/nnimage.dart';
import 'package:neural_network/network/root.dart';

class Network {
  late List<Layer> layers;
  CategoricalCrossentropy lossFxn = CategoricalCrossentropy();
  late Optimizer optimizer;
  double? accuracy;

  Network({
    required this.layers,
    required this.optimizer,
  });

  Network.fromFilename(String filename, {bool compressed = false}) {
    print("--LOADING MODEL FROM FILE: $filename--");
    File file = File(filename);
    List<int> fileByes = file.readAsBytesSync();
    if (compressed) {
      fileByes = gzip.decode(fileByes);
    }
    String json = utf8.decode(fileByes);
    loadFromMap(jsonDecode(json));
  }

  Network.fromJson(String json) {
    loadFromMap(jsonDecode(json));
  }

  void loadFromMap(Map<String, dynamic> values) {
    layers = [];
    for (var i in values['layers']) {
      layers.add(Layer.fromMap(i));
    }
    optimizer = Adam.fromMap(values['optimizer']);
    accuracy = values['accuracy'];
    lossFxn = CategoricalCrossentropy();
    print("--SUCCESSFULLY LOADED MODEL--");
  }

  void train(List<List<double>> data, List<int> labels,
      {int epochs = 1, int batchSize = 100}) {
    // calculate step size
    int steps = labels.length ~/ batchSize;
    if (steps * batchSize < labels.length) {
      steps += 1;
    }

    print("--TRAINING MODEL: EPOCHS = $epochs STEPS = $steps--");

    for (int epoch = 0; epoch < epochs; epoch++) {
      for (int step = 0; step < steps; step++) {
        var batchData = data.sublist(
            step * batchSize,
            (step + 1) * batchSize > data.length
                ? data.length
                : (step + 1) * batchSize);
        var batchLabels = labels.sublist(
            step * batchSize,
            (step + 1) * batchSize > labels.length
                ? labels.length
                : (step + 1) * batchSize);

        // forward pass
        for (int i = 0; i < layers.length; i++) {
          if (i == 0) {
            layers[i].forward(batchData);
          } else {
            layers[i].forward(layers[i - 1].outputs!);
          }
        }

        // calculate accuracy
        var loss = lossFxn.calculate(layers.last.outputs!, batchLabels);
        int correct = 0;
        for (int i = 0; i < batchLabels.length; i++) {
          if (layers.last.outputs![i].maxIndex() == batchLabels[i]) {
            correct += 1;
          }
        }
        var accuracy = correct / batchLabels.length;

        // backwards pass
        for (int i = layers.length - 1; i > -1; i--) {
          if (i == layers.length - 1) {
            layers[i]
                .backward(lossFxn.backward(layers.last.outputs!, batchLabels));
          } else {
            layers[i].backward(layers[i + 1].dinputs!);
          }
        }

        // run optimizer
        optimizer.pre();
        for (var i in layers) {
          optimizer.update(i);
        }
        optimizer.post();

        if (step % 100 == 0) {
          print("EPOCH: ${epoch + 1} STEP: $step LOSS: $loss, ACC: $accuracy");
        }
      }
    }
  }

  void test(List<List<double>> data, List<int> labels, {int batchSize = 10}) {
    // calculate step size
    int steps = labels.length ~/ batchSize;
    if (steps * batchSize < labels.length) {
      steps += 1;
    }

    print("--TESTING MODEL: STEPS = $steps--");

    double accSum = 0;

    for (int step = 0; step < steps; step++) {
      var batchData = data.sublist(
          step * batchSize,
          (step + 1) * batchSize > data.length
              ? data.length
              : (step + 1) * batchSize);
      var batchLabels = labels.sublist(
          step * batchSize,
          (step + 1) * batchSize > labels.length
              ? labels.length
              : (step + 1) * batchSize);

      // forward pass
      for (int i = 0; i < layers.length; i++) {
        if (i == 0) {
          layers[i].forward(batchData);
        } else {
          layers[i].forward(layers[i - 1].outputs!);
        }
      }

      // calculate accuracy
      var loss = lossFxn.calculate(layers.last.outputs!, batchLabels);
      int correct = 0;
      for (int i = 0; i < batchLabels.length; i++) {
        if (layers.last.outputs![i].maxIndex() == batchLabels[i]) {
          correct += 1;
        }
      }
      var accuracy = correct / batchLabels.length;

      if (step % 10 == 0) {
        print(
            "TEST - STEP: $step LOSS: $loss, ACC: $accuracy TOTAL ACC: ${accSum / step}");
      }
      accSum += accuracy;
    }
    accuracy = accSum / steps;
    print("--TOTAL ACCURACY: $accuracy--");
  }

  Future<void> save(String about) async {
    String modelPath =
        "/Users/jakelanders/code/neural_network/neural_network/models";
    int millSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    String filename = "$modelPath/$millSinceEpoch.json.gz";
    String json = jsonEncode(toMap());
    // encode to utf-8
    List<int> encoded = utf8.encode(json);
    // compress
    List<int> compressed = gzip.encode(encoded);
    // create the file
    File file = File(filename);
    file = await file.create();
    await file.writeAsBytes(compressed);
    print("--SUCCESSFULLY SAVED MODEL TO: $filename--");

    // save comprehensive summary about network
    String summaryName = "$modelPath/$millSinceEpoch.stats.json";

    Map<String, dynamic> summary = {
      "date": DateTime.now().toString(),
      "dataset": "all_data",
      "shape": shape(),
      "layers": layers.map((e) => e.stats()).toList(),
      "accuracy": accuracy ?? "NONE",
      "lossFunction": lossFxn.name(),
      "optimizer": optimizer.toMap(),
      "about": about,
    };

    String summaryJson = jsonEncode(summary);
    List<int> summaryEncoded = utf8.encode(summaryJson);
    File summaryFile = File(summaryName);
    summaryFile = await summaryFile.create();
    await summaryFile.writeAsBytes(summaryEncoded);
    print(
      "Successfully saved comprehensive summary of model to: $summaryName",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "layers": layers.map((e) => e.toMap()).toList(),
      "lossFxn": lossFxn.name(),
      "optimizer": optimizer.toMap(),
      "accuracy": accuracy ?? "NONE",
    };
  }

  List<List<int>> shape() {
    List<List<int>> out = [];
    for (var i in layers) {
      out.add(i.shape());
    }
    return out;
  }

  List<double> predict(List<double> image) {
    for (int i = 0; i < layers.length; i++) {
      if (i == 0) {
        layers[i].forward([image]);
      } else {
        layers[i].forward(layers[i - 1].outputs!);
      }
    }
    return layers.last.outputs!.first;
  }
}

void mnist() async {
  var trainImages = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist_train.csv");

  var trainData = nnimagesToLists(trainImages);

  Network network = Network(
    layers: [
      Layer(
        inputs: trainData.v1.length,
        neurons: 128,
        activation: ReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      Layer(
        inputs: 128,
        neurons: 64,
        activation: ReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      Layer(
        inputs: 64,
        neurons: 10,
        activation: Softmax(),
      ),
    ],
    optimizer: Adam(learningRate: 0.005, decay: 5e-4),
  );

  network.train(trainData.v1, trainData.v2);

  var testImages = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist_test.csv");

  var testData = nnimagesToLists(testImages);

  network.test(testData.v1, testData.v2);

  await network.save(
      "First round of working on the optimizations. Basic mnist dataset with no modifications");
}

void mnist2() async {
  print("--READING TRAINING DATA--");
  var handDrawn = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-generated.csv");

  var trainReg = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-train.csv");
  var trainRand = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-train.csv",
      modification: (image) => image.randomized());
  var trainDraw = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-train.csv",
      modification: (image) => image.toDrawStyle());
  print("--DONE READING TRAINING DATA--");
  print("--PROCESSING TRAINING DATA--");
  List<NNImage> trainImages = [];
  trainImages.addAll(trainReg);
  trainImages.addAll(trainRand);
  trainImages.addAll(trainDraw);
  trainImages.addAll(handDrawn.sublist(0, 800));
  trainImages.shuffle();

  var trainData = nnimagesToLists(trainImages);

  print("--DONE PROCESSING TRAINING DATA--\nLENGTH=${trainData.v1.length}");

  Network network = Network(
    layers: [
      Layer(
        inputs: trainData.v1.first.length,
        neurons: 200,
        activation: ReLU(),
        weightRegL2: 5e-4,
        biasRegL2: 5e-4,
      ),
      Layer(
        inputs: 200,
        neurons: 10,
        activation: Softmax(),
      ),
    ],
    optimizer: Adam(learningRate: 0.005, decay: 5e-4),
  );

  network.train(trainData.v1, trainData.v2);

  print("--READING TESTING DATA--");
  var testReg = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-test.csv");
  var testRand = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-test.csv",
      modification: (image) => image.randomized());
  var testDraw = await readData(
      "/Users/jakelanders/code/neural_network/data/mnist-test.csv",
      modification: (image) => image.toDrawStyle());
  print("--DONE READING TESTING DATA--");
  print("--PROCESSING TESTING DATA--");
  List<NNImage> testImages = [];
  testImages.addAll(testReg);
  testImages.addAll(testRand);
  testImages.addAll(testDraw);
  testImages.addAll(handDrawn.sublist(800));
  testImages.shuffle();

  var testData = nnimagesToLists(testImages);
  print("--DONE PROCESSING TESTING DATA--\nLENGTH=${testData.v1.length}");

  network.test(testData.v1, testData.v2);

  await network.save(
      "Reworked network data, reg, randomized, draw style, and hand drawn all shuffled and trained on network");
}
