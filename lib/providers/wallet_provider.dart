import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/foundation.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:web3dart/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bip32/bip32.dart' as bip32;

abstract class WalletAddressService {
  String generateMnemonic();
  Future<String> getPrivateKey(String mnemonic);
  Future<EthereumAddress> getPublicKey(String privateKey);
}

class WalletProvider extends ChangeNotifier implements WalletAddressService {
  // Variable to store the private key
  String? privateKey;

  // Load the private key from the shared preferences
  Future<void> loadPrivateKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    privateKey = prefs.getString('privateKey');
  }

  // set the private key in the shared preferences
  Future<void> setPrivateKey(String privateKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('privateKey', privateKey);
    this.privateKey = privateKey;
    notifyListeners();
  }

  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  Future<String> getPrivateKey(String mnemonic) async {
    String hdPath = "m/44'/60'/0'/0";
    final isValidMnemonic = bip39.validateMnemonic(mnemonic);
    if (!isValidMnemonic) {
      throw 'Invalid mnemonic';
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);

    const first = 0;
    final firstChild = root.derivePath("$hdPath/$first");
    final privateKey = "0x${HEX.encode(firstChild.privateKey as List<int>)}";
    await setPrivateKey(privateKey);
    return privateKey;

    // final seed = bip39.mnemonicToSeed(mnemonic);
    // final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    // final privateKey = HEX.encode(master.key);
    // await setPrivateKey(privateKey);
    // return privateKey;

    // final seed = bip39.mnemonicToSeed(mnemonic);
    // final root = bip32.BIP32.fromSeed(seed);
    // final child1 = root.derivePath("m/44'/60'/0'/0/0");
    // return bytesToHex(child1.publicKey.toList());
  }

  @override
  Future<EthereumAddress> getPublicKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.address;
    return address;
  }
}
