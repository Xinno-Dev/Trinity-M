import 'dart:convert';

import 'dart:math';

import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/utils/walletHelper.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:secp256k1cipher/secp256k1cipher.dart';
import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:crypto/crypto.dart';
import 'package:web3dart/crypto.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;

class EccManager {
  var eccDomain = ECDomainParameters(ECCurve_secp256k1().domainName);

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateKeypair() async {
    var keyPair = _secp256k1KeyPair();
    return keyPair;
  }

  Future<String> signing(EccKeyPair keyPair, String msg) async {
    String privateKey = keyPair.d;
    String signature = _privateSign(privateKey, msg);
    privateKey = '0x00';
    return signature;
  }

  Future<String> signingEx(String privateKeyHex, String msg) async {
    String signature = _privateSign(privateKeyHex, msg, false);
    return signature;
  }

  Future<bool> verify(
      String strPublicKey, String message, String strSignature) async {
    var verify = _publicVerify(strPublicKey, message, strSignature);
    return verify;
  }

  String _privateSign(String strPrivateKey, String message, [var isBase64 = true]) {
    Uint8List privateKey = intToBytes(hexToInt(strPrivateKey));
    Uint8List hashMessage;
    if (isBase64) {
      hashMessage = Uint8List.fromList(sha256.convert(base64Decode(message)).bytes);
    } else {
      hashMessage = Uint8List.fromList(sha256.convert(message.codeUnits).bytes);
    }
    // secp256k1 signing..
    MsgSignature signature = sign(hashMessage, privateKey);

    privateKey = Uint8List.fromList([0]);
    final x_s = signature.r.toRadixString(16);
    final y_s = signature.s.toRadixString(16);
    final v_s = (signature.v - 27).toRadixString(16).padLeft(2, '0');
    // LOG('--> signature xyv : $x_s, $y_s, $v_s / $hashMessage');
    //Chain에 적용된 전자서명과 맞추기 위해 -27 을 해준다.
    //추후 verify 할때에는 v 값을 +27 해줘야함.
    final hex_x = left_padding(x_s, 64);
    final hex_y = left_padding(y_s, 64);
    return hex_x + hex_y + v_s;
  }

