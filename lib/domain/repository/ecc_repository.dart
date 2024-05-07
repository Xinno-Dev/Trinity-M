import '../model/account_model.dart';
import '../model/ecckeypair.dart';

abstract class EccRepository {
  Future<bool> generateKeyPair(String pin, {String? nickId, String? mnemonic});
  Future<bool> addKeyPair(String pin, {String? nickId, String? privateKeyHex});
  Future<bool> removeKeyPair(String address);
  Future<String> signing(String pin, String message);
  Future<String> signingEx(String pin, String message);
  Future<bool> verify(String strPublicKey, String message, String strSignature);
  Future<bool> deleteKeyPair();
}
