import 'dart:convert';
import 'package:http/http.dart' as http;

class ImgbbService {
  static const String apiKey = '3ca3dda7b277e755eb113fe96665be9e';
  static const String apiUrl = 'https://api.imgbb.com/1/upload';

  Future<Map<String, String>?> uploadImage({
    required String photoTitle,
    required String emoji,
    required List<int> bytes,
    required String uploadedBy,
  }) async {
    try {
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'key': apiKey,
          'image': base64Image,
          'name': photoTitle,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final url = jsonResponse['data']['url'];

        return {
          'title': photoTitle,
          'emoji': emoji,
          'driveUrl': url, // Key dipertahankan 'driveUrl' agar kompatibel dengan schema Firestore lama
          'url': url, // Tambahkan 'url' agar UI mengenali bahwa ini gambar asli dari ImgBB
          'uploadedBy': uploadedBy,
          'date': 'Hari Ini',
        };
      } else {
        print('ImgBB Upload Failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('ImgBB Service Error: $e');
      return null;
    }
  }
}
