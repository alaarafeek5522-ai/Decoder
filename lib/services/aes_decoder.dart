import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class AESDecoder {
  // المفتاح مقسم ومخفي
  static String _getKey() {
    String part1 = "X25ldHN5bmF";
    String part2 = "fbmV0bW9kXw==";
    return part1 + part2;
  }

  static String decode(String encodedText) {
    try {
      // فك base64 للمفتاح
      Uint8List keyBytes = Uint8List.fromList(base64.decode(_getKey()));
      
      // فك base64 للنص المشفر
      Uint8List encryptedBytes = Uint8List.fromList(base64.decode(encodedText));
      
      // إنشاء cipher AES-ECB
      final cipher = AESEngine();
      cipher.init(false, KeyParameter(keyBytes));
      
      // فك التشفير
      Uint8List decryptedBytes = _ecbDecrypt(cipher, encryptedBytes);
      
      // إزالة padding PKCS7
      int padLength = decryptedBytes.last;
      if (padLength < 1 || padLength > 16) {
        throw Exception('Invalid padding');
      }
      decryptedBytes = Uint8List.sublistView(decryptedBytes, 0, decryptedBytes.length - padLength);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('فك التشفير فشل: ${e.toString()}');
    }
  }
  
  static Uint8List _ecbDecrypt(AESEngine cipher, Uint8List data) {
    int blockSize = cipher.blockSize;
    List<int> result = [];
    
    for (int i = 0; i < data.length; i += blockSize) {
      int end = (i + blockSize < data.length) ? i + blockSize : data.length;
      Uint8List block = Uint8List.sublistView(data, i, end);
      
      // تأكد أن حجم البلوك صحيح
      if (block.length < blockSize) {
        List<int> padded = List.filled(blockSize, 0);
        for (int j = 0; j < block.length; j++) {
          padded[j] = block[j];
        }
        block = Uint8List.fromList(padded);
      }
      
      Uint8List decryptedBlock = Uint8List(blockSize);
      cipher.processBlock(block, 0, decryptedBlock, 0);
      result.addAll(decryptedBlock);
    }
    
    return Uint8List.fromList(result);
  }
}
