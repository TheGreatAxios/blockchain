part of 'package:blockchain/blockchain.dart';

class TransactionResponse{

  TransactionResponse({
    required this.blockNumber,
    required this.from,
    required this.gas,
    required this.gasPrice,
    required this.hash,
    required this.input,
    required this.nonce,
    required this.value,
    required this.r,
    required this.s,
    required this.v,
    this.blockHash,
    this.to,
    this.transactionIndex,
  });

  TransactionResponse.noSignature({
    required this.blockHash,
    required this.blockNumber,
    required this.from,
    required this.gas,
    required this.gasPrice,
    required this.hash,
    required this.input,
    required this.nonce,
    required this.to,
    required this.transactionIndex,
    required this.value
  });

  factory TransactionResponse.returnFromTxHash(Map<String, dynamic> map) {
    return TransactionResponse.noSignature(
      blockHash: map['blockHash'] as String,
      blockNumber: map['blockNumber'] != null ? BlockNumber.exact(
          int.parse(map['blockNumber'] as String)) : const BlockNumber.pending(),
      from: EthereumAddress.fromHex(map['from'] as String),
      gas: int.parse(map['gas'] as String),
      gasPrice: EthereumAmount.inWei(BigInt.parse(map['gasPrice'] as String)),
      hash: map['hash'] as String,
      input: Formatter.hexToBytes(map['input'] as String),
      nonce: int.parse(map['nonce'] as String),
      to: map['to'] != null
          ? EthereumAddress.fromHex(map['to'] as String)
          : null,
      transactionIndex: map['transactionIndex'] != null ? int.parse(
          map['transactionIndex'] as String) : null,
      value: EthereumAmount.inWei(BigInt.parse(map['value'] as String)),
    );
  }

  factory TransactionResponse.fromMap(Map<String, dynamic> map) {
    return TransactionResponse(
        blockHash: map['blockHash'] as String,
        blockNumber: map['blockNumber'] != null ? BlockNumber.exact(
            int.parse(map['blockNumber'] as String)) : const BlockNumber.pending(),
        from: EthereumAddress.fromHex(map['from'] as String),
        gas: int.parse(map['gas'] as String),
        gasPrice: EthereumAmount.inWei(BigInt.parse(map['gasPrice'] as String)),
        hash: map['hash'] as String,
        input: Formatter.hexToBytes(map['input'] as String),
        nonce: int.parse(map['nonce'] as String),
        to: map['to'] != null
            ? EthereumAddress.fromHex(map['to'] as String)
            : null,
        transactionIndex: map['transactionIndex'] != null ? int.parse(
            map['transactionIndex'] as String) : null,
        value: EthereumAmount.inWei(BigInt.parse(map['value'] as String)),
        v: int.parse(map['v'] as String),
        r: Formatter.hexToInt(map['r'] as String),
        s: Formatter.hexToInt(map['s'] as String)
    );
  }
  /// The hash of the block containing this transaction. If this transaction has
  /// not been mined yet and is thus in no block, it will be `null`
  final String? blockHash;

  /// [BlockNum] of the block containing this transaction, or [BlockNum.pending]
  /// when the transaction is not part of any block yet.
  final BlockNumber blockNumber;

  /// The sender of this transaction.
  final EthereumAddress from;

  /// How many units of gas have been used in this transaction.
  final int gas;

  /// The amount of Ether that was used to pay for one unit of gas.
  final EthereumAmount gasPrice;

  /// A hash of this transaction, in hexadecimal representation.
  final String hash;

  /// The data sent with this transaction.
  final Uint8List input;

  /// The nonce of this transaction. A nonce is incremented per sender and
  /// transaction to make sure the same transaction can't be sent more than
  /// once.
  final int nonce;

  /// Address of the receiver. `null` when its a contract creation transaction
  final EthereumAddress? to;

  /// Integer of the transaction's index position in the block. `null` when it's
  /// pending.
  int? transactionIndex;

  /// The amount of Ether sent with this transaction.
  final EthereumAmount value;

  /// A cryptographic recovery id which can be used to verify the authenticity
  /// of this transaction together with the signature [r] and [s]
  late final int v;

  /// ECDSA signature r
  late final BigInt r;

  /// ECDSA signature s
  late final BigInt s;

  /// The ECDSA full signature used to sign this transaction.
  MsgSignature get signature => MsgSignature(r, s, v);
}

