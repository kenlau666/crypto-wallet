import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../../../domain/alchemy/alchemy.dart';
import '../model/transaction.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({
    required AlchemyRepository alchemyRepository,
    required String privateKey,
  })  : _alchemyRepository = alchemyRepository,
        _privateKey = privateKey,
        super(TransactionState());

  final AlchemyRepository _alchemyRepository;
  final String _privateKey;
  late EthPrivateKey credentials;

  late WebSocketChannel channel;
  late String publicKey;

  void init() {
    credentials = EthPrivateKey.fromHex(_privateKey);
  }

  void initializeWebSocket(
      {required String privateKey, required String publicKey}) async {
    init();
    await signTransaction();
    await getAssetsTransfer();
    privateKey = privateKey;
    publicKey = publicKey;
    channel = _alchemyRepository.channel;
    channel.sink.add(jsonEncode({
      "jsonrpc": "2.0",
      "id": 0,
      "method": "eth_subscribe",
      "params": [
        "alchemy_minedTransactions",
        {
          "addresses": [
            {"from": publicKey},
            {"to": publicKey},
          ]
        }
      ]
    }));
    channel.stream.listen((message) {
      var data = jsonDecode(message);
      if (data['method'] == "eth_subscription") {
        emit(state.copyWith(
          status: TransactionStatus.minting,
        ));
        Map<String, TransactionDetail> currentTransactionRecord =
            Map.from(state.transactions);
        bool isIn = data['params']['result']['transaction']['to']
                .toString()
                .toUpperCase() ==
            publicKey.toUpperCase();
        String address = isIn
            ? data['params']['result']['transaction']['from']
            : data['params']['result']['transaction']['to'];
        String txHash = data['params']['result']['transaction']['hash'];
        String txValue =
            (BigInt.tryParse(data['params']['result']['transaction']['value'])!
                        .toDouble() /
                    1000000000000000000)
                .toStringAsPrecision(4)
                .substring(0, 5);
        DateTime timestamp = DateTime.now();
        String operation = "Transaction"; //@todo
        bool isPending = false;
        bool isSuccess = true;
        String remark = "aaa";
        currentTransactionRecord[data['params']['result']['transaction']
                ['hash']] =
            TransactionDetail(
                isIn: isIn,
                address: address,
                txHash: txHash,
                txValue: txValue,
                timestamp: timestamp,
                operation: operation,
                isPending: isPending,
                isSuccess: isSuccess,
                remark: remark);
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: currentTransactionRecord,
        ));
      }
    });
  }

  void closeWebSocket() async {
    channel.sink.close();
  }

  Future<String> signTransaction() async {
    var httpClient = http.Client();
    var ethClient = Web3Client(
        "https://eth-sepolia.g.alchemy.com/v2/B-sCeel_s5mL6N6BDJdY4GMpSUB6glaA",
        httpClient);
    double amount = double.parse("0.001");
    BigInt bigIntValue = BigInt.from(amount * math.pow(10, 18));
    EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);

    // http.Response respMaxPriorityFeePerGas = await http.post(
    //   Uri.parse(
    //       "https://eth-sepolia.g.alchemy.com/v2/B-sCeel_s5mL6N6BDJdY4GMpSUB6glaA"),
    //   headers: <String, String>{
    //     "accept": "application/json",
    //     "content-type": "application/json"
    //   },
    //   body: jsonEncode(<String, dynamic>{
    //     "id": 1,
    //     "jsonrpc": "2.0",
    //     "method": "eth_maxPriorityFeePerGas"
    //   }),
    // );

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

    // final Map<String, dynamic> decodedRespMaxPriorityFeePerGas =
    //     jsonDecode(respMaxPriorityFeePerGas.body);
    final Map<String, dynamic> decodedRespFeeHistory =
        jsonDecode(respFeeHistory.body);

    BigInt maxPriorityFeePerGas =
        BigInt.parse(decodedRespFeeHistory['result']['reward'][0][1]);
    BigInt baseFeePerGas =
        BigInt.parse(decodedRespFeeHistory['result']['baseFeePerGas'][1]);

    Transaction transaction = Transaction(
      to: EthereumAddress.fromHex("0x620342996E4f01f17995759e8bdd2A687612F702"),
      value: ethAmount,
      maxPriorityFeePerGas:
          EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas),
      maxFeePerGas: EtherAmount.fromBigInt(
          EtherUnit.wei, maxPriorityFeePerGas + baseFeePerGas),
    );

    String txHash = await ethClient.sendTransaction(
      credentials,
      transaction,
      chainId: 11155111,
    );

    print(txHash);

    // Uint8List signedTransaction =
    //     await ethClient.signTransaction(credentials, transaction);
    // String signedTransactionHex =
    //     bytesToHex(signedTransaction, include0x: true, padToEvenLength: true);

    return "";
  }

  Future<void> getAssetsTransfer() async{
    http.Response resp = await http.post(
      Uri.parse(
          "https://eth-sepolia.g.alchemy.com/v2/B-sCeel_s5mL6N6BDJdY4GMpSUB6glaA"),
      headers: <String, String>{
        "accept": "application/json",
        "content-type": "application/json"
      },
      body: jsonEncode(<String, dynamic>{
        "id": 1,
        "jsonrpc": "2.0",
        "method": "alchemy_getAssetTransfers",
        "params": [
          {
            "fromBlock": "0x0",
            "toBlock": "latest",
            "fromAddress": "0x123d551F438D6921BD92d7a82610a33861b075d2",
            "category": ["external", "internal", "erc20", "erc721"],
            "withMetadata": true,
            "excludeZeroValue": true,
            "maxCount": "0x3e8"
          }
        ]
      }),
    );

    print(resp.body);
  }

  void sendTransaction() async {
    emit(state.copyWith(
      status: TransactionStatus.pending,
    ));

    try {
      //todo
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          errorMessage: "",
        ),
      );
    } catch (e, stacktrace) {
      debugPrint("$e: \n$stacktrace");

      emit(state.copyWith(
        status: TransactionStatus.failure,
      ));
    }
  }

  void receiveTransaction() async {
    emit(state.copyWith(
      status: TransactionStatus.pending,
    ));

    try {
      //todo
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          errorMessage: "",
        ),
      );
    } catch (e, stacktrace) {
      debugPrint("$e: \n$stacktrace");

      emit(state.copyWith(
        status: TransactionStatus.failure,
      ));
    }
  }
}
