import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/bottom_app_bar.dart';

class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBarDAX(),
      appBar: AppBar(
        title: const Text("Future extensions"),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Decentralized Identifiers'),
                      content: const Text(
                          "Developed by W3C. DID can be used for verification of anything without reliance on servers"),
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
              child: const Text("Decentralized Identifiers"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Lens Protocol'),
                      content: const Text(
                          "Lens Protocol provides a decentralized social graph that users totally own, giving them back control of their information and links and even providing features to monetize their content.\n\n"
                              "It helps create social media like functions and contact system in DAX."),
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
              child: const Text("Lens Protocol"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ERC-4337 Account Abstraction'),
                      content: const Text(
                          "Account Abstraction is a blend of external owned account (EOA) and contract account. It is meant to streamline setting up a wallet and make the user experience more like a bank\n\n"
                              "It helps build functions of account recovery, seamless wallet setup, bundled Transactions, pre-approved transactions and more."),
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
              child: const Text("ERC-4337 Account Abstraction"),
            ),
            // const SizedBox(height: 10,),
            // TextButton(
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text("Coming Soon"),
            //       ),
            //     );
            //     print("Showing ERC-6551 research result...");
            //   },
            //   child: const Text("ERC-6551 NFT Bound Accounts"),
            // ),
          ],
        ),
      ),
    );
  }
}
