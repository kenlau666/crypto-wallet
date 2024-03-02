import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/alchemy/alchemy.dart';
import 'bottom_app_bar.dart';

class SendTokensPage extends StatefulWidget {
  final String publicKey;
  final String privateKey;
  final String selectedNetwork;
  final Map<String, dynamic> allERC20Tokens;

  const SendTokensPage(
      {Key? key,
      required this.privateKey,
      required this.selectedNetwork,
      required this.publicKey,
      required this.allERC20Tokens})
      : super(key: key);

  @override
  State<SendTokensPage> createState() => _SendTokensPageState();
}

class _SendTokensPageState extends State<SendTokensPage> {
  final AlchemyRepository _alchemyRepository = AlchemyRepository();
  late WebSocketChannel channel;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<DropdownMenuEntry<String>> currencyNetworks =
      <DropdownMenuEntry<String>>[];
  late String selectedNetwork;

  final List<DropdownMenuEntry<String>> currencyTokens =
      <DropdownMenuEntry<String>>[];
  late String selectedTokens;

  @override
  void initState() {
    selectedNetwork = widget.selectedNetwork;
    _alchemyRepository.switchNetwork(network: selectedNetwork);
    selectedTokens = "ETH";
    currencyTokens.add(const DropdownMenuEntry<String>(
      value: "ETH",
      label: "ETH",
    ));
    for (var value in AcceptedNetworks.values) {
      currencyNetworks.add(DropdownMenuEntry<String>(
        value: value.name.toUpperCase(),
        label: value.value.toUpperCase(),
      ));
    }
    for (var entry in widget.allERC20Tokens.entries) {
      currencyTokens.add(DropdownMenuEntry<String>(
        value: entry.key,
        label: entry.key,
      ));
    }
    channel = _alchemyRepository.channel;
    channel.sink.add(jsonEncode({
      "jsonrpc": "2.0",
      "id": 0,
      "method": "eth_subscribe",
      "params": [
        "alchemy_minedTransactions",
        {
          "addresses": [
            {"from": widget.publicKey},
            {"to": widget.publicKey},
          ]
        }
      ]
    }));
    super.initState();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBarDAX(),
      appBar: AppBar(
        title: const Text('Send Tokens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Address',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16.0),
              DropdownMenu(
                dropdownMenuEntries: currencyTokens,
                label: const Text("Currency"),
                initialSelection: selectedTokens,
                onSelected: (String? currency) async {
                  setState(() {
                    selectedTokens = currency!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownMenu(
                dropdownMenuEntries: currencyNetworks,
                label: const Text("Network"),
                initialSelection: selectedNetwork,
                onSelected: (String? network) async {
                  await _alchemyRepository.switchNetwork(network: network!);
                  setState(() {
                    channel = _alchemyRepository.channel;
                    channel.sink.add(jsonEncode({
                      "jsonrpc": "2.0",
                      "id": 0,
                      "method": "eth_subscribe",
                      "params": [
                        "alchemy_minedTransactions",
                        {
                          "addresses": [
                            {"from": widget.publicKey},
                            {"to": widget.publicKey},
                          ]
                        }
                      ]
                    }));
                    selectedNetwork = network;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (selectedTokens == "ETH") {
                    String recipient = recipientController.text;
                    double amount = double.parse(amountController.text);
                    BigInt bigIntValue = BigInt.from(amount * pow(10, 18));
                    EtherAmount ethAmount =
                        EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
                    sendTransaction(recipient, ethAmount);
                  } else {
                    _alchemyRepository.transferERC20(
                        contractAddress: widget.allERC20Tokens[selectedTokens]
                            [0],
                        receiver: recipientController.text,
                        txValue: amountController.text,
                        privateKey: widget.privateKey);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sending"),
                    ),
                  );
                },
                child: const Text('Send'),
              ),
              StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    Map<String, dynamic> data = jsonDecode(snapshot.data);
                    if (data['method'] == "eth_subscription") {
                      final Uri _url = Uri.parse(
                          'https://sepolia.etherscan.io/tx/${data['params']['result']['transaction']['hash']}');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Successful Transaction'),
                              content:
                                  // 1 == 1
                                  //     ? const Text("a")
                                  //     :
                                  Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "From: ${data['params']['result']['transaction']['from']}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "To: ${data['params']['result']['transaction']['to']}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "value: ${BigInt.tryParse(data['params']['result']['transaction']['value'])!.toDouble() / 1000000000000000000} ether(s)"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (!await launchUrl(
                                        _url,
                                        mode: LaunchMode.externalApplication,
                                      )) {
                                        throw Exception(
                                            'Could not launch $_url');
                                      }
                                    },
                                    child:
                                        const Text("View details in Etherscan"),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "https://sepolia.etherscan.io/tx/${data['params']['result']['transaction']['hash']}"),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    channel.sink.add(jsonEncode({
                                      "jsonrpc": "2.0",
                                      "id": 0,
                                      "method": "eth_subscribe",
                                      "params": [
                                        "alchemy_minedTransactions",
                                        {
                                          "addresses": [
                                            {"from": widget.publicKey},
                                            {"to": widget.publicKey},
                                          ]
                                        }
                                      ]
                                    }));
                                    Navigator.pop(context, 'OK');
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendTransaction(String receiver, EtherAmount txValue) async {
    var apiUrl =
        "${dotenv.env[widget.selectedNetwork]}"; // Replace with your API
    // Replace with your API
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EthPrivateKey credentials = EthPrivateKey.fromHex(widget.privateKey);

    EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
    EtherAmount gasPrice = await ethClient.getGasPrice();

    print(etherAmount);

    await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: txValue,
      ),
      chainId: 11155111,
    );
  }
}
