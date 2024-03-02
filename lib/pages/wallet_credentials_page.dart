import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/bottom_app_bar.dart';

class wallet_credentials_page extends StatelessWidget {
  late final mnemonic;
  late final privateKey;

  wallet_credentials_page({required this.mnemonic, required this.privateKey});

  @override
  Widget build(BuildContext context) {
    final mnemonicList = mnemonic.toString().split(' ');

    return Scaffold(
      bottomNavigationBar: BottomAppBarDAX(),
      appBar: AppBar(
        title: Text("Never Share These!"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Private Key: $privateKey"),
            SizedBox(height: 20.0,),
            Text("Key-Phrase:",style: TextStyle(fontWeight:FontWeight.bold ),),
            Column(
              children: List.generate(
                  mnemonicList.length,
                  (index) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("$index. ${mnemonicList[index]}"),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
