import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.post(
    Uri.parse('https://fast-eat-npb7.onrender.com/api/v1/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': 'admin@fasteat.bj', 'password': 'admin123'}),
  );
  print('Status: \${res.statusCode}');
  print('Body: \${res.body}');
}
