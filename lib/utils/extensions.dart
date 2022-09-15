extension List1DExtension on List<num> {
  /// Get max value in 1d array
  num max() {
    num max = 0;
    for (var i in this) {
      if (i > max) {
        max = i;
      }
    }
    return max;
  }

  /// Get which index contains the max value
  int maxIndex() {
    int idx = 0;
    num max = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] > max) {
        idx = i;
        max = this[i];
      }
    }
    return idx;
  }

  /// Add all values in array together
  num sum() {
    num sum = 0;
    for (var i in this) {
      sum += i;
    }
    return sum;
  }

  /// Quick mean calculation of the array values
  num mean() {
    return sum() / length;
  }

  /// Multiply all values by a number
  List<num> multiply(num value) {
    List<num> out = [];
    for (var i in this) {
      out.add(i * value);
    }
    return out;
  }

  /// Add all values by a number
  List<num> add(num value) {
    List<num> out = [];
    for (var i in this) {
      out.add(i + value);
    }
    return out;
  }
}

extension List2DExtension on List<List<double>> {
  /// Conveniently see dimensions of 2d array
  String size() {
    return "($length, ${this[0].length})";
  }

  /// Transpose a 2d array, cols become rows, rows become cols
  List<List<double>> transpose() {
    List<List<double>> out = List.generate(this[0].length, (_) => []);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < this[i].length; j++) {
        out[j].add(this[i][j]);
      }
    }

    return out;
  }

  /// Multiply all elements by a number
  List<List<double>> multiply0D(double value) {
    List<List<double>> total = [];
    for (var row in this) {
      total.add(row.multiply(value).map((e) => e.toDouble()).toList());
    }
    return total;
  }

  /// Add all elements by a value
  List<List<double>> add0D(double value) {
    List<List<double>> total = [];
    for (var row in this) {
      total.add(row.add(value) as List<double>);
    }
    return total;
  }

  /// For pretty printing the 2d array
  String pretty({int precision = 6}) {
    String out = "[";
    for (var i in this) {
      out += "[";
      for (var j = 0; j < i.length; j++) {
        if (!i[j].isNegative) {
          out += " ";
        }
        // if (j < 0.001) {
        //   out += j.toStringAsExponential(precision);
        // } else {
        //   out += j.toStringAsFixed(precision);
        // }
        out += i[j].toStringAsExponential(precision);
        if (j != i.length - 1) {
          out += " ";
        }
      }
      out += "]";
      if (i != last) {
        out += "\n ";
      } else {
        out += "]";
      }
    }
    return out;
  }
}
