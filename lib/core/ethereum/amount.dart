import 'package:blockchain/constant/ethereum_unit.dart';

/// Utility class to easily convert amounts of Ether into different units of
/// quantities.
class EthereumAmount {
  static final Map<EthereumUnit, BigInt> _factors = {
    EthereumUnit.wei: BigInt.one,
    EthereumUnit.kwei: BigInt.from(10).pow(3),
    EthereumUnit.mwei: BigInt.from(10).pow(6),
    EthereumUnit.gwei: BigInt.from(10).pow(9),
    EthereumUnit.szabo: BigInt.from(10).pow(12),
    EthereumUnit.finney: BigInt.from(10).pow(15),
    EthereumUnit.ether: BigInt.from(10).pow(18)
  };

  final BigInt _value;

  BigInt get getInWei => _value;
  BigInt get getInEther => getValueInUnitBI(EthereumUnit.ether);

  const EthereumAmount.inWei(this._value);

  EthereumAmount.zero() : this.inWei(BigInt.zero);

  /// Constructs an amount of Ether by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or a BigInt.
  factory EthereumAmount.fromUnitAndValue(EthereumUnit unit, dynamic amount) {
    BigInt parsedAmount;
    if (amount is BigInt) {
      parsedAmount = amount;
    } else if (amount is int) {
      parsedAmount = BigInt.from(amount);
    } else if (amount is String) {
      parsedAmount = BigInt.parse(amount);
    } else {
      throw ArgumentError('Invalid type, must be BigInt, string or int');
    }

    return EthereumAmount.inWei(parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except for [EtherUnit.wei], this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of ether by
  /// using a BigInt storing the amount in wei.
  BigInt getValueInUnitBI(EthereumUnit unit) => _value ~/ _factors[unit]!;

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of ether in a human-readable format, it should not be
  /// used for anything else.
  num getValueInUnit(EthereumUnit unit) {
    final factor = _factors[unit]!;
    final value = _value ~/ factor;
    final remainder = _value.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }

  @override
  String toString() {
    return 'EtherAmount: $getInWei wei';
  }

  @override
  int get hashCode => getInWei.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is EthereumAmount && other.getInWei == getInWei;
}