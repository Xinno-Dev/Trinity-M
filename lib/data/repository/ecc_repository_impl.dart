import 'dart:convert';
import 'dart:typed_data';

import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/utils/eccManager.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/account_model.dart';
import 'package:larba_00/domain/model/address_model.dart';
import 'package:larba_00/domain/repository/ecc_repository.dart';
import 'package:pointycastle/export.dart';

import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:secp256k1cipher/secp256k1cipher.dart';
import 'package:larba_00/common/const/utils/aesManager.dart';

const String AccountName = '계정 ';

class EccRepositoryImpl implements EccRepository {
  EccManager? _eccManager;

  @override
  Future<bool> generateKeyPair(String pin, {
    String? nickId,
    String? mnemonic,
  }) async {
    String encodeJson = '';
    UserHelper userHelper = UserHelper();
    LOG('--> generateKeyPair : ${userHelper.userKey}');

    _eccManager = EccManager();

    AsymmetricKeyPair<PublicKey, PrivateKey> keyResult =
        await _eccManager!.generateMnemonicKeypair(pin, mnemonic: mnemonic ?? '');

    ECPrivateKey privateKey = keyResult.privateKey as ECPrivateKey;
    ECPublicKey publicKey = keyResult.publicKey as ECPublicKey;

    final x_s = publicKey.Q!.x!.toBigInteger()!.toRadixString(16);
    final y_s = publicKey.Q!.y!.toBigInteger()!.toRadixString(16);

    final hex_x = left_padding(x_s, 64);
    final hex_y = left_padding(y_s, 64);

    final String publicKeyStr = hex_x + hex_y;
    userHelper.setUser(publickey: publicKeyStr);

    EccKeyPair eccKeyPair = EccKeyPair(
      publicKey: publicKeyStr,
      d: privateKey.d!.toRadixString(16).toString(),
    );
    var toJson = eccKeyPair.toJson();
    encodeJson = json.encode(toJson);

    final String address = _generateAddress(hex_x, hex_y);
    userHelper.setUser(address: address);

    AesManager aesManager = AesManager();
    String encResult = await aesManager.encrypt(pin, encodeJson);

    List<AddressModel> addressList = [];
    AddressModel newAddress = AddressModel(
        accountName: nickId ?? AccountName + '01',
        address: address,
        keyPair: encResult,
        publicKey: publicKeyStr,
        hasMnemonic: true);
    addressList.add(newAddress);

    final addressListJson =
        addressList.map((address) => address.toJson()).toList();

    final addressJsonString = json.encode(addressListJson);
    userHelper.setUser(addressList: addressJsonString);

    if (encResult == 'fail') {
      return false;
    } else {
      userHelper.setUser(key: encResult); //최초로 사용되는 Key 저장
      AesManager aesManager = AesManager();
      String trashResult = await aesManager.encrypt(pin, publicKeyStr);
      userHelper.setUser(trash: trashResult);
      return true;
    }
  }

  @override
  Future<bool> addKeyPair(String pin, {
    String? nickId,
    String? privateKeyHex
  }) async {
    _eccManager = EccManager();
    UserHelper userHelper = UserHelper();
    List<AddressModel> addressList = [];

    String jsonString = await userHelper.get_addressList();

    List<dynamic> decodeJson = json.decode(jsonString);
    int index = 0;
    for (var jsonObject in decodeJson) {
      AddressModel model = AddressModel.fromJson(jsonObject);
      if (model.hasMnemonic == true) {
        index++;
      }
      addressList.add(model);
    }
    AsymmetricKeyPair<PublicKey, PrivateKey>? keyResult;
    if (privateKeyHex != null && privateKeyHex.length > 0) {
      keyResult = (await _eccManager!.loadKeyPair(privateKeyHex));
    } else {
      keyResult = await _eccManager!.addMnemonicKeypair(pin, index);
    }
    if (keyResult == null) {
      return false;
    }

    ECPrivateKey privateKey = keyResult.privateKey as ECPrivateKey;
    ECPublicKey publicKey = keyResult.publicKey as ECPublicKey;

    final x_s = publicKey.Q!.x!.toBigInteger()!.toRadixString(16);
    final y_s = publicKey.Q!.y!.toBigInteger()!.toRadixString(16);

    final hex_x = left_padding(x_s, 64);
    final hex_y = left_padding(y_s, 64);

    final String publicKeyStr = hex_x + hex_y;

    EccKeyPair eccKeyPair = EccKeyPair(
      publicKey: publicKeyStr,
      d: privateKey.d!.toRadixString(16).toString(),
    );
    var toJson = eccKeyPair.toJson();
    String encodeJson = json.encode(toJson);

    final String address = _generateAddress(hex_x, hex_y);
    AesManager aesManager = AesManager();
    final String encResult = await aesManager.encrypt(pin, encodeJson);

    AddressModel newAddress = AddressModel(
        accountName: nickId ??
            '$AccountName' + '${addressList.length + 1}'.padLeft(2, '0'),
        address: address,
        keyPair: encResult,
        publicKey: publicKeyStr,
        hasMnemonic: false);

    //추가 전 같은 주소가 있는지 확인 후 같은 주소가 있으면 추가하지 않음.
    for (AddressModel model in addressList) {
      if (model.address == newAddress.address) {
        return false;
      }
    }

    addressList.add(newAddress);

    final addressListJson =
        addressList.map((address) => address.toJson()).toList();

    final addressJsonString = json.encode(addressListJson);
    userHelper.setUser(
      publickey: publicKeyStr,
      key: encResult,
      address: address,
      addressList: addressJsonString,
    );
    return true;
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

  @override
  Future<String> signing(String pin, String message) async {
    _eccManager = EccManager();
    try {
      String keyStr = await UserHelper().get_key();

      UserHelper().get_key().then((value) {
        keyStr = value;
      });

      AesManager aesManager = AesManager();

      String keyJson = await aesManager.decrypt(pin, keyStr);
      EccKeyPair keyPair = EccKeyPair.fromJson(json.decode(keyJson));
      String signature = await _eccManager!.signing(keyPair, message);
      keyPair = EccKeyPair(publicKey: '0x00', d: '0x00');
      return signature;
    } catch (e) {
      return 'fail';
    }
  }

  @override
  Future<String> signingEx(String pin, String message) async {
    _eccManager = EccManager();
    try {
      String keyStr = await UserHelper().get_key();

      UserHelper().get_key().then((value) {
        keyStr = value;
      });

      AesManager aesManager = AesManager();

      String keyJson = await aesManager.decrypt(pin, keyStr);
      EccKeyPair keyPair = EccKeyPair.fromJson(json.decode(keyJson));
      String signature = await _eccManager!.signingEx(keyPair.d, message);
      keyPair = EccKeyPair(publicKey: '0x00', d: '0x00');
      return signature;
    } catch (e) {
      return 'fail';
    }
  }

  @override
  Future<bool> verify(
      String strPublicKey, String message, String strSignature) async {
    _eccManager = EccManager();

    bool verify = await _eccManager!.verify(
      strPublicKey,
      message,
      strSignature,
    );
    return verify;
  }

  @override
  Future<bool> deleteKeyPair() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }
}
