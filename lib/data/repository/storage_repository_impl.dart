import '../../common/common_package.dart';
import '../../domain/model/storage_model.dart';
import '../../domain/repository/storage_repository.dart';
import '../../services/storage_api_services.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageAPIServices storageAPIServices;
  StorageRepositoryImpl(
    this.storageAPIServices,
  );

  @override
  Future<StorageModel> read(String uid) async {
    // storageAPIServices = StorageAPIServices(httpClient: http.Client());
    return await storageAPIServices.read(uid);
  }

  @override
  Future<StorageModel> create(
      String uid, String publicKey, String pushToken) async {
    return await storageAPIServices.create(uid, publicKey, pushToken);
  }
}

final storageRepositoryProvider = Provider<StorageRepositoryImpl>((ref) {
  return StorageRepositoryImpl(ref.read(storageServiceProvider));
});
