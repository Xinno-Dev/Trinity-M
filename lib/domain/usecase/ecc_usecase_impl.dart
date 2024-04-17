import 'package:larba_00/domain/repository/ecc_repository.dart';
import 'package:larba_00/domain/usecase/ecc_usecase.dart';

import '../model/account_model.dart';
import '../model/ecckeypair.dart';

class EccUseCaseImpl implements EccUseCase {
  final EccRepository _repository;

  const EccUseCaseImpl(this._repository);

  @override
  Future<bool> generateKeyPair(String pin, {String? nickId, String? mnemonic}) async {
    return _repository.generateKeyPair(pin, nickId: nickId, mnemonic: mnemonic);
  }

  @override
  Future<bool> addKeyPair(String pin,
      {String? nickId, String? privateKeyHex}) async {
    return _repository.addKeyPair(pin, nickId: nickId, privateKeyHex: privateKeyHex);
  }

  @override
  Future<String> authSign(String pin, String message) async {
    return _repository.signing(pin, message);
  }

  @override
  Future<String> updateSign(
    String pin,
    String UID,
  ) async {
    var unixTimestamp = DateTime.now().millisecondsSinceEpoch;

    return _repository.signing(
      pin,
      unixTimestamp.toString(),
    );
  }

  @override
  Future<String> deleteSign(String pin) async {
    var unixTimestamp = DateTime.now().millisecondsSinceEpoch;

    return _repository.signing(
      pin,
      unixTimestamp.toString(),
    );
  }

  @override
  Future<bool> verify(
      String strPublicKey, String message, String strSignature) async {
    return _repository.verify(strPublicKey, message, strSignature);
  }

  @override
  Future<bool> deleteKeyPair() async => _repository.deleteKeyPair();
}
