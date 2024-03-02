import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum AcceptedNetworks {
  sepolia("Sepolia"),
  goerli("Goerli"),
  ethereum("Mainnet");

  const AcceptedNetworks(this.value);

  final String value;
}

Map<String, int> networkToChainId = {
  "SEPOLIA": 11155111,
  "GOERLI": 5,
  "ETHEREUM": 1
};

class AlchemyRepository {
  final String _loggerPrefix = "AlchemyRepo";
  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(dotenv.env["SEPOLIA_WEBSOCKET"]!),
  );

  String networkApiKey = dotenv.env["SEPOLIA"]!;
  int chainId = 11155111;

  Future<void> switchNetwork({required String network}) async {
    final String loggerName = "$_loggerPrefix.switchNetwork";
    try {
      networkApiKey = dotenv.env[network]!;
      channel = WebSocketChannel.connect(
        Uri.parse(dotenv.env["${network}_WEBSOCKET"]!),
      );
      chainId = networkToChainId[network]!;
      log("Alchemy.switchNetwork(network: $network)", name: loggerName);
    } catch (e) {
      log("Invalid Network: $network", name: loggerName);
    }
  }

  Future<List<dynamic>> loadNFTList({required String address}) async {
    final String loggerName = "$_loggerPrefix.loadNFTList";
    List<dynamic> nftList;
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env["SEPOLIA"]}/getNFTs/?owner=$address"),
      );
      log("Alchemy.nft.getNftsForOwner(address: $address)", name: loggerName);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        nftList = jsonData['ownedNfts'];
        log("returned nft list length: ${nftList.length}", name: loggerName);
        return nftList;
      } else {
        throw Exception('Failed to load NFT list');
      }
    } catch (e) {
      log("Alchemy.nft.getNftsForOwner(address: $address) return an error",
          name: loggerName);
      return [];
    }
  }

  Future<String> sendTransaction(
      {required String receiver,
      required String txValue,
      required String privateKey}) async {
    final String loggerName = "$_loggerPrefix.sendTransaction";
    double amount = double.parse(txValue);
    BigInt bigIntValue = BigInt.from(amount * math.pow(10, 18));
    EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
    var apiUrl = networkApiKey;
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);

    try {
      log("AlchemySDK.sendTransaction(receiver:$receiver, txValue:$txValue, privateKey:$privateKey)",
          name: loggerName);

      http.Response respFeeHistory = await http.post(
        Uri.parse(
            "https://eth-sepolia.g.alchemy.com/v2/B-sCeel_s5mL6N6BDJdY4GMpSUB6glaA"),
        headers: <String, String>{
          "accept": "application/json",
          "content-type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "jsonrpc": "2.0",
          "method": "eth_feeHistory",
          "params": [
            1,
            "latest",
            [25, 50, 75]
          ],
          "id": 1
        }),
      );

      final Map<String, dynamic> decodedRespFeeHistory =
          jsonDecode(respFeeHistory.body);
      BigInt maxPriorityFeePerGas =
          BigInt.parse(decodedRespFeeHistory['result']['reward'][0][1]);
      BigInt baseFeePerGas =
          BigInt.parse(decodedRespFeeHistory['result']['baseFeePerGas'][1]);

      String txHash = await ethClient.sendTransaction(
        credentials,
        Transaction(
          to: EthereumAddress.fromHex(receiver),
          maxPriorityFeePerGas:
              EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas),
          maxFeePerGas: EtherAmount.fromBigInt(
              EtherUnit.wei, maxPriorityFeePerGas + baseFeePerGas),
          value: ethAmount,
        ),
        chainId: chainId,
      );
      log("Transaction Hash: $txHash", name: loggerName);
      await ethClient.dispose();
      return txHash;
    } catch (e) {
      log("AlchemySDK.sendTransaction(receiver:$receiver, txValue:$txValue, privateKey:$privateKey) returns an error",
          name: loggerName);
      await ethClient.dispose();
      return "";
    }
  }

  Future<String> getJson() async {
    final abiStringFile =
        await rootBundle.loadString('assets/contracts/mint_abi.json');
    // final jsonAbi = jsonDecode(abiStringFile);
    return abiStringFile;
  }

  Future<http.Response> getERC20BalanceResponse({required String address}) {
    return http.post(
      Uri.parse(networkApiKey),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "method": "alchemy_getTokenBalances",
        "params": [
          address,
        ],
        "id": 1
      }),
    );
  }

  Future<List<dynamic>> getERC20Balance({required String address}) async {
    final String loggerName = "$_loggerPrefix.getERC20Balance";
    log("AlchemySDK.getERC20Balance(address: $address)", name: loggerName);
    http.Response resp = await getERC20BalanceResponse(address: address);
    final Map<String, dynamic> decodedResp = await jsonDecode(resp.body);
    final List<dynamic> balances = decodedResp['result']['tokenBalances'];
    return balances;
  }

  Future<http.Response> getERC20MetadataResponse({required String address}) {
    return http.post(
      Uri.parse(networkApiKey),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "jsonrpc": "2.0",
        "method": "alchemy_getTokenMetadata",
        "params": [address],
        "id": 1
      }),
    );
  }

  Future<Map<String, dynamic>> getERC20Metadata(
      {required String address}) async {
    final String loggerName = "$_loggerPrefix.getERC20Metadata";
    log("AlchemySDK.getERC20Metadata(address: $address)", name: loggerName);
    http.Response resp = await getERC20MetadataResponse(address: address);
    final Map<String, dynamic> decodedResp = jsonDecode(resp.body);
    final String name = decodedResp['result']['name'];
    final int decimal = decodedResp['result']['decimals'] ?? 0;
    return {"name": name, "decimal": decimal};
  }

  Future<Map<String, dynamic>> getERC20NameWithBalance(
      {required String address}) async {
    Map<String, dynamic> allERC20 = {};
    final String loggerName = "$_loggerPrefix.getERC20NameWithBalance";
    log("AlchemySDK.getERC20NameWithBalance()", name: loggerName);
    List<dynamic> balances = await getERC20Balance(address: address);
    for (int i = 0; i < balances.length; ++i) {
      Map<String, dynamic> metadata =
          await getERC20Metadata(address: balances[i]['contractAddress']);
      String name = metadata['name'];
      int decimal = metadata['decimal'];
      allERC20[name] = [
        balances[i]['contractAddress'],
        BigInt.tryParse(balances[i]['tokenBalance'])!.toDouble() /
            math.pow(10, decimal),
      ];
    }
    return allERC20;
  }

  Future<String> transferERC20(
      {required String contractAddress,
      required String receiver,
      required String txValue,
      required String privateKey}) async {
    Map<String, dynamic> metadata =
        await getERC20Metadata(address: contractAddress);
    int decimal = metadata['decimal'];
    final String loggerName = "$_loggerPrefix.transferERC20";
    final EthereumAddress contractAddr =
        EthereumAddress.fromHex(contractAddress);
    var apiUrl = "${dotenv.env["SEPOLIA"]}";
    var httpClient = http.Client();

    var ethClient = Web3Client(apiUrl, httpClient);

    final _erc20ContractAbi = ContractAbi.fromJson(
        '[{"inputs":[{"internalType":"string","name":"name_","type":"string"},{"internalType":"string","name":"symbol_","type":"string"},{"internalType":"uint8","name":"decimals_","type":"uint8"},{"internalType":"uint256","name":"initialBalance_","type":"uint256"},{"internalType":"address payable","name":"feeReceiver_","type":"address"}],"stateMutability":"payable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]',
        'ERC20');
    final contract = DeployedContract(_erc20ContractAbi, contractAddr);
    final transfer = contract.function('transfer');

    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    try {
      log("AlchemySDK.transferERC20(contractAddress: $contractAddress, privateKey:$privateKey, receiver:$receiver, txValue:$txValue)",
          name: loggerName);

      http.Response respFeeHistory = await http.post(
        Uri.parse(
            "https://eth-sepolia.g.alchemy.com/v2/B-sCeel_s5mL6N6BDJdY4GMpSUB6glaA"),
        headers: <String, String>{
          "accept": "application/json",
          "content-type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "jsonrpc": "2.0",
          "method": "eth_feeHistory",
          "params": [
            1,
            "latest",
            [25, 50, 75]
          ],
          "id": 1
        }),
      );

      final Map<String, dynamic> decodedRespFeeHistory =
          jsonDecode(respFeeHistory.body);
      BigInt maxPriorityFeePerGas =
          BigInt.parse(decodedRespFeeHistory['result']['reward'][0][1]);
      BigInt baseFeePerGas =
          BigInt.parse(decodedRespFeeHistory['result']['baseFeePerGas'][1]);

      String txHash = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          maxPriorityFeePerGas:
              EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas),
          maxFeePerGas: EtherAmount.fromBigInt(
              EtherUnit.wei, maxPriorityFeePerGas + baseFeePerGas),
          contract: contract,
          function: transfer,
          parameters: [
            EthereumAddress.fromHex(receiver),
            BigInt.from(double.tryParse(txValue)! * math.pow(10, decimal))
          ],
        ),
        chainId: chainId,
      );
      print(txHash);
      await ethClient.dispose();
      return txHash;
    } catch (e) {
      log(e.toString());
      log("AlchemySDK.transferERC20(contractAddress:$contractAddress, transferNFT:$receiver, txValue:$txValue) returns an error",
          name: loggerName);
      await ethClient.dispose();
      return "";
    }
  }
}
