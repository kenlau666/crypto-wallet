import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecm2425_coursework/providers/wallet_provider.dart';
import 'package:ecm2425_coursework/pages/wallet.dart';

class ImportPrivateKey extends StatefulWidget {
  const ImportPrivateKey({Key? key}) : super(key: key);

  @override
  _ImportPrivateKeyState createState() => _ImportPrivateKeyState();
}

class _ImportPrivateKeyState extends State<ImportPrivateKey> {
  bool isVerified = false;
  final TextEditingController importedPrivateKeyController = TextEditingController();
  void navigateToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    void verifyMnemonic() async {
      final walletProvider =
      Provider.of<WalletProvider>(context, listen: false);

      // Call the getPrivateKey function from the WalletProvider
      final privateKey = await walletProvider.setPrivateKey(importedPrivateKeyController.text);

      // Navigate to the WalletPage
      navigateToWalletPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Private Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please Enter your private key:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 24.0),
            TextField(
         controller: importedPrivateKeyController,
              decoration: const InputDecoration(
                labelText: 'Enter private key',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: verifyMnemonic,
              child: const Text('Import'),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
