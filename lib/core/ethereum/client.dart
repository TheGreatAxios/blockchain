part of 'package:blockchain/blockchain.dart';

/// Signature for a function that opens a socket on which json-rpc operations
/// can be performed.
///
/// Typically, this would be a websocket. The `web_socket_channel` package on
/// pub is suitable to create websockets. An implementation using that library
/// could look like this:
/// ```dart
/// import "package:web3dart/web3dart.dart";
/// import "package:web_socket_channel/io.dart";
///
/// final client = Web3Client(rpcUrl, Client(), socketConnector: () {
///    return IOWebSocketChannel.connect(wsUrl).cast<String>();
/// });
/// ```
typedef SocketConnector = StreamChannel<String> Function();

/// Class for sending requests over an HTTP JSON-RPC API endpoint to Ethereum
/// clients. This library won't use the accounts feature of clients to use them
/// to create transactions, you will instead have to obtain private keys of
/// accounts yourself.
class EthereumClient {
  /// Starts a client that connects to a JSON rpc API, available at [url]. The
  /// [httpClient] will be used to send requests to the rpc server.
  /// Am isolate will be used to perform expensive operations, such as signing
  /// transactions or computing private keys.
  EthereumClient(String url, Client httpClient, {SocketConnector? socketConnector})
      : this.custom(JsonRPC(url, httpClient), socketConnector: socketConnector);

  EthereumClient.custom(RpcService rpc, {this.socketConnector}) : _jsonRpc = rpc {
    _filters = _FilterEngine(this);
  }

  static const BlockNumber _defaultBlock = BlockNumber.current();

  final RpcService _jsonRpc;

  /// Some ethereum nodes support an event channel over websockets. Web3dart
  /// will use the [StreamChannel] returned by this function as a socket to send
  /// event requests and parse responses. Can be null, in which case a polling
  /// implementation for events will be used.
  // @experimental
  final SocketConnector? socketConnector;

  rpc.Peer? _streamRpcPeer;
  late final _FilterEngine _filters;

