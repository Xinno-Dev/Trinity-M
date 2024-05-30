import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../common/const/utils/userHelper.dart';
import '../../../domain/model/rwf.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'appVersionHelper.dart';
import 'convertHelper.dart';

class AesManager {
  static int SALT_SIZE = 20;
  static int AES_IV_SIZE = 16;

  Future<String> encrypt(String pin, String msg, {var isBase64 = true}) async {
    Random rnd = Random.secure();
    Uint8List salt = _getRandomData(rnd, SALT_SIZE);

    Uint8List iv = _getRandomData(rnd, AES_IV_SIZE);
    // Uint8List key =
    //     await _generateScryptKey(salt, Uint8List.fromList(utf8.encode(pin)));
    Uint8List key =
        await _generatePbkdf2Key(salt, Uint8List.fromList(utf8.encode(pin)));

//AES 설정 정보
    final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
    final ParametersWithIV<KeyParameter> ivParams =
        ParametersWithIV<KeyParameter>(new KeyParameter(key), iv);
    final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>
        paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            ivParams, null);
    final PaddedBlockCipherImpl paddedCipher =
        new PaddedBlockCipherImpl(new PKCS7Padding(), cbcCipher);

    paddedCipher.init(true, paddingParams);
    Uint8List cipherText =
        paddedCipher.process(Uint8List.fromList(msg.codeUnits));

    BytesBuilder all = BytesBuilder();
    all.add(salt);
    all.add(iv);
    all.add(cipherText);

    Cp cp = Cp(
      ca: 'aes-256-cbc',
      ct: base64.encode(cipherText),
      ci: base64.encode(iv),
    );

    Dkp dkp = Dkp(
      ka: 'scrypt',
      kh: 'sha256',
      kc: '0',
      ks: base64.encode(salt),
      kl: '32',
    );

    String address = await UserHelper().get_address();

    RWF rwf = RWF(
      version: '1',
      address: address,
      algo: 'secp256k1',
      cp: cp,
      dkp: dkp,
    );
    String rwfString = json.encode(rwf.toJson());
    UserHelper().setUser(rwf: rwfString);
    return base64Encode(Uint8List.fromList(all.toBytes()));
  }

  Future<String?> get localJwt async {
    var jwtEnc = await UserHelper().get_jwt();
    if (jwtEnc == null) {
      LOG('--> jwtEnc error !!');
      return null;
    }
    var pass = await deviceIdPass;
    var jwt  = await decrypt(pass, jwtEnc);
    LOG('--> jwt : $jwt / $pass');
    return jwt;
  }

  Future<String> get deviceIdPass async {
    var deviceId = await getDeviceId();
    var pass = crypto.sha256.convert(utf8.encode(deviceId)).toString();
    LOG('--> deviceIdPass : $pass');
    return pass;
  }

  Future<String> encryptWithDeviceId(String msg) async {
    var pass    = await deviceIdPass;
    var result  = await encrypt(pass, msg);
    return result;
  }

  Future<String> decryptWithDeviceId(String encMsg) async {
    var pass    = await deviceIdPass;
    var result  = await decrypt(pass, encMsg);
    return result;
  }

  Future<String> decrypt(String pin, String ciphertext) async {
    Uint8List ciphertextlist = base64.decode(ciphertext);

    var salt = ciphertextlist.sublist(0, SALT_SIZE);
    var iv = ciphertextlist.sublist(SALT_SIZE, SALT_SIZE + AES_IV_SIZE);
    var encrypted = ciphertextlist.sublist(SALT_SIZE + AES_IV_SIZE);
    // Uint8List key =
    //     await _generateScryptKey(salt, Uint8List.fromList(utf8.encode(pin)));
    Uint8List key =
        await _generatePbkdf2Key(salt, Uint8List.fromList(utf8.encode(pin)));

    final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
    final ParametersWithIV<KeyParameter> ivParams =
        ParametersWithIV<KeyParameter>(new KeyParameter(key), iv);
    final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>
        paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            ivParams, null);
    final PaddedBlockCipherImpl paddedCipher =
        new PaddedBlockCipherImpl(new PKCS7Padding(), cbcCipher);

    paddedCipher.init(false, paddingParams);

    Uint8List cipherText = Uint8List.fromList([]);

    try {
      cipherText = paddedCipher.process(encrypted);
    } catch (_) {
      return 'fail';
    }

    return String.fromCharCodes(cipherText);
  }

  static Uint8List _getRandomData(Random rnd, int numberBytes) {
    Uint8List data = Uint8List(numberBytes);
    for (int i = 0; i < numberBytes; i++) {
      data[i] = rnd.nextInt(256);
    }
    return data;
  }

  Future<Uint8List> _generateScryptKey(
      Uint8List salt, Uint8List passphrase) async {
    var derivator = KeyDerivator('scrypt');
    var params = ScryptParameters(2048, 8, 16, 32, salt);
    // ScryptParameters(N, r, p, desiredKeyLength, salt)
    derivator.init(params);
    return await derivator.process(passphrase);
  }

  Future<Uint8List> _generatePbkdf2Key(
      Uint8List salt, Uint8List passphrase) async {
    KeyDerivator derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    Pbkdf2Parameters params = Pbkdf2Parameters(salt, 1000, 32);
    derivator.init(params);
    return derivator.process(passphrase);
  }
}
