// authmodel.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchInstitutData() async {
  String apiUrl = 'http://localhost:8000/client/get_Institut/';
  try {
    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept-Charset': 'utf-8',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      print('Failed to load the data: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error loading the data: $e');
    return [];
  }
}
