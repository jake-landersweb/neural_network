import 'root.dart';

double dot1D1D(List<double> list1, List<double> list2) {
  assert(list1.length == list2.length, "Lists must be the same length");
  double out = 0;
  for (int i = 0; i < list1.length; i++) {
    out += list1[i] * list2[i];
  }
  return out;
}

List<double> dot1D2D(List<double> list1, List<List<double>> list2) {
  assert(list1.length == list2[0].length,
      "The elements in list2 should be the same length as list1");
  List<double> out = [];
  for (var i = 0; i < list2.length; i++) {
    out.add(dot1D1D(list1, list2[i]));
  }
  return out;
}

List<List<double>> dot2D2D(List<List<double>> list1, List<List<double>> list2) {
  assert(list1[0].length == list2.length,
      "List2 must have the same length as the element length inside of list1");
  List<List<double>> transposedList2 = list2.transpose();

  List<List<double>> out = [];
  for (var i in list1) {
    List<double> col = [];
    for (var j in transposedList2) {
      col.add(dot1D1D(i, j));
    }
    out.add(col);
  }

  return out;
}

List<double> vectorSum1D1D(List<double> list1, List<double> list2) {
  assert(list1.length == list2.length, "Lists must be the same length");
  List<double> out = [];
  for (int i = 0; i < list1.length; i++) {
    out.add(list1[i] + list2[i]);
  }
  return out;
}

List<List<double>> vectorSum2D1D(List<List<double>> list1, List<double> list2) {
  assert(list1[0].length == list2.length,
      "The elements in list1 should be the same length as list2");
  List<List<double>> out = [];

  for (var i in list1) {
    out.add(vectorSum1D1D(i, list2));
  }

  return out;
}

List<List<double>> vectorSum2D2D(
    List<List<double>> list1, List<List<double>> list2) {
  assert(list1.length == list2.length, "The length of the lists need to match");
  List<List<double>> out = [];

  for (var i = 0; i < list1.length; i++) {
    List<double> temp = [];
    for (var j = 0; j < list1[i].length; j++) {
      temp.add(list1[i][j] + list2[i][j]);
    }
    out.add(temp);
  }
  return out;
}
