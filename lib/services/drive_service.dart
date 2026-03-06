import 'dart:convert';
import 'package:http/http.dart' as http;

class DriveService {
  // YOUR SECURE WEB APP SCRIPT URL
  static const String _scriptUrl = 'https://script.google.com/macros/s/AKfycbzakbt_wDipLiu8-YF8nOvCVK7mpDfxZo5_LBChWpNb0WWaUhU72pt2LKonPF1tz-L0/exec';

  static Future<String?> uploadFile(List<int> bytes, String fileName, String mimeType) async {
    try {
      // Convert audio bytes to a format the Google Apps Script can read
      String base64Data = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_scriptUrl),
        // CRITICAL FIX: Using 'text/plain' instead of 'application/json' 
        // forces the browser to skip the CORS preflight check that Google blocks.
        headers: {
          "Content-Type": "text/plain",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "filename": fileName,
          "mimeType": mimeType,
          "base64": base64Data
        }),
      );

      // Google Apps Script usually returns 200 or 302 on success
      if (response.statusCode == 200 || response.statusCode == 302) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['url']; // The direct playback link
        } else {
          print("Script Error: ${jsonResponse['message']}");
          return null;
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
      return null;
    } catch (e) {
      print("Drive Upload Error: $e");
      return null;
    }
  }
}