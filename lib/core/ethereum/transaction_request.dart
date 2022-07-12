part of 'package:blockchain/blockchain.dart';

class TransactionRequest {
  /// The address of the sender of this transaction.
  ///
  /// This can be set to null, in which case the client will use the address
  /// belonging to the credentials used to this transaction.
  final String? from;

  /// The recipient of this transaction, or null for transactions that create a
  /// contract.
  final String? to;

  /// The maximum amount of gas to spend.
  ///
  /// If [maxGas] is `null`, this library will ask the rpc node to estimate a
  /// reasonable spending via [Web3Client.estimateGas].
  ///
  /// Gas that is not used but included in [maxGas] will be returned.
  final BigInt? maxGas;

  /// How much ether to spend on a single unit of gas. Can be null, in which
  /// case the rpc server will choose this value.
  final EthereumAmount? gasPrice;

  /// How much ether to send to [to]. This can be null, as some transactions
  /// that call a contracts method won't have to send ether.
  final EthereumAmount? value;

  /// For transactions that call a contract function or create a contract,
  /// contains the hashed function name and the encoded parameters or the
  /// compiled contract code, respectively.
  final Uint8List? data;

  /// The nonce of this transaction. A nonce is incremented per sender and
  /// transaction to make sure the same transaction can't be sent more than
  /// once.
  ///
  /// If null, it will be determined by checking how many transactions
  /// have already been sent by [from].
  final int? nonce;

  final EthereumAmount? maxPriorityFeePerGas;
  final EthereumAmount? maxFeePerGas;

  TransactionRequest(
      {this.from,
        this.to,
        this.maxGas,
        this.gasPrice,
        this.value,
        this.data,
        this.nonce,
        this.maxFeePerGas,
        this.maxPriorityFeePerGas});

  TransactionRequest copyWith(
      {String? from,
        String? to,
        dynamic? maxGas,
        dynamic? gasPrice,
        EthereumAmount? value,
        Uint8List? data,
        int? nonce,
        EthereumAmount? maxPriorityFeePerGas,
        EthereumAmount? maxFeePerGas}) {
    return TransactionRequest(
      from: from ?? this.from,
      to: to ?? this.to,
      maxGas: maxGas ?? this.maxGas,
      gasPrice: gasPrice ?? this.gasPrice,
      value: value ?? this.value,
      data: data ?? this.data,
      nonce: nonce ?? this.nonce,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
    );
  }

  bool get isEIP1559 => maxFeePerGas != null && maxPriorityFeePerGas != null;
}