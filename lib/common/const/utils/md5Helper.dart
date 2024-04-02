import 'package:encrypt/encrypt.dart' as enc;

import 'convertHelper.dart';

const String AES_KEY =
    'A336094308408F431A635D0B67B5F841A1233AEB66300251F0A629CA3A5143D6';

String? encryptAES(String plainText, {String passKey = AES_KEY}) {
  try {
    // // LOG('--> encryptAES : $plainText / $passKey');
    final key = enc.Key.fromUtf8(passKey);
    final iv = enc.IV.fromLength(16);
    final encrypter =
    enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  } catch (e) {
    LOG('--> encryptAES error : $e');
    rethrow;
  }
}

String? decryptAES(String encrypted, {String passKey = AES_KEY}) {
  try {
    // // LOG('--> decryptAES : $encrypted / $passKey');
    final key = enc.Key.fromUtf8(passKey);
    final iv = enc.IV.fromLength(16);
    final encrypter =
    enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: "PKCS7"));
    return encrypter.decrypt64(encrypted, iv: iv);
  } catch (e) {
    LOG('--> decryptAES error : $e');
    rethrow;
  }
}
