
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

import '../../../domain/model/ecckeypair.dart';
import 'aesManager.dart';
import 'userHelper.dart';

Future<String> getPrivateKey(inputPin) async {
  var keyPair = await getPrivateKeyPair(inputPin);
  return keyPair.d;
}

Future<EccKeyPair> getPrivateKeyPair(inputPin) async {
  final keyData = await UserHelper().get_key();
  final shaConvert = sha256.convert(utf8.encode(inputPin));
  final keyStr = await AesManager().decrypt(shaConvert.toString(), keyData);
  final keyJson = EccKeyPair.fromJson(jsonDecode(keyStr));
  return keyJson;
}

ECPublicKey getPublicKey(String privateKeyHex) {
  final privateKeyBigInt = BigInt.parse(privateKeyHex, radix: 16);
  final domainParams = ECCurve_secp256k1();
  final pointQ = domainParams.G * privateKeyBigInt;
  final publicKey = ECPublicKey(pointQ, domainParams);
  return publicKey;
}

String formatBytesAsHexString(Uint8List bytes) {
  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

