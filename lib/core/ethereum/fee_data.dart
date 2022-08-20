import 'package:blockchain/core/ethereum/amount.dart';

class FeeData {

  final EthereumAmount gasPrice;
  final BigInt? lastBaseFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final BigInt? maxFeePerGas;
  final bool isEip1159;

  FeeData({
    required this.gasPrice,
    this.isEip1159 = false,
    this.lastBaseFeePerGas,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas
  });
}