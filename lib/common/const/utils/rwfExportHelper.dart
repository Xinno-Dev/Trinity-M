import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../common/const/utils/userHelper.dart';
import '../../../domain/model/rwf.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

import 'convertHelper.dart';

class RWFExportHelper {
  static Future<String> encrypt(String pin, String address, String privateKey,
    [String? mnemonic]) async {
    int SALT_SIZE = 20;
    int AES_IV_SIZE = 16;
    int RANDOM_COUNT = Random().nextInt(5000) + 1000;

    LOG('--> RWFExportHelper encrypt : $pin / $address / $privateKey / $mnemonic');
    Random rnd = Random.secure();
    Uint8List salt = _getRandomData(rnd, SALT_SIZE);
    Uint8List iv   = _getRandomData(rnd, AES_IV_SIZE);
    Uint8List key  = await _generatePbkdf2Key(salt,
      Uint8List.fromList(utf8.encode(pin)), RANDOM_COUNT);

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
      paddedCipher.process(Uint8List.fromList(privateKey.codeUnits));

    var all = BytesBuilder();
    all.add(salt);
    all.add(iv);
    all.add(cipherText);

    Cp cp = Cp(
      ca: 'aes-256-cbc',
      ct: base64.encode(cipherText),
      ci: base64.encode(iv),
    );

    Dkp dkp = Dkp(
      ka: 'pbkdf2',
      kh: 'sha256',
      kc: RANDOM_COUNT.toString(),
      ks: base64.encode(salt),
      kl: '32',
    );

    RWF rwf = RWF(
      version: '1',
      address: address,
      algo: 'secp256k1',
      cp: cp,
      dkp: dkp,
    );

    if (mnemonic != null) {
      Uint8List encOrigin =
      paddedCipher.process(Uint8List.fromList(mnemonic.codeUnits));
      rwf.origin = base64.encode(encOrigin);
      LOG('--> RWFExportHelper origin : ${rwf.origin}');
    }

    String rwfString = json.encode(rwf.toJson());
    return rwfString;
  }

  static Future<String?> decrypt(String pin, String ciphertext) async {
    JSON jsonData = jsonDecode(ciphertext);
    var salt      = base64Decode(jsonData['dkp']['ks']);
    var iv        = base64Decode(jsonData['cp']['ci']);
    var encrypted = base64Decode(jsonData['cp']['ct']);
    var random    = INT(jsonData['dkp']['kc']);
    LOG('--> RWFExportHelper decrypt : $pin / $random => $encrypted');
    Uint8List key = await _generatePbkdf2Key(salt,
      Uint8List.fromList(utf8.encode(pin)), random);

    final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
    final ParametersWithIV<KeyParameter> ivParams =
      ParametersWithIV<KeyParameter>(new KeyParameter(key), iv);
    final paddingParams =
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ivParams, null);
    final paddedCipher =
      PaddedBlockCipherImpl(new PKCS7Padding(), cbcCipher);
    paddedCipher.init(false, paddingParams);
    Uint8List cipherText = Uint8List.fromList([]);

    try {
      cipherText = paddedCipher.process(encrypted);
      return String.fromCharCodes(cipherText);
    } catch (e) {
      LOG('--> RWFExportHelper decrypt error : $e');
    }
    return null;
  }

  static Uint8List _getRandomData(Random rnd, int numberBytes) {
    Uint8List data = Uint8List(numberBytes);
    for (int i = 0; i < numberBytes; i++) {
      data[i] = rnd.nextInt(256);
    }
    return data;
  }

  static Future<Uint8List> _generatePbkdf2Key(
    Uint8List salt, Uint8List passphrase, int randomCount) async {
    KeyDerivator derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    Pbkdf2Parameters params = Pbkdf2Parameters(salt, randomCount, 32);
    derivator.init(params);
    return derivator.process(passphrase);
  }
}
