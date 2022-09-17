import 'dart:math';

import 'root.dart';

/// Returns the dot product of two vectors. When both vectors are
/// [Vector1], the return vector will be a [Vector1] with a length of 1.
/// When one vector is [Vector1] and the other is [Vector2], the
/// returned vector will be [Vector1]. If both of the vectors are
/// [Vector2], the returned vector will be [Vector2].
Vector dot(Vector v1, Vector v2) {
  if (v1 is Vector1) {
    if (v2 is Vector1) {
      // both 1D
      return _dot1D1D(v1, v2);
    } else {
      // v1 1D v2 2D
      return _dot1D2D(v1, v2 as Vector2);
    }
  } else {
    if (v2 is Vector1) {
      // v1 is 2D v2 is 1D
      return _dot1D2D(v2, v1 as Vector2);
    } else {
      // both 2D
      return _dot2D2D(v1 as Vector2, v2 as Vector2);
    }
  }
}

Vector1 _dot1D1D(Vector1 v1, Vector1 v2) {
  assert(v1.length == v2.length, "Lists must be the same length");
  double out = 0;
  for (int i = 0; i < v1.length; i++) {
    out += v1[i] * v2[i];
  }
  return Vector1.from([out]);
}

Vector1 _dot1D2D(Vector1 v1, Vector2 v2) {
  assert(v1.length == v2[0].length,
      "The elements in v2 should be the same length as v1");
  List<num> out = [];
  for (var i = 0; i < v2.length; i++) {
    out.add(_dot1D1D(v1, v2[i]).first);
  }
  return Vector1.from(out);
}

Vector2 _dot2D2D(Vector2 v1, Vector2 v2) {
  assert(v1[0].length == v2.length,
      "v2 must have the same length as the element length inside of v1");
  Vector2 transposedv2 = v2.T;

  List<List<num>> out = [];
  for (var i in v1.val) {
    List<num> col = [];
    for (var j in transposedv2.val) {
      col.add(_dot1D1D(i, j).first);
    }
    out.add(col);
  }

  return Vector2.from(out);
}

/// Loops through all values in the vector and
/// replaces the vector value with the passed value
/// if the passed value is larger.
Vector maximum(num value, Vector vec) {
  if (vec is Vector1) {
    return _max1D(value, vec);
  } else if (vec is Vector2) {
    return _max2D(value, vec);
  } else {
    throw "Invalid Vector type";
  }
}

Vector1 _max1D(num value, Vector1 vec) {
  Vector1 out = Vector1.empty();
  for (num i in vec) {
    if (value > i) {
      out.add(value);
    } else {
      out.add(i);
    }
  }
  return out;
}

Vector2 _max2D(num value, Vector2 vec) {
  Vector2 out = Vector2.empty();
  for (Vector1 i in vec) {
    out.add(_max1D(value, i));
  }
  return out;
}

Vector minimum(num value, Vector vec) {
  if (vec is Vector1) {
    return _min1D(value, vec);
  } else if (vec is Vector2) {
    return _min2D(value, vec);
  } else {
    throw "Invalid Vector type";
  }
}

Vector1 _min1D(num value, Vector1 vec) {
  Vector1 out = Vector1.empty();
  for (num i in vec) {
    if (i < value) {
      out.add(value);
    } else {
      out.add(i);
    }
  }
  return out;
}

Vector2 _min2D(num value, Vector2 vec) {
  Vector2 out = Vector2.empty();
  for (Vector1 i in vec) {
    out.add(_max1D(value, i));
  }
  return out;
}
