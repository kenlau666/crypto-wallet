import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:web3dart/web3dart.dart';

import 'bottom_app_bar.dart';

class GetNFTURIPage extends StatelessWidget {
  final String privateKey;
  final String publicKey;
  final String selectedNetwork;
  final TextEditingController tokenIdController = TextEditingController();
  final EthereumAddress contractAddr =
      EthereumAddress.fromHex('0xb4Baa1DD10989B8F01Da7965249f8901E604a742');

  // final File abiFile = File('');

  GetNFTURIPage(
      {Key? key,
      required this.privateKey,
      required this.publicKey,
      required this.selectedNetwork})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBarDAX(),
      appBar: AppBar(
        title: const Text('Transfer AppNet NFT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: tokenIdController,
              decoration: const InputDecoration(
                labelText: 'Token ID',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String tokenId = tokenIdController.text;
                getNFTURI(tokenId);
              },
              child: const Text('Get URI'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getJson() async {
    final abiStringFile =
        await rootBundle.loadString('assets/contracts/mint_abi.json');
    // final jsonAbi = jsonDecode(abiStringFile);
    return abiStringFile;
  }

  void getNFTURI(String tokenId) async {
    int tokenID = int.tryParse(tokenId) ?? 9999999999999;
    var apiUrl = "${dotenv.env["SEPOLIA"]}";
    // Replace with your API
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    // read the contract abi and tell web3dart where it's deployed (contractAddr)
    final abiCode = await getJson();
    final contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'AppnetIdToken'), contractAddr);

    // extracting some functions and events that we'll need later
    final tokenURI = contract.function('tokenURI');

    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);

    var uri = await ethClient.call(
        contract: contract, function: tokenURI, params: [BigInt.from(tokenID)]);
    print(uri.first);
    // await ethClient.sendTransaction(
    //   credentials,
    //   Transaction.callContract(
    //     contract: contract,
    //     function: tokenURI,
    //     parameters: [BigInt.from(tokenID)],
    //   ),
    //   chainId: 11155111,
    // );
  }
}
