import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String cloudName = dotenv.env['CLOUD_NAME'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  final String apiSecret = dotenv.env['API_SECRET'] ?? '';

  Future<String?> uploadPDF(File pdfFile) async {
    try {
      // Cloudinary Upload URL
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

      // Prepare the request body
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'unsigned_preset'
        ..fields['api_key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      // Send the request
      final response = await request.send();

      // Parse the response
      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseBody.body);
        return jsonResponse['secure_url']; // Cloudinary URL of the uploaded file
      } else {
        print('Upload failed: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }
}
