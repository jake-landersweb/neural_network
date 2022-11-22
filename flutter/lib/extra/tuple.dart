/// To encapsulate two different datatypes
class Tuple2<I, J> {
  late I v1;
  late J v2;

  Tuple2({
    required this.v1,
    required this.v2,
  });
}

/// To encapsulate three different datatypes
class Tuple3<I, J, G> {
  late I v1;
  late J v2;
  late G v3;

  Tuple3({
    required this.v1,
    required this.v2,
    required this.v3,
  });
}
