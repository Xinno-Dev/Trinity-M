import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

class SignHelper {
  late var rnd = getSecureRandom();
  var domainParams = ECDomainParameters("secp256k1");

  String encrypt(var rawPubKeyCompUncomp, var plaintext){

    // 1. Create ephemeral key pair
    var ephKeyPair = (KeyGenerator("EC")..init(ParametersWithRandom(ECKeyGeneratorParameters(domainParams), rnd))).generateKeyPair();

    // 2. Import public key of receiver
    var ecPoint = domainParams.curve.decodePoint(hex.decode(rawPubKeyCompUncomp));
    var publicKey = ECPublicKey(ecPoint, domainParams);

    // 3. Get full point to ECDH shared secret, derive AES key via HKDF
    var sharedSecretECPointUncomp = (publicKey.Q! * (ephKeyPair.privateKey as ECPrivateKey).d)!.getEncoded(false);
    var ephPublicKeyUncomp = (ephKeyPair.publicKey as ECPublicKey).Q!.getEncoded(false);
    var aesKey = hkdf(ephPublicKeyUncomp, sharedSecretECPointUncomp);

    // 4. Encrypt via AES-256, GCM
    var nonce = rnd.nextBytes(16);
    var ciphertextTag = (GCMBlockCipher(AESEngine())..init(true, AEADParameters(KeyParameter(aesKey), 128, nonce, Uint8List(0)))).process(plaintext);

    // 5. Concatenate (ephemeral public key|nonce|tag|ciphertext), Base64 encode and return
    return base64.encode(ephPublicKeyUncomp + nonce + ciphertextTag.sublist(ciphertextTag.length - 16) + ciphertextTag.sublist(0, ciphertextTag.length - 16));
  }

  SecureRandom getSecureRandom() {
    List<int> seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return FortunaRandom()..seed(KeyParameter(Uint8List.fromList(seed)));
  }

  Uint8List hkdf(var ephPublicKeyUnc, var sharedSecretEcPointUnc) {
    var master = Uint8List.fromList(ephPublicKeyUnc + sharedSecretEcPointUnc);
    var aesKey = Uint8List(32);
    (HKDFKeyDerivator(SHA256Digest())..init(HkdfParameters(master, 32, null))).deriveKey(null, 0, aesKey, 0);
    return aesKey;
  }
}