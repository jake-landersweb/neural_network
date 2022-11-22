import 'package:neural_network/vector/root.dart';

class Accuracy {
  num accumulatedSum = 0;
  int accumulatedCount = 0;

  double calculate(Vector2 predictions, Vector1 labels) {
    // calculate accuracy
    var correct = 0;
    for (var i = 0; i < labels.length; i++) {
      if (predictions[i].maxIndex() == labels[i]) {
        correct += 1;
      }
    }
    var accuracy = correct / labels.length;

    // add accumulated
    accumulatedSum += accuracy;
    accumulatedCount += 1;

    return accuracy;
  }

  double calculateAccumulated() {
    return accumulatedSum / accumulatedCount;
  }

  void newPass() {
    accumulatedSum = 0;
    accumulatedCount = 0;
  }
}
