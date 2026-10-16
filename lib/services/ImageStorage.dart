import 'dart:typed_data';

abstract class ImageStorage {
  /// Uploads image [bytes] to storage with [key] (public_id) and returns the public URL.
  Future<String> upload({
    required String key,
    required Uint8List bytes,
    required String contentType,
    String? filename,
  });

  /// Deletes an image by [key].
  Future<void> delete(String key);

  /// Builds a URL for [key].
  String urlFor(String key);
}
