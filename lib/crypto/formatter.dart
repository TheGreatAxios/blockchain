import 'dart:typed_data';
import 'package:convert/convert.dart' show hex;
import 'package:pointycastle/src/utils.dart' as castle;


/// Formatter Class
/// Core Web3 Formatting Utils
abstract class Formatter {

  /// Removes 0x from String
  static String remove0x(String hex) {
    if (hex.startsWith('0x')) {
      return hex.substring(2);
    }
    return hex;
  }

  /// Converts the [bytes] given as a list of integers into a hexadecimal
  /// representation.
  /// If any of the bytes is outside of the range [0, 256], the method will throw.
  /// The outcome of this function will prefix a 0 if it would otherwise not be
  /// of even length. If [include0x] is set, it will prefix "0x" to the hexadecimal
  /// representation. If [forcePadLength] is set, the hexadecimal representation
  /// will be expanded with zeroes until the desired length is reached. The "0x"
  /// prefix does not count for the length.
  static String bytesToHex(List<int> bytes, {
    bool include0x = false,
    bool padToEvenLength = false,
    int? forcePadLength,
  }) {
    try {
      String encoded = hex.encode(bytes);

      if (forcePadLength != null) {
        if (forcePadLength < encoded.length) {
          throw Error.safeToString({
            "package": "blockchain",
            "function": "BytesToHex",
            "err": "Force Pad Length < Encode.length"
          });
        }

        final padding = forcePadLength - encoded.length;
        encoded = ('0' * padding) + encoded;
      }

      if (padToEvenLength && encoded.length % 2 != 0) {
        encoded = '0$encoded';
      }

      return (include0x ? '0x' : '') + encoded;
    } catch (err) {
      rethrow;
    }
  }


  /// Converts the hexadecimal string, which can be prefixed with 0x, to a byte
  /// sequence.
  static Uint8List hexToBytes(String hexStr) {
    final bytes = hex.decode(remove0x(hexStr));
    if (bytes is Uint8List) return bytes;

    return Uint8List.fromList(bytes);
  }

  static Uint8List unsignedIntToBytes(BigInt number) {
    try {
      if (number.isNegative) {
        throw Error.safeToString({
          "package": "blockchain",
          "function": "BytesToHex",
          "err": "Number Is Negative"
        });
      }
      return castle.encodeBigIntAsUnsigned(number);
    } catch (err) {
      rethrow;
    }
  }

  static BigInt bytesToUnsignedInt(Uint8List bytes) {
    return castle.decodeBigIntWithSign(1, bytes);
  }

  ///Converts the bytes from that list (big endian) to a (potentially signed)
  /// BigInt.
  static BigInt bytesToInt(List<int> bytes) => castle.decodeBigInt(bytes);

  static Uint8List intToBytes(BigInt number) => castle.encodeBigInt(number);

  ///Takes the hexadecimal input and creates a [BigInt].
  static BigInt hexToInt(String hex) {
    return BigInt.parse(remove0x(hex), radix: 16);
  }

  /// Converts the hexadecimal input and creates an [int].
  static int hexToDartInt(String hex) {
    return int.parse(remove0x(hex), radix: 16);
  }

}