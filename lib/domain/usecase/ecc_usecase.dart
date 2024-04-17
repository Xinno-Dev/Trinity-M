import '../model/account_model.dart';
import '../model/ecckeypair.dart';

abstract class EccUseCase {
  Future<bool> generateKeyPair(String pin, {String? nickId, String? mnemonic});
  Future<bool> addKeyPair(String pin, {String? nickId, String? privateKeyHex});
  Future<String> updateSign(String pin, String UID);
  Future<String> deleteSign(
    String pin,
  );
  Future<String> authSign(String pin, String message);
  Future<bool> verify(String strPublicKey, String message, String strSignature);
  Future<bool> deleteKeyPair();
}
