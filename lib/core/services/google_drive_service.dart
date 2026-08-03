import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../models/group_model.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService {
  static const String clientId = '224225254785-j0r2s9s61khb18i11jje50rosdt0pe3q.apps.googleusercontent.com';
  
  // Target Folder ID: arisan-antigravity
  static const String targetFolderId = '1bU-HL9pQHyHyDNn8awxabxrSrVr8_6DI';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? currentUser;

  // Sign In with Google Account
  Future<GoogleSignInAccount?> signIn() async {
    try {
      currentUser = await _googleSignIn.signIn();
      return currentUser;
    } catch (e) {
      return null;
    }
  }

  // Backup Group Data JSON directly into target Folder 'arisan-antigravity'
  Future<String?> backupGroupToDrive(GroupModel group) async {
    try {
      final user = currentUser ?? await signIn();
      if (user == null) return null;

      final authHeaders = await user.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final jsonContent = jsonEncode({
        'group_id': group.id,
        'group_name': group.name,
        'pot_amount': group.potAmount,
        'kas_amount': group.kasAmount,
        'period_type': group.periodType,
        'active_period_index': group.activePeriodIndex,
        'backup_time': DateTime.now().toIso8601String(),
        'members_count': group.members.length,
      });

      final mediaStream = Stream.value(utf8.encode(jsonContent));
      final driveFile = drive.File()
        ..name = 'Backup_Arisan_${group.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json'
        ..parents = [targetFolderId]
        ..mimeType = 'application/json';

      final result = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(mediaStream, jsonContent.length),
      );

      return result.id;
    } catch (e) {
      return null;
    }
  }

  // Upload Photo directly into target Folder 'arisan-antigravity'
  Future<Map<String, String>?> uploadPhotoToDrive({
    required String photoTitle,
    required String emoji,
    List<int>? bytes,
    String? filename,
  }) async {
    try {
      final user = currentUser ?? await signIn();
      if (user == null || user.email.isEmpty) {
        throw Exception('User is not authenticated or email is missing.');
      }
      
      final fileNameStr = filename ?? 'Foto_Dokumentasi_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final authHeaders = await user.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Photo bytes cannot be null or empty.');
      }
      final mediaBytes = bytes;
      final mediaStream = Stream.value(mediaBytes);

        final driveFile = drive.File()
          ..name = fileNameStr
          ..parents = [targetFolderId]
          ..mimeType = 'image/jpeg';

        final result = await driveApi.files.create(
          driveFile,
          uploadMedia: drive.Media(mediaStream, mediaBytes.length),
        );

        final shareableLink = 'https://drive.google.com/file/d/${result.id}/view?usp=sharing';

        return {
          'title': photoTitle,
          'emoji': emoji,
          'driveUrl': shareableLink,
          'uploadedBy': user.email,
          'date': 'Hari Ini',
        };
    } catch (e) {
      print('Google Drive Upload Error: $e');
      rethrow;
    }
  }
}
