import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class Api {
  static Future<Map<String,dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('$SERVER_BASE/auth/login'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'email':email,'password':password})
    );
    return {'status': res.statusCode, 'body': res.body};
  }

  static Future<http.Response> startBreak(String token, String type) {
    return http.post(Uri.parse('$SERVER_BASE/breaks/start'),
      headers: {'Content-Type':'application/json','Authorization':'Bearer $token'},
      body: jsonEncode({'type':type})
    );
  }

  static Future<http.Response> stopBreak(String token, String id) {
    return http.post(Uri.parse('$SERVER_BASE/breaks/stop'),
      headers: {'Content-Type':'application/json','Authorization':'Bearer $token'},
      body: jsonEncode({'id':id})
    );
  }
}