class TransactionReceipt {
  TransactionReceipt(
      {required this.transactionHash,
        required this.transactionIndex,
        required this.blockHash,
        required this.cumulativeGasUsed,
        this.blockNumber = const BlockNumber.pending(),
        this.contractAddress,
        this.status,
        this.from,
        this.to,
        this.gasUsed,
        this.effectiveGasPrice,
        this.logs = const []});

  factory TransactionReceipt.fromMap(Map<String, dynamic> map) {
    return TransactionReceipt(
        transactionHash: Formatter.hexToBytes(map['transactionHash'] as String),
        transactionIndex: Formatter.hexToDartInt(map['transactionIndex'] as String),
        blockHash: Formatter.hexToBytes(map['blockHash'] as String),
        blockNumber: map['blockNumber'] != null
            ? BlockNumber.exact(int.parse(map['blockNumber'] as String))
            : const BlockNumber.pending(),
        from: map['from'] != null
            ? EthereumAddress.fromHex(map['from'] as String)
            : null,
        to: map['to'] != null
            ? EthereumAddress.fromHex(map['to'] as String)
            : null,
        cumulativeGasUsed: Formatter.hexToInt(map['cumulativeGasUsed'] as String),
        gasUsed:
        map['gasUsed'] != null ? Formatter.hexToInt(map['gasUsed'] as String) : null,
        effectiveGasPrice: map['effectiveGasPrice'] != null
            ? EthereumAmount.inWei(
            BigInt.parse(map['effectiveGasPrice'] as String))
            : null,
        contractAddress: map['contractAddress'] != null
            ? EthereumAddress.fromHex(map['contractAddress'] as String)
            : null,
        status: map['status'] != null
            ? (Formatter.hexToDartInt(map['status'] as String) == 1)
            : null,
        logs: map['logs'] != null
            ? (map['logs'] as List<dynamic>)
            .map((log) => FilterEvent.fromMap(log as Map<String, dynamic>))
            .toList()
            : [
        ]
    );
  }
  /// Hash of the transaction (32 bytes).
  final Uint8List transactionHash;

  /// Index of the transaction's position in the block.
  final int transactionIndex;

  /// Hash of the block where this transaction is in (32 bytes).
  final Uint8List blockHash;

  /// Block number where this transaction is in.
  final BlockNumber blockNumber;

  /// Address of the sender.
  final EthereumAddress? from;

  /// Address of the receiver or `null` if it was a contract creation
  /// transaction.
  final EthereumAddress? to;

  /// The total amount of gas used when this transaction was executed in the
  /// block.
  final BigInt cumulativeGasUsed;

  /// The amount of gas used by this specific transaction alone.
  final BigInt? gasUsed;

  /// The address of the contract created if the transaction was a contract
  /// creation. `null` otherwise.
  final EthereumAddress? contractAddress;

  /// Whether this transaction was executed successfully.
  final bool? status;

  /// Array of logs generated by this transaction.
  final List<FilterEvent> logs;

  final EthereumAmount? effectiveGasPrice;

  @override
  String toString() {
    return 'TransactionReceipt{transactionHash: ${Formatter.bytesToHex(transactionHash)}, '
        'transactionIndex: $transactionIndex, blockHash: ${Formatter.bytesToHex(blockHash)}, '
        'blockNumber: $blockNumber, from: ${from?.hex}, to: ${to?.hex}, '
        'cumulativeGasUsed: $cumulativeGasUsed, gasUsed: $gasUsed, '
        'contractAddress: ${contractAddress?.hex}, status: $status, '
        'effectiveGasPrice: $effectiveGasPrice, logs: $logs}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TransactionReceipt &&
              runtimeType == other.runtimeType &&
              const ListEquality().equals(transactionHash, other.transactionHash) &&
              transactionIndex == other.transactionIndex &&
              const ListEquality().equals(blockHash, other.blockHash) &&
              blockNumber == other.blockNumber &&
              from == other.from &&
              to == other.to &&
              cumulativeGasUsed == other.cumulativeGasUsed &&
              gasUsed == other.gasUsed &&
              contractAddress == other.contractAddress &&
              status == other.status &&
              effectiveGasPrice == other.effectiveGasPrice &&
              const ListEquality().equals(logs, other.logs);

  @override
  int get hashCode =>
      transactionHash.hashCode ^
      transactionIndex.hashCode ^
      blockHash.hashCode ^
      blockNumber.hashCode ^
      from.hashCode ^
      to.hashCode ^
      cumulativeGasUsed.hashCode ^
      gasUsed.hashCode ^
      contractAddress.hashCode ^
      status.hashCode ^
      effectiveGasPrice.hashCode ^
      logs.hashCode;
}