// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> fetchInstitutData() async {
    String apiUrl = 'http://192.168.1.22:8000/client/get_Institut/';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load the data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading the data: $e');
    }
  }

  static Future<bool> checkIpAddressAllowed(String publicIpAddress) async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://192.168.1.22:8000/abscence/check_ip_allowed/$publicIpAddress'),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['allowed'];
      } else {
        throw Exception('Failed to check IP address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while checking IP address: $e');
    }
  }
}
