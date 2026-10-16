import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/services/CloudinaryStorageService.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

final _storage = CloudinaryStorageService();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    Uint8List bytes;
    String contentType = 'image/jpeg';
    String filename = 'upload.jpg';

    final header = context.request.headers['content-type'] ?? '';

    if (header.contains('multipart/form-data')) {
      final formData = await context.request.formData();
      final file = formData.files['image'] ?? formData.files['file'];
      if (file == null) {
        return ApiResponse.badRequest(
          'No image file found in form-data. Use field name "image" or "file".',
        );
      }
      bytes = Uint8List.fromList(await file.readAsBytes());
      contentType = file.contentType.mimeType;
      filename = file.name;
    } else {
      final body = await context.request.json() as Map<String, dynamic>;
      final raw = body['image'] ?? body['image_base64'] ?? body['file'];
      if (raw == null || raw is! String || raw.isEmpty) {
        return ApiResponse.badRequest(
          'Provide an image via multipart/form-data ("image") or JSON { "image": "<base64>" }.',
        );
      }

      var base64Data = raw;
      if (raw.contains(',')) {
        final prefix = raw.substring(0, raw.indexOf(','));
        base64Data = raw.substring(raw.indexOf(',') + 1);
        if (prefix.contains(':') && prefix.contains(';')) {
          contentType = prefix.split(':')[1].split(';')[0];
        }
      }
      bytes = base64Decode(base64Data);
      if (body['content_type'] is String) {
        contentType = body['content_type'] as String;
      }
      if (body['filename'] is String) {
        filename = body['filename'] as String;
      }
    }

    if (bytes.isEmpty) {
      return ApiResponse.badRequest('Uploaded image cannot be empty.');
    }

    final key = 'product_detail/${DateTime.now().millisecondsSinceEpoch}';
    final url = await _storage.upload(
      key: key,
      bytes: bytes,
      contentType: contentType,
      filename: filename,
    );

    return ApiResponse.single(
      data: {
        'url': url,
        'public_id': key,
      },
      message: 'Image uploaded to Cloudinary successfully.',
    );
  } on FormatException {
    return ApiResponse.badRequest(
      'Invalid request format (expected multipart/form-data or JSON).',
    );
  } catch (e) {
    return ApiResponse.badRequest(ApiResponse.cleanError(e));
  }
}

