import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:e_commerces/services/ImageStorage.dart';
import 'package:http/http.dart' as http;

class CloudinaryStorageService implements ImageStorage {
  CloudinaryStorageService({
    String? cloudName,
    String? apiKey,
    String? apiSecret,
    String? uploadPreset,
  }) : _cloudName =
           (cloudName ??
                   Platform.environment['CLOUDINARY_CLOUD_NAME'] ??
                   'dd8qsz6kj')
               .trim(),
       _apiKey =
           (apiKey ??
                   Platform.environment['CLOUDINARY_API_KEY'] ??
                   '918426918962158')
               .trim(),
       _apiSecret =
           (apiSecret ??
                   Platform.environment['CLOUDINARY_API_SECRET'] ??
                   '8cctLv37rbMUOSBEVZPeBYfbLbE')
               .trim(),
       _uploadPreset =
           (uploadPreset ?? Platform.environment['CLOUDINARY_UPLOAD_PRESET'])
               ?.trim();

  /// Reads CLOUDINARY_URL=cloudinary://<key>:<secret>@<cloud_name>
  factory CloudinaryStorageService.fromEnv() {
    final raw = Platform.environment['CLOUDINARY_URL'];
    if (raw != null && raw.isNotEmpty) {
      final uri = Uri.parse(raw);
      final parts = uri.userInfo.split(':');
      if (parts.length == 2 && uri.host.isNotEmpty) {
        return CloudinaryStorageService(
          cloudName: uri.host,
          apiKey: parts[0],
          apiSecret: parts[1],
        );
      }
    }
    return CloudinaryStorageService();
  }

  final String _cloudName;
  final String _apiKey;
  final String _apiSecret;
  final String? _uploadPreset;

  String get _base => 'https://api.cloudinary.com/v1_1/$_cloudName/image';

  // Signature = SHA1("k1=v1&k2=v2" + api_secret), params sorted by name,
  // excluding file, api_key, cloud_name and resource_type.
  String _sign(Map<String, String> params) {
    final keys = params.keys.toList()..sort();
    final toSign = keys.map((k) => '$k=${params[k]}').join('&');
    return sha1.convert(utf8.encode('$toSign$_apiSecret')).toString();
  }

  String _timestamp() =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  @override
  Future<String> upload({
    required String key, // used as Cloudinary public_id
    required Uint8List bytes,
    required String contentType,
    String? filename,
  }) async {
    final timestamp = _timestamp();
    final request = http.MultipartRequest('POST', Uri.parse('$_base/upload'));

    if (_uploadPreset != null && _uploadPreset!.isNotEmpty) {
      request.fields['upload_preset'] = _uploadPreset!;
      request.fields['public_id'] = key;
    } else {
      final signature = _sign({'public_id': key, 'timestamp': timestamp});
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['public_id'] = key;
      request.fields['signature'] = signature;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename ?? 'image.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      stderr.writeln(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
      String errMsg = 'Upload failed (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['error']?['message'] != null) {
          errMsg = decoded['error']['message'].toString();
        }
      } catch (_) {}
      throw Exception('Cloudinary error: $errMsg');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['secure_url'] ?? data['url'] ?? urlFor(key)).toString();
  }

  @override
  Future<void> delete(String key) async {
    final timestamp = _timestamp();
    final signature = _sign({'public_id': key, 'timestamp': timestamp});

    final response = await http.post(
      Uri.parse('$_base/destroy'),
      body: {
        'public_id': key,
        'timestamp': timestamp,
        'api_key': _apiKey,
        'signature': signature,
      },
    );

    if (response.statusCode != 200) {
      stderr.writeln('Cloudinary delete failed: ${response.body}');
      String errMsg = 'Delete failed';
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['error']?['message'] != null) {
          errMsg = decoded['error']['message'].toString();
        }
      } catch (_) {}
      throw Exception('Cloudinary delete error: $errMsg');
    }
  }

  /// f_auto,q_auto = Cloudinary picks the best format (WebP/AVIF) and quality.
  @override
  String urlFor(String key) =>
      'https://res.cloudinary.com/$_cloudName/image/upload/f_auto,q_auto/$key';
}
