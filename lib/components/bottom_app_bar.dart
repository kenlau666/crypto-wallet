import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ecm2425_coursework/components/send_tokens.dart';
import 'package:ecm2425_coursework/domain/alchemy/alchemy.dart';
import 'package:ecm2425_coursework/pages/discovery_page.dart';
import 'package:ecm2425_coursework/pages/wallet.dart';
import 'package:web3dart/credentials.dart';

import '../features/transaction/view/transaction_records.dart';
import '../providers/wallet_provider.dart';

class BottomAppBarDAX extends StatefulWidget {
  final FloatingActionButtonLocation fabLocation;

  const BottomAppBarDAX({
    super.key,
    this.fabLocation = FloatingActionButtonLocation.endDocked,
  });

  @override
  State<BottomAppBarDAX> createState() => _BottomAppBarDAXState();
}

class _BottomAppBarDAXState extends State<BottomAppBarDAX> {
  final AlchemyRepository _alchemyRepository = AlchemyRepository();
  String publicKey = "";
  String privateKey = "";
  String selectedNetwork = "SEPOLIA";
  Map<String, dynamic> allERC20Tokens = {};

  @override
  void initState() {
    loadWalletData();
    super.initState();
  }

  Future<void> loadWalletData() async {
    final walletProvider = WalletProvider();
    await walletProvider.loadPrivateKey();
    EthereumAddress address =
        await walletProvider.getPublicKey(walletProvider.privateKey!);
    setState(() {
      publicKey = address.hex;
      privateKey = walletProvider.privateKey!;
    });
    await getAllERC20();
  }

  Future<void> getAllERC20() async {
    Map<String, dynamic> allERC20 =
        await _alchemyRepository.getERC20NameWithBalance(address: publicKey);
    setState(() {
      allERC20Tokens = allERC20;
    });
  }

  Future<void> getBalance() async {}

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.account_balance_wallet),
              tooltip: "Assets",
              iconSize: 35,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SendTokensPage(
                            privateKey: privateKey,
                            publicKey: publicKey,
                            selectedNetwork: selectedNetwork,
                            allERC20Tokens: allERC20Tokens,
                          )),
                );
              },
            ),
            //main button
            FloatingActionButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WalletPage()),
                  );
                },
                child: Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.white,
                )),
            // CircularFabWidget(),
            IconButton(
              icon: Icon(Icons.location_searching),
              tooltip: "Discover",
              iconSize: 35,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DiscoveryPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              tooltip: "Profile",
              iconSize: 35,
              onPressed: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => TransactionRecordPage()),
                // );
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Coming Soon'),
                      content: const Text("Personal Setting is coming soon"),
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
              },
            ),
          ],
        ));
  }
}
//
// class CircularFabWidget extends StatefulWidget {
//   const CircularFabWidget({super.key});
//
//   @override
//   State<CircularFabWidget> createState() => _CircularFabWidgetState();
// }
//
// class _CircularFabWidgetState extends State<CircularFabWidget> with SingleTickerProviderStateMixin{
//   late AnimationController controller;
//   @override
//   void initState() {
//     super.initState();
//     controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Flow(
//     delegate: FlowMenuDelegate(controller: controller),
//     children: <IconData>[
//       Icons.send,
//       Icons.add,
//       Icons.arrow_forward,
//     ].map<Widget>(buildFAB).toList(),
//   );
//
//   Widget buildFAB(IconData icon) => SizedBox(
//     width: 35,
//     height: 35,
//     child:   FloatingActionButton(onPressed: () {
//       if (controller.status == AnimationStatus.completed) {
//         controller.reverse();
//       } else {
//         controller.forward();
//       }
//     },
//         splashColor: Colors.grey,
//         child: Icon(icon, color: Colors.white, size: 45)),
//   );
// }
//
// class FlowMenuDelegate extends FlowDelegate {
//   final Animation<double> controller;
//   const FlowMenuDelegate({required this.controller}) : super(repaint: controller);
//   @override
//   void paintChildren(FlowPaintingContext context) {
//     final size = context.size;
//     final xStart = size.width - buttonSize;
//     final yStart = size.height - buttonSize;
//
//     final n = context.childCount;
//     for (int i = 0; i < n; i++) {
//       final isLastItem = i == context.childCount - 1;
//       final setValue = (value) => isLastItem ? 0.0 : value;
//       final radius =  180 * controller.value;
//       final theta = i * pi * 0.5 / (n-2);
//       final x = xStart - setValue(radius*cos(theta));
//       final y = yStart - setValue(radius*sin(theta));
//       context.paintChild(i,
//           transform: Matrix4.identity()
//             ..translate(x,y,0)
//             ..translate(buttonSize / 2, buttonSize / 2)
//           ..rotateZ(isLastItem ? 0.0: 180* (1-controller.value) * pi / 180)
//             ..scale(isLastItem ? 1.0: max(controller.value, 0.5))
//           ..translate(-buttonSize / 2, -buttonSize / 2),
//       );
//     }
//
//   }
//   @override
//   bool shouldRepaint(FlowMenuDelegate oldDelegate) => false;
// }
