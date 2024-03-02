import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecm2425_coursework/components/buttons.dart';
import 'package:ecm2425_coursework/pages/wallet_credentials_questionnare_page.dart';
import 'package:ecm2425_coursework/providers/wallet_provider.dart';
import 'package:ecm2425_coursework/pages/create_or_import.dart';
import 'package:web3dart/web3dart.dart';
import 'package:ecm2425_coursework/utils/get_balances.dart';
import 'package:ecm2425_coursework/components/nft_balances.dart';
import 'package:ecm2425_coursework/components/send_tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../components/bottom_app_bar.dart';
import '../components/get_nft_uri.dart';
import '../domain/alchemy/alchemy.dart';
import '../features/transaction/view/transaction_records.dart';
import 'discovery_page.dart';

List<Map<String, int>> blockchainList = [
  {'Mainnet': 1},
  {'Binance Smart Chain': 56},
  {'Polygon': 137},
  {'Fantom': 250},
  {'Avalanche': 43114},
  {'Harmony': 1666600000},
  {'Huobi Eco Chain': 128},
  {'Sepolia': 11155111},
  {'Goerli': 5},
];

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {

  final AlchemyRepository _alchemyRepository = AlchemyRepository();
  late WebSocketChannel channel;
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
  String currentNetwork = '-';
  Map<String, dynamic> allERC20Tokens = {};
  late String selectedNetwork;
  late String apiUrl;

  // AcceptedNetworks switchNetwork = AcceptedNetworks.sepolia;
  final List<DropdownMenuEntry<String>> currencyNetworks =
      <DropdownMenuEntry<String>>[];

  @override
  void initState() {
    channel = _alchemyRepository.channel;
    for (var value in AcceptedNetworks.values) {
      currencyNetworks.add(DropdownMenuEntry<String>(
        value: value.name.toUpperCase(),
        label: value.value.toUpperCase(),
      ));
    }
    selectedNetwork = AcceptedNetworks.values.first.name.toUpperCase();
    apiUrl = "${dotenv.env[selectedNetwork]}";
    loadWalletData();
    super.initState();
  }

  Future<void> loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);
      channel.sink.add(jsonEncode({
        "jsonrpc": "2.0",
        "id": 0,
        "method": "eth_subscribe",
        "params": [
          "alchemy_minedTransactions",
          {
            "addresses": [
              {"from": address.hex},
              {"to": address.hex},
            ]
          }
        ]
      }));
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });
      var httpClient = http.Client();
      var ethClient = Web3Client(apiUrl, httpClient);
      EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
      EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
      int chainId = await ethClient.getNetworkId();
      setState(() {
        balance = (etherAmount.getInWei.toDouble() / 1000000000000000000)
            .toStringAsPrecision(4)
            .substring(0, 5);
        for (int i = 0; i < blockchainList.length; ++i) {
          for (var chain in blockchainList[i].entries) {
            if (chain.value == chainId) {
              currentNetwork = chain.key;
              break;
            }
          }
        }
      });
    }
    await getAllERC20();
  }

  Future<void> getAllERC20() async {
    Map<String, dynamic> allERC20 = await _alchemyRepository
        .getERC20NameWithBalance(address: walletAddress);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("tokens", json.encode(allERC20));
    setState(() {
      allERC20Tokens = allERC20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuildProfile(),
          Divider(
            color: Colors.white.withOpacity(0.5),
            thickness: 0.5.sp,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Network:",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownMenu(
                          dropdownMenuEntries: currencyNetworks,
                          label: const Text("Network"),
                          initialSelection: selectedNetwork,
                          onSelected: (String? network) async {
                            await _alchemyRepository.switchNetwork(
                                network: network!);
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
                                      {"from": walletAddress},
                                      {"to": walletAddress},
                                    ]
                                  }
                                ]
                              }));
                              selectedNetwork = network!;
                              apiUrl = "${dotenv.env[selectedNetwork]}";
                              allERC20Tokens = {};

                              loadWalletData();
                            });
                          },
                        )
                      ]),
                  SizedBox(width: 24.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    wallet_credentials_questionnare_page()));
                      },
                      child: Text("Show keyprhase &\nprivate key"))
                ],
              ),
              // const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text(
              //       'Balance:',
              //       style: TextStyle(
              //         fontSize: 24.0,
              //         fontWeight: FontWeight.bold,
              //       ),
              //       textAlign: TextAlign.center,
              //     ),
              //     const SizedBox(
              //       width: 10,
              //     ),
              //     Text(
              //       balance,
              //       style: const TextStyle(
              //         fontSize: 20.0,
              //       ),
              //       textAlign: TextAlign.center,
              //     ),
              //   ],
              // ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Column(
          //       children: [
          //         FloatingActionButton(
          //           heroTag: 'sendButton', // Unique tag for send button
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => SendTokensPage(
          //                         privateKey: pvKey,
          //                         selectedNetwork: selectedNetwork,
          //                         publicKey: walletAddress,
          //                         allERC20Tokens: allERC20Tokens,
          //                       )),
          //             );
          //           },
          //           child: const Icon(Icons.send),
          //         ),
          //         const SizedBox(height: 8.0),
          //         const Text('Send'),
          //       ],
          //     ),
          //     if (mintedAppNetId == '')
          //       Column(
          //         children: [
          //           FloatingActionButton(
          //             heroTag: 'mintButton', // Unique tag for send button
          //             onPressed: mintedAppNetId != ''
          //                 ? null
          //                 : () {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                           builder: (context) => MintNFTPage(
          //                                 privateKey: pvKey,
          //                                 publicKey: walletAddress,
          //                                 selectedNetwork: selectedNetwork,
          //                                 appNetId: appNetId,
          //                               )),
          //                     );
          //                   },
          //             child: const Icon(Icons.add),
          //           ),
          //           const SizedBox(height: 8.0),
          //           const Text('Mint'),
          //         ],
          //       ),
          //     if (mintedAppNetId != '')
          //       Column(
          //         children: [
          //           FloatingActionButton(
          //             heroTag: 'transferNFTButton',
          //             // Unique tag for send button
          //             onPressed: mintedAppNetId == ''
          //                 ? null
          //                 : () {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                           builder: (context) => TransferNFTPage(
          //                                 privateKey: pvKey,
          //                                 publicKey: walletAddress,
          //                                 selectedNetwork: selectedNetwork,
          //                               )),
          //                     );
          //                   },
          //             child: const Icon(Icons.arrow_forward),
          //           ),
          //           const SizedBox(height: 8.0),
          //           const Text('Send NFT'),
          //         ],
          //       ),
          //     // Column(
          //     //   children: [
          //     //     FloatingActionButton(
          //     //       heroTag: 'getNFTURIButton', // Unique tag for send button
          //     //       onPressed: () {
          //     //         Navigator.push(
          //     //           context,
          //     //           MaterialPageRoute(
          //     //               builder: (context) => GetNFTURIPage(
          //     //                     privateKey: pvKey,
          //     //                     publicKey: walletAddress,
          //     //                     selectedNetwork: selectedNetwork,
          //     //                   )),
          //     //         );
          //     //       },
          //     //       child: const Icon(Icons.get_app),
          //     //     ),
          //     //     const SizedBox(height: 8.0),
          //     //     const Text('NFT URI'),
          //     //   ],
          //     // ),
          //     if (mintedAppNetId != '')
          //       Column(
          //         children: [
          //           FloatingActionButton(
          //             heroTag: 'startMessage', // Unique tag for send button
          //             onPressed: mintedAppNetId == ''
          //                 ? null
          //                 : () {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                           builder: (context) => StartMessage(
          //                                 privateKey: pvKey,
          //                                 publicKey: walletAddress,
          //                                 selectedNetwork: selectedNetwork,
          //                                 allERC20Tokens: allERC20Tokens,
          //                               )),
          //                     );
          //                   },
          //             child: const Icon(Icons.message),
          //           ),
          //           const SizedBox(height: 8.0),
          //           const Text('Message'),
          //         ],
          //       ),
          //     Column(
          //       children: [
          //         FloatingActionButton(
          //           heroTag: 'refreshButton', // Unique tag for send button
          //           onPressed: () async {
          //             await searchAppNetPassPort();
          //           },
          //           child: const Icon(Icons.replay_outlined),
          //         ),
          //         const SizedBox(height: 8.0),
          //         const Text('Refresh'),
          //       ],
          //     ),
          //     Column(
          //       children: [
          //         FloatingActionButton(
          //           heroTag: 'developerButton', // Unique tag for send button
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => DeveloperPage(
          //                         publicKey: walletAddress,
          //                         privateKey: pvKey,
          //                       )),
          //             );
          //           },
          //           child: const Icon(Icons.developer_board),
          //         ),
          //         const SizedBox(height: 8.0),
          //         const Text('Develop'),
          //       ],
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 30.0),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Assets'),
                      Tab(text: 'NFTs'),
                      Tab(text: 'Options'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Assets Tab
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.all(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${currentNetwork[0].toUpperCase()}${currentNetwork.substring(1).toLowerCase()} ETH",
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        balance,
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              for (var entry in allERC20Tokens.entries) ...[
                                Card(
                                  margin: const EdgeInsets.all(10.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          entry.value[1].toString().substring(
                                              0,
                                              entry.value[1].toString().length -
                                                  2),
                                          style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // NFTs Tab
                        SingleChildScrollView(
                            child: NFTListPage(
                                address: walletAddress, chain: currentNetwork)),
                        // Activities Tab
                        SingleChildScrollView(
                          child: Center(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.money),
                                  title: const Text("Get ETH"),
                                  onTap: () async {
                                    if (double.tryParse(balance)! < 0.001) {
                                      await _alchemyRepository.sendTransaction(
                                          receiver: walletAddress,
                                          privateKey:
                                              dotenv.env["SAMPLE_PRIVATE_KEY"]!,
                                          txValue: '0.001');
                                      // mintAppNetNFT();
                                    } else {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Not Eligible'),
                                            content: Text(
                                                "You have $balance ETH inside your wallet"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.search),
                                  title: Text("Discover"),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DiscoveryPage()));
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout),
                                  title: const Text('Logout'),
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('privateKey');
                                    await prefs.remove('tokens');
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateOrImportPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                ),
                                // ListTile(
                                //   leading: const Icon(Icons.developer_board),
                                //   title: const Text("Develop"),
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => DeveloperPage(
                                //                 publicKey: walletAddress,
                                //                 privateKey: pvKey,
                                //               )),
                                //     );
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                                    throw Exception('Could not launch $_url');
                                  }
                                },
                                child: const Text("View details in Etherscan"),
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
                                        {"from": walletAddress},
                                        {"to": walletAddress},
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
      bottomNavigationBar: BottomAppBarDAX(),
    );
  }

  Widget BuildProfile() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0.sp, 16.sp, 16.sp, 10.sp),
      margin: EdgeInsets.fromLTRB(0, 5.sp, 0, 10.sp),
      child: Row(
        children: [
          //icon
          Container(
            margin: EdgeInsets.only(right: 20.sp),
            child: Icon(
              Icons.account_circle,
              size: 50.sp,
            ),
          ),
          //columns
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // title NEED TO CHANGE
                'Wallet Address',
                style: TextStyle(
                  fontSize: 20.0.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(
                width: 250.sp,
                child: SelectableText(
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  walletAddress,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0.sp,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
