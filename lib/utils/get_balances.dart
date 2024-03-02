import 'dart:developer';

import 'package:http/http.dart' as http;

Future<String> getBalances(String address, String chain) async {
  final url = Uri.http('192.168.100.47:5002', '/get_token_balance', {
    'address': address,
    'chain': chain,
  });

  final response = await http.get(url);
  if (response.statusCode == 200) {
    log("AAAAAAAAAAAA");
    log(response.body);
    return response.body;
  } else {
    throw Exception('Failed to get balances');
  }
}
