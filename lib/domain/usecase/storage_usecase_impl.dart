import 'package:larba_00/domain/model/storage_model.dart';
import 'package:larba_00/domain/repository/storage_repository.dart';
import 'storage_usecase.dart';

class StorageUseCaseImpl implements StorageUseCase {
  final StorageRepository _repository;

  const StorageUseCaseImpl(this._repository);
  @override
  Future<StorageModel> read(String uid) async {
    return await _repository.read(uid);
  }

  @override
  Future<StorageModel> create(
      String uid, String publicKey, String pushToken) async {
    return await _repository.create(uid, publicKey, pushToken);
  }
}
