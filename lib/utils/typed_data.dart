import 'dart:typed_data';

abstract class TypedData {
  static Uint8List uint8ListFromList(List<int> data) {
    if (data is Uint8List) return data;

    return Uint8List.fromList(data);
  }

  static Uint8List padUint8ListTo32(Uint8List data) {
    assert(data.length <= 32);
    if (data.length == 32) return data;

    // todo there must be a faster way to do this?
    return Uint8List(32)..setRange(32 - data.length, 32, data);
  }
}