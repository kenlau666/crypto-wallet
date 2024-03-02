import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecm2425_coursework/pages/wallet_credentials_page.dart';

import '../components/bottom_app_bar.dart';

class wallet_credentials_questionnare_page extends StatefulWidget {
  @override
  State<wallet_credentials_questionnare_page> createState() =>
      _wallet_credentials_questionnare_pageState();
}

class _wallet_credentials_questionnare_pageState
    extends State<wallet_credentials_questionnare_page> {
  bool match=false;

  @override
  Widget build(BuildContext context) {
    void navigateToWalletCredential() async{
      var sharedPreference = await SharedPreferences.getInstance();
      var mnemonic = await sharedPreference.getString("mnemonic");
      var pvKey = await sharedPreference.getString("privateKey");
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>wallet_credentials_page(mnemonic: mnemonic,privateKey: pvKey)));
    }

    const password = "666";
    var input="";


    return Scaffold(
      bottomNavigationBar: BottomAppBarDAX(),
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text("Please enter the password: 666"),
            TextField(onChanged: (value){
              setState(() {
                input = value;
                if(input==password){
                  match=true;
                }
                else{
                  match=false;
                }
              });
            },),
            ElevatedButton(onPressed: match? navigateToWalletCredential:null, child: Text("Proceed"))
          ],
        ),
      ),
    );
  }
}
