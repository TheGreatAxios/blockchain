import 'package:blockchain/contracts/abi/abi.dart';
import 'package:blockchain/contracts/ethereum_contract.dart';

class EthereumContractBuilder {
  static EthereumContract buildContract(String address, String json, String name) {
    final ContractAbi abi = ContractAbi.fromJson(json, name);
    return EthereumContract(address: address, abi: abi);
  }
}