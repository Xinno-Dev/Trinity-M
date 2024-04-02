
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../../domain/model/ecckeypair.dart';
import 'aesManager.dart';
import 'userHelper.dart';

Future<String> getPrivateKey(inputPin) async {
  final keyData = await UserHelper().get_key();
  final shaConvert = sha256.convert(utf8.encode(inputPin));
  final keyStr = await AesManager().decrypt(shaConvert.toString(), keyData);
  final keyJson = EccKeyPair.fromJson(jsonDecode(keyStr));
  return keyJson.d;
}
