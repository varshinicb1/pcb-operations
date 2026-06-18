import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageHelper {
  ImageHelper._();

  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  static Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  static const String prefix = 'data:image/jpeg;base64,';
}