  ///Whether errors, handled or not, should be printed to the console.
  bool printErrors = false;

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) async {
    try {
      // print(function);
      // print(params);
      // params?.forEach((element) => print(element.toString()));
      final data = await _jsonRpc.call(function, params);

      if (data is Error || data is Exception) {
        // print("Error Result");
        // print(data.result);
        throw data;
      }
      // print(data.result.runtimeType);
      return data.result as T;

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // print("Print Errors");
      if (printErrors) print(e);

      rethrow;
    }
  }

  rpc.Peer? _connectWithPeer() {
    if (_streamRpcPeer != null && !_streamRpcPeer!.isClosed) {
      return _streamRpcPeer;
    }
    if (socketConnector == null) return null;

    final socket = socketConnector!();
    _streamRpcPeer = rpc.Peer(socket)
      ..registerMethod('eth_subscription', _filters.handlePubSubNotification);

    _streamRpcPeer?.listen().then((_) {
      // .listen() will complete when the socket is closed, so reset client
      _streamRpcPeer = null;
      _filters.handleConnectionClosed();
    });

    return _streamRpcPeer;
  }

  String _getBlockParam(BlockNumber? block) {
    return (block ?? _defaultBlock).toBlockParam();
  }

  /// Constructs a new [Credentials] with the provided [privateKey] by using
  /// an [EthPrivateKey].
  @Deprecated('Use EthPrivateKey.fromHex instead')
  Future<EthPrivateKey> credentialsFromPrivateKey(String privateKey) {
    return Future.value(EthPrivateKey.fromHex(privateKey));
  }

  /// Returns the version of the client we're sending requests to.
  Future<String> getClientVersion() {
    return _makeRPCCall('web3_clientVersion');
  }

  /// Returns the id of the network the client is currently connected to.
  ///
  /// In a non-private network, the network ids usually correspond to the
  /// following networks:
  /// 1: Ethereum Mainnet
  /// 2: Morden Testnet (deprecated)
  /// 3: Ropsten Testnet
  /// 4: Rinkeby Testnet
  /// 42: Kovan Testnet
  Future<int> getNetworkId() {
    return _makeRPCCall<String>('net_version').then(int.parse);
  }

  Future<BigInt> getChainId() {
    return _makeRPCCall<String>('eth_chainId').then(BigInt.parse);
  }

  /// Returns true if the node is actively listening for network connections.
  Future<bool> isListeningForNetwork() {
    return _makeRPCCall('net_listening');
  }

  /// Returns the amount of Ethereum nodes currently connected to the client.
  Future<int> getPeerCount() async {
    final hex = await _makeRPCCall<String>('net_peerCount');
    return Formatter.hexToInt(hex).toInt();
  }

  /// Returns the version of the Ethereum-protocol the client is using.
  Future<int> getEtherProtocolVersion() async {
    final hex = await _makeRPCCall<String>('eth_protocolVersion');
    return Formatter.hexToInt(hex).toInt();
  }

  /// Returns an object indicating whether the node is currently synchronising
  /// with its network.
  ///
  /// If so, progress information is returned via [SyncInformation].
  Future<SyncInformation> getSyncStatus() async {
    final data = await _makeRPCCall<dynamic>('eth_syncing');

    if (data is Map) {
      final startingBlock = Formatter.hexToInt(data['startingBlock'] as String).toInt();
      final currentBlock = Formatter.hexToInt(data['currentBlock'] as String).toInt();
      final highestBlock = Formatter.hexToInt(data['highestBlock'] as String).toInt();

      return SyncInformation(startingBlock, currentBlock, highestBlock);
    } else {
      return SyncInformation(null, null, null);
    }
  }

  Future<String> coinbaseAddress() async {
    final hex = await _makeRPCCall<String>('eth_coinbase');
    return hex;
  }

  /// Returns true if the connected client is currently mining, false if not.
  Future<bool> isMining() {
    return _makeRPCCall('eth_mining');
  }

  /// Returns the amount of hashes per second the connected node is mining with.
  Future<int> getMiningHashrate() {
    return _makeRPCCall<String>('eth_hashrate')
        .then((s) => Formatter.hexToInt(s).toInt());
  }

  /// Returns the amount of Ether typically needed to pay for one unit of gas.
  ///
  /// Although not strictly defined, this value will typically be a sensible
  /// amount to use.
  Future<EthereumAmount> getGasPrice() async {
    final data = await _makeRPCCall<String>('eth_gasPrice');
    // print("Data on Gas: ${data}");
    return EthereumAmount.fromUnitAndValue(EthereumUnit.wei, Formatter.hexToInt(data));
  }

  /// Returns the number of the most recent block on the chain.
  Future<int> getBlockNumberber() {
    return _makeRPCCall<String>('eth_blockNumber')
        .then((s) => Formatter.hexToInt(s).toInt());
  }

  Future<Block> getBlock(
      {String blockNumber = 'latest', bool isContainFullObj = true}) {
    return _makeRPCCall<Map<String, dynamic>>(
        'eth_getBlockByNumber', [blockNumber, isContainFullObj])
        .then((Map<String, dynamic> json) => Block.fromJson(json));
  }

  /// Gets the balance of the account with the specified address.
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNumber.current] will be used.
  Future<EthereumAmount> getBalance(String address, {BlockNumber? atBlock}) {
    final blockParam = _getBlockParam(atBlock);

    return _makeRPCCall<String>('eth_getBalance', [address, blockParam])
        .then((data) {
      return EthereumAmount.fromUnitAndValue(EthereumUnit.wei, Formatter.hexToInt(data));
    });
  }

  /// Gets an element from the storage of the contract with the specified
  /// [address] at the specified [position].
  /// See https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_getstorageat for
  /// more details.
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNumber.current] will be used.
  Future<Uint8List> getStorage(String address, BigInt position,
      {BlockNumber? atBlock}) {
    final blockParam = _getBlockParam(atBlock);

    return _makeRPCCall<String>('eth_getStorageAt', [
      address,
      '0x${position.toRadixString(16)}',
      blockParam
    ]).then(Formatter.hexToBytes);
  }

  /// Gets the amount of transactions issued by the specified [address].
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNumber.current] will be used.
  Future<int> getTransactionCount(String address,
      {BlockNumber? atBlock}) {
    final blockParam = _getBlockParam(atBlock);

    return _makeRPCCall<String>(
        'eth_getTransactionCount', [address, blockParam])
        .then((hex) => Formatter.hexToInt(hex).toInt());
  }

  /// Returns the information about a transaction requested by transaction hash
  /// [transactionHash].
  Future<TransactionResponse> getTransactionByHash(String transactionHash) {
    return _makeRPCCall<Map<String, dynamic>>(
        'eth_getTransactionByHash', [transactionHash])
        .then((s) => TransactionResponse.returnFromTxHash(s));
  }

  /// Returns an receipt of a transaction based on its hash.
  Future<TransactionReceipt?> getTransactionReceipt(String hash) {
    return _makeRPCCall<Map<String, dynamic>?>(
        'eth_getTransactionReceipt', [hash])
        .then((s) => s != null ? TransactionReceipt.fromMap(s) : null);
  }

  /// Gets the code of a contract at the specified [address]
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNumber.current] will be used.
  Future<Uint8List> getCode(String address, {BlockNumber? atBlock}) {
    return _makeRPCCall<String>(
        'eth_getCode', [address, _getBlockParam(atBlock)]).then(Formatter.hexToBytes);
  }

  /// Returns all logs matched by the filter in [options].
  ///
  /// See also:
  ///  - [events], which can be used to obtain a stream of log events
  ///  - https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_getlogs
  Future<List<FilterEvent>> getLogs(FilterOptions options) {
    final filter = _EventFilter(options);
    return _makeRPCCall<List<dynamic>>(
        'eth_getLogs', [filter._createParamsObject(true)]).then((logs) {
      return logs.map(filter.parseChanges).toList();
    });
  }

  /// Signs the given transaction using the keys supplied in the [cred]
  /// object to upload it to the client so that it can be executed.
  ///
  /// Returns a hash of the transaction which, after the transaction has been
  /// included in a mined block, can be used to obtain detailed information
  /// about the transaction.
  Future<String> sendTransaction(EthereumCredentials cred, TransactionRequest transaction,
      {int? chainId = 1, bool fetchChainIdFromNetworkId = false}) async {
    if (cred is CustomTransactionSender) {
      return cred.sendTransaction(transaction);
    }

    var signed = await signTransaction(cred, transaction,
        chainId: chainId, fetchChainIdFromNetworkId: fetchChainIdFromNetworkId);

    if (transaction.isEIP1559) {
      signed = prependTransactionType(0x02, signed);
    }

    return sendRawTransaction(signed);
  }

  /// Sends a raw, signed transaction.
  ///
  /// To obtain a transaction in a signed form, use [signTransaction].
  ///
  /// Returns a hash of the transaction which, after the transaction has been
  /// included in a mined block, can be used to obtain detailed information
  /// about the transaction.
  Future<String> sendRawTransaction(Uint8List signedTransaction) async {
    return _makeRPCCall('eth_sendRawTransaction', [
      Formatter.bytesToHex(signedTransaction, include0x: true, padToEvenLength: true)
    ]);
  }

  /// Signs the [transaction] with the credentials [cred]. The transaction will
  /// not be sent.
  ///
  /// See also:
  ///  - [bytesToHex], which can be used to get the more common hexadecimal
  /// representation of the transaction.
  Future<Uint8List> signTransaction(EthereumCredentials cred, TransactionRequest transaction,
      {int? chainId = 1, bool fetchChainIdFromNetworkId = false}) async {
    final signingInput = await _fillMissingData(
      credentials: cred,
      transaction: transaction,
      chainId: chainId,
      loadChainIdFromNetwork: fetchChainIdFromNetworkId,
      client: this,
    );

    return _signTransaction(signingInput.transaction, signingInput.credentials,
        signingInput.chainId);
  }

  // /// Calls a [function] defined in the smart [contract] and returns it's
  // /// result.
  // ///
  // /// The connected node must be able to calculate the result locally, which
  // /// means that the call can't write any data to the blockchain. Doing that
  // /// would require a transaction which can be sent via [sendTransaction].
  // /// As no data will be written, you can use the [sender] to specify any
  // /// Ethereum address that would call that function. To use the address of a
  // /// credential, call [Credentials.extractAddress].
  // ///
  // /// This function allows specifying a custom block mined in the past to get
  // /// historical data. By default, [BlockNumber.current] will be used.
  // Future<List<dynamic>> call({
  //   String? sender,
  //   required DeployedContract contract,
  //   required ContractFunction function,
  //   required List<dynamic> params,
  //   BlockNumber? atBlock,
  // }) async {
  //   final encodedResult = await callRaw(
  //     sender: sender,
  //     contract: contract.address,
  //     data: function.encodeCall(params),
  //     atBlock: atBlock,
  //   );
  //   return function.decodeReturnValues(encodedResult);
  // }

  /// Estimate the amount of gas that would be necessary if the transaction was
  /// sent via [sendTransaction]. Note that the estimate may be significantly
  /// higher than the amount of gas actually used by the transaction.
  Future<BigInt> estimateGas({
    String? sender,
    String? to,
    EthereumAmount? value,
    BigInt? amountOfGas,
    EthereumAmount? gasPrice,
    EthereumAmount? maxPriorityFeePerGas,
    EthereumAmount? maxFeePerGas,
    Uint8List? data,
    @Deprecated('Parameter is ignored') BlockNumber? atBlock,
  }) async {
    try {
      final amountHex = await _makeRPCCall<String>(
        'eth_estimateGas',
        [
          {
            if (sender != null) 'from': sender,
            if (to != null) 'to': to,
            if (amountOfGas != null) 'gas': '0x${amountOfGas.toRadixString(16)}',
            if (gasPrice != null)
              'gasPrice': '0x${gasPrice.getInWei.toRadixString(16)}',
            if (maxPriorityFeePerGas != null)
              'maxPriorityFeePerGas':
              '0x${maxPriorityFeePerGas.getInWei.toRadixString(16)}',
            if (maxFeePerGas != null)
              'maxFeePerGas': '0x${maxFeePerGas.getInWei.toRadixString(16)}',
            if (value != null) 'value': '0x${value.getInWei.toRadixString(16)}',
            if (data != null) 'data': Formatter.bytesToHex(data, include0x: true),
          },
        ],
      );
      return Formatter.hexToInt(amountHex);
    } catch (err, trace) {
      print("ERROR: $err \n $trace");
      rethrow;
    }
  }

  /// Sends a raw method call to a smart contract.
  ///
  /// The connected node must be able to calculate the result locally, which
  /// means that the call can't write any data to the blockchain. Doing that
  /// would require a transaction which can be sent via [sendTransaction].
  /// As no data will be written, you can use the [sender] to specify any
  /// Ethereum address that would call that function. To use the address of a
  /// credential, call [Credentials.extractAddress].
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNumber.current] will be used.
  ///
  /// See also:
  /// - [call], which automatically encodes function parameters and parses a
  /// response.
  Future<String> callRaw({
    String? sender,
    required String contract,
    required Uint8List data,
    BlockNumber? atBlock,
  }) {
    final call = {
      'to': contract,
      'data': Formatter.bytesToHex(data, include0x: true, padToEvenLength: true),
      if (sender != null) 'from': sender,
    };

    return _makeRPCCall<String>('eth_call', [call, _getBlockParam(atBlock)]);
  }

  /// Listens for new blocks that are added to the chain. The stream will emit
  /// the hexadecimal hash of the block after it has been added.
  ///
  /// {@template web3dart:filter_streams_behavior}
  /// The stream can only be listened to once. The subscription must be disposed
  /// properly when no longer used. Failing to do so causes a memory leak in
  /// your application and uses unnecessary resources on the connected node.
  /// {@endtemplate}
  /// See also:
  /// - [hexToBytes] and [hexToInt], which can transform hex strings into a byte
  /// or integer representation.
  Stream<String> addedBlocks() {
    return _filters.addFilter(_NewBlockFilter());
  }

  /// Listens for pending transactions as they are received by the connected
  /// node. The stream will emit the hexadecimal hash of the pending
  /// transaction.
  ///
  /// {@macro web3dart:filter_streams_behavior}
  /// See also:
  /// - [hexToBytes] and [hexToInt], which can transform hex strings into a byte
  /// or integer representation.
  Stream<String> pendingTransactions() {
    return _filters.addFilter(_PendingTransactionsFilter());
  }

  /// Listens for logs emitted from transactions. The [options] can be used to
  /// apply additional filters.
  ///
  /// {@macro web3dart:filter_streams_behavior}
  /// See also:
  /// - https://solidity.readthedocs.io/en/develop/contracts.html#events, which
  /// explains more about how events are encoded.
  Stream<FilterEvent> events(FilterOptions options) {
    if (socketConnector != null) {
      // The real-time rpc nodes don't support listening to old data, so handle
      // that here.
      return Stream.fromFuture(getLogs(options))
          .expand((e) => e)
          .followedBy(_filters.addFilter(_EventFilter(options)));
    }

    return _filters.addFilter(_EventFilter(options));
  }

  /// Closes resources managed by this client, such as the optional background
  /// isolate for calculations and managed streams.
  Future<void> dispose() async {
    await _filters.dispose();
    await _streamRpcPeer?.close();
  }
}