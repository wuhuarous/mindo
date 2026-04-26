import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class OssService {
  static final OssService _instance = OssService._();
  factory OssService() => _instance;
  OssService._();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String> uploadFile(File file, String objectKey) async {
    final token = await _getToken();
    final uri = Uri.parse('${AppConstants.baseUrl}/upload');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final res = jsonDecode(body) as Map<String, dynamic>;

    if (res['success'] == true) {
      return res['data']['url'] as String;
    }
    throw Exception(res['error'] ?? '上传失败');
  }
}