  bool _publicVerify(String strPublicKey, String message, String strSignature) {
    ECPublicKey publicKey = loadPublicKey(strPublicKey);
    ECDSASigner verifySinger = new ECDSASigner();
    var pubkeyParam = new PublicKeyParameter(
        new ECPublicKey(publicKey.Q, publicKey.parameters));

    final str_r = strSignature.substring(0, 64);
    final str_s = strSignature.substring(64, 128);
    final r = BigInt.parse(str_r, radix: 16);
    final s = BigInt.parse(str_s, radix: 16);

    ECSignature signature = new ECSignature(r, s);
    verifySinger.init(false, pubkeyParam);

    var utf8List = utf8.encode(message);
    var shaConvert = sha256.convert(utf8List);

    return verifySinger.verifySignature(
        // createUint8ListFromString(message), signature);
        createUint8ListFromString(shaConvert.toString()),
        signature);
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> _secp256k1KeyPair() {
    var keyParams = ECKeyGeneratorParameters(ECCurve_secp256k1());

    var random = FortunaRandom();
    random.seed(KeyParameter(_seed()));

    var generator = ECKeyGenerator();
    generator.init(ParametersWithRandom(keyParams, random));

    return generator.generateKeyPair();
  }

  Uint8List _seed() {
    var random = Random.secure();
    var seed = List<int>.generate(32, (_) => random.nextInt(256));
    return Uint8List.fromList(seed);
  }

  //니모닉 생성, 최초 키페어 생성
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateMnemonicKeypair(
      String pin,
      {String mnemonic = ''}) async {
    if (mnemonic == '') mnemonic = bip39.generateMnemonic();
    LOG('--> generateMnemonicKeypair : $pin / $mnemonic');

    final seed = bip39.mnemonicToSeed(mnemonic);
    final rootKey = bip32.BIP32.fromSeed(seed);
    final keyPair = rootKey.derivePath(
        "m/44'/1021'/0'/0/0"); //index num 에 따라 유도 되는 KeyPair 처음은 0으로 고정

    final Uint8List privateKeyList = keyPair.privateKey!;
    final String privateKeyHex = formatBytesAsHexString(privateKeyList);

    ECPrivateKey privateKey = hexToECPrivateKey(privateKeyHex);
    ECPublicKey  publicKey  = getPublicKey(privateKeyHex);

    AesManager aesManager = AesManager();
    String encMnemonic = await aesManager.encrypt(pin, mnemonic);
    String encRootKey  = await aesManager.encrypt(pin, rootKey.toBase58());

    UserHelper().setUser(
      mnemonic: encMnemonic,
      rootKey:  encRootKey,
      checkMnemonic: mnemonic,
    );

    return AsymmetricKeyPair(publicKey, privateKey);
  }

  //RootKey 기반으로 새로운 키페어 추가
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> addMnemonicKeypair(
      String pin, int index) async {
    UserHelper userHelper = UserHelper();
    String rootKeyenc = await userHelper.get_rootKey(); //암호화된 RootKey

    AesManager aesManager = AesManager();
    String rootKeyString =
        await aesManager.decrypt(pin, rootKeyenc); //복호화된 RootKey

    final rootKey =
        bip32.BIP32.fromBase58(rootKeyString); //base58 String 으로 부터 rootKey 복원
    final keyPair = rootKey
        .derivePath("m/44'/1021'/0'/0/$index"); //AddressModel 의 hasmnemonic

    final Uint8List privateKeyList = keyPair.privateKey!;
    final String privateKeyHex = formatBytesAsHexString(privateKeyList);
    ECPrivateKey privateKey = hexToECPrivateKey(privateKeyHex);
    ECPublicKey publicKey = getPublicKey(privateKeyHex);
    return AsymmetricKeyPair(publicKey, privateKey);
  }

  //사용자에게 입력받은 PrivateKey 로 생성하는 키페어
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>?> loadKeyPair(
      String privateKeyHex) async {
    try {
      ECPrivateKey privateKey = hexToECPrivateKey(privateKeyHex);
      ECPublicKey publicKey = getPublicKey(privateKeyHex);
      return AsymmetricKeyPair(publicKey, privateKey);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isValidateKeyPair(
      AsymmetricKeyPair<PublicKey, PrivateKey>? keyPair) async {
    if (keyPair == null) {
      return false;
    }

    ECPrivateKey privateKey = keyPair.privateKey as ECPrivateKey;
    ECPublicKey publicKey = keyPair.publicKey as ECPublicKey;

    ECDSASigner signer = new ECDSASigner();
    var privParams = new PrivateKeyParameter(
        new ECPrivateKey(privateKey.d, privateKey.parameters));
    var signParams =
        () => new ParametersWithRandom(privParams, new NullSecureRandom());
    signer.init(true, signParams());

    var message = 'Test Message'.codeUnits;

    ECSignature signature =
        signer.generateSignature(Uint8List.fromList(message)) as ECSignature;

    ECDSASigner verifySinger = new ECDSASigner();
    var pubkeyParam = new PublicKeyParameter(
        new ECPublicKey(publicKey.Q, publicKey.parameters));

    verifySinger.init(false, pubkeyParam);
    verifySinger.verifySignature(Uint8List.fromList(message), signature);

    return true;
  }

  //BIP32 Package 를 통해 생성된 Public Key 는 압축된 Public Key 가 출력되기 때문에 압축되지 않은 Public Key 생성
  ECPublicKey getPublicKey(String privateKeyHex) {
    final privateKeyBigInt = BigInt.parse(privateKeyHex, radix: 16);
    final domainParams = ECCurve_secp256k1();
    final pointQ = domainParams.G * privateKeyBigInt;
    final publicKey = ECPublicKey(pointQ, domainParams);
    return publicKey;
  }

  ECPrivateKey hexToECPrivateKey(String hexPrivateKey) {
    final privateKeyBigInt = BigInt.parse(hexPrivateKey, radix: 16);
    final ECCurve_secp256k1 curve = ECCurve_secp256k1();
    final ECPrivateKey privateKey = ECPrivateKey(privateKeyBigInt, curve);
    return privateKey;
  }

  String getAddressFromPublicKey(ECPublicKey publicKey) {
    final x_s = publicKey.Q!.x!.toBigInteger()!.toRadixString(16);
    final y_s = publicKey.Q!.y!.toBigInteger()!.toRadixString(16);
    final hex_x = left_padding(x_s, 64);
    final hex_y = left_padding(y_s, 64);
    final String address = _generateAddress(hex_x, hex_y);
    return address;
  }

  String _generateAddress(String x, String y) {
    late final Uint8List compressed;
    Uint8List xArr = createUint8ListFromHexString(x);
    Uint8List yArr = createUint8ListFromHexString(y);
    compressed = Uint8List(33);
    if ((yArr.last & 1) == 0) {
      compressed[0] = 0x02;
    } else {
      compressed[0] = 0x03;
    }
    compressed.setRange(1, 33, xArr);
    return formatBytesAsHexString(_btcAddress(compressed));
  }

  Uint8List _btcAddress(Uint8List compressed) {
    final sha256 = SHA256Digest();
    final ripemd160 = RIPEMD160Digest();
    final hash = sha256.process(compressed);
    final addr = ripemd160.process(hash);
    return Uint8List.fromList(addr);
  }
}
