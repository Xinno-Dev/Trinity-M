abstract class EccRepository {
  Future<bool> generateKeyPair(String pin, {String mnemonic = ''});
  Future<bool> addKeyPair(String pin,
      {bool hasMnemonic = true, String privateKeyHex = ''});
  Future<String> signing(String pin, String message);
  Future<String> signingEx(String pin, String message);
  Future<bool> verify(String strPublicKey, String message, String strSignature);
  Future<bool> deleteKeyPair();
}
