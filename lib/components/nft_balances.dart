import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NFTListPage extends StatefulWidget {
  final String address;
  final String chain;

  const NFTListPage({
    Key? key,
    required this.address,
    required this.chain,
  }) : super(key: key);

  @override
  _NFTListPageState createState() => _NFTListPageState();
}

class _NFTListPageState extends State<NFTListPage> {
  List<dynamic> _nftList = [];

  @override
  void initState() {
    super.initState();
    _loadNFTList();
  }

  Future<void> _loadNFTList() async {
    final response = await http.get(
      Uri.parse("${dotenv.env["SEPOLIA"]}/getNFTs/?owner=${widget.address}"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _nftList = jsonData['ownedNfts'];
      });
    } else {
      throw Exception('Failed to load NFT list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Number of NFT(s): ${_nftList.length}"),
        const SizedBox(height: 10,),
        for (var nft in _nftList)
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${nft['id']['tokenMetadata']['tokenType']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 150, // adjust the height as needed
                  child: nft['tokenUri']['gateway'] != ""
                      ? Image.network(
                          nft['tokenUri']['gateway'],
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Text('Image'),
                        ),
                ),
                Text(
                  "${nft['contractMetadata']['name']}: ${BigInt.tryParse(nft['id']['tokenId'])}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
