import 'package:blockchain/blockchain.dart';
import 'package:blockchain/constant/ethereum_unit.dart';
import 'package:blockchain/core/ethereum/amount.dart';
import 'package:blockchain/blockchain.dart';

class Block {
  final String? from; // Author
  final String? boundary;
  final String? difficulty;
  final String? extraData;
  final String? gasLimit;
  final String? gasUsed;
  final String? hash;
  final String? logsBloom;
  final String? miner;
  final String? mixHash;
  final String? nonce;
  final EthereumAmount? baseFeePerGas;
  final String? number;
  final String? parentHash;
  final String? receiptsRoot;
  final String? seedHash;
  final String? sha3Uncles;
  final String? size;
  final String? stateRoot;
  final String? timestamp;
  final String? totalDifficulty;
  final List<TransactionResponse>? transactions;
  final String? transactionsRoot;
  final List<dynamic>? uncles;

  Block({
    this.from,
    this.boundary,
    this.difficulty,
    this.extraData,
    this.gasLimit,
    this.gasUsed,
    this.hash,
    this.logsBloom,
    this.miner,
    this.mixHash,
    this.nonce,
    this.baseFeePerGas,
    this.number,
    this.parentHash,
    this.receiptsRoot,
    this.seedHash,
    this.sha3Uncles,
    this.size,
    this.stateRoot,
    this.timestamp,
    this.totalDifficulty,
    this.transactions,
    this.transactionsRoot,
    this.uncles,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> list = List.castFrom(json['transactions'] as List<dynamic>);
    List<TransactionResponse>? transactions;
    if (list.isNotEmpty) {
      transactions = list.map((Map<String, dynamic> e) => TransactionResponse.fromMap(e)).toList();
    } else {
      transactions = null;
    }

    final String? from = json.containsKey('author') ? json['author'] : null;
    final String? boundary = json.containsKey('boundary') ? json['boundary'] as String : null;
    final String? difficulty = json.containsKey('difficulty') ? json['difficulty'] as String : null;
    final String? extraData = json.containsKey('extraData') ? json['extraData'] as String : null;
    final String? gasLimit = json.containsKey('gasLimit') ? json['gasLimit'] as String : null;
    final String? gasUsed = json.containsKey('gasUsed') ? json['gasUsed'] as String : null;
    final String? hash = json.containsKey('hash') ? json['hash'] as String : null;
    final String? logsBloom = json.containsKey('logsBloom') ? json['logsBloom'] as String : null;
    final String? miner = json.containsKey('miner') ? json['miner'] : null;
    final String? mixHash = json.containsKey('mixHash') ? json['mixHash'] as String : null;
    final String? nonce = json.containsKey('nonce') ? json['nonce'] as String : null;
    final EthereumAmount? baseFeePerGas = json.containsKey('baseFeePerGas') ? EthereumAmount.fromUnitAndValue(EthereumUnit.wei, Formatter.hexToInt(json['baseFeePerGas'] as String)) : null;
    final String? number = json.containsKey('number') ? json['number'] as String : null;
    final String? parentHash = json.containsKey('parentHash') ? json['parentHash'] as String : null;
    final String? receiptsRoot = json.containsKey('receiptsRoot') ? json['receiptsRoot'] as String : null;
    final String? seedHash = json.containsKey('seedHash') ? json['seedHash'] as String : null;
    final String? sha3Uncles = json.containsKey('sha3Uncles') ? json['sha3Uncles'] as String : null;
    final String? size = json.containsKey('size') ? json['size'] as String : null;
    final String? stateRoot = json.containsKey('stateRoot') ? json['size'] as String : null;
    final String? timestamp = json.containsKey('timestamp') ? json['timestamp'] as String : null;
    final String? totalDifficulty = json.containsKey('totalDifficulty') ? json['totalDifficulty'] as String : null;
    final String? transactionsRoot = json.containsKey('transactionsRoot') ? json['transactionsRoot'] as String : null;
    final List<dynamic>? uncles = json.containsKey('uncles') ? json['uncles'] as List<dynamic> : null;


    return Block(
      from: from,
      boundary: boundary,
      difficulty: difficulty,
      extraData: extraData,
      gasLimit: gasLimit,
      gasUsed: gasUsed,
      hash: hash,
      logsBloom: logsBloom,
      miner: miner,
      mixHash: mixHash,
      nonce: nonce,
      baseFeePerGas: baseFeePerGas,
      number: number,
      parentHash: parentHash,
      receiptsRoot: receiptsRoot,
      seedHash: seedHash,
      sha3Uncles: sha3Uncles,
      size: size,
      stateRoot: stateRoot,
      timestamp: timestamp,
      totalDifficulty: totalDifficulty,
      transactions: transactions,
      transactionsRoot: transactionsRoot,
      uncles: uncles,
    );
  }

  bool get isSupportEIP1559 => baseFeePerGas != null;
}