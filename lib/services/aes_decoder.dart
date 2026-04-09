import 'dart:convert';
import 'package:pointycastle/export.dart';

class AESDecoder {
  // المفتاح مقسم ومخفي بطريقة صعبة الوصول
  static String _getKey() {
    // المفتاح الأصلي: X25ldHN5bmFfbmV0bW9kXw==
    // مخفي كأجزاء يتم دمجها
    String part1 = "X25ldHN5bmF";
    String part2 = "fbmV0bW9kXw==";
    return part1 + part2;
  }

  static String decode(String encodedText) {
    try {
      // فك base64 للمفتاح
      List<int> keyBytes = base64.decode(_getKey());
      
      // فك base64 للنص المشفر
      List<int> encryptedBytes = base64.decode(encodedText);
      
      // إنشاء cipher AES-ECB
      final cipher = AESEngine();
      cipher.init(false, KeyParameter(keyBytes));
      
      // فك التشفير
      List<int> decryptedBytes = _ecbDecrypt(cipher, encryptedBytes);
      
      // إزالة padding PKCS7
      int padLength = decryptedBytes.last;
      if (padLength < 1 || padLength > 16) {
        throw Exception('Invalid padding');
      }
      decryptedBytes = decryptedBytes.sublist(0, decryptedBytes.length - padLength);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('فك التشفير فشل: ${e.toString()}');
    }
  }
  
  static List<int> _ecbDecrypt(AESEngine cipher, List<int> data) {
    int blockSize = cipher.blockSize;
    List<int> result = [];
    
    for (int i = 0; i < data.length; i += blockSize) {
      int end = (i + blockSize < data.length) ? i + blockSize : data.length;
      List<int> block = data.sublist(i, end);
      
      // تأكد أن حجم البلوك صحيح
      if (block.length < blockSize) {
        // Padding مشكلة، نحاول نكمل
        while (block.length < blockSize) {
          block.add(0);
        }
      }
      
      List<int> decryptedBlock = List<int>.filled(blockSize, 0);
      cipher.processBlock(block, 0, decryptedBlock, 0);
      result.addAll(decryptedBlock);
    }
    
    return result;
  }
}
