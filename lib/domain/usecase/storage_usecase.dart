import 'package:larba_00/domain/model/storage_model.dart';

abstract class StorageUseCase {
  Future<StorageModel> read(String uid);
  Future<StorageModel> create(String uid, String publicKey, String pushToken);
}
