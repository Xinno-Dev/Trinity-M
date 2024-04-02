import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => FlutterSecureStorage());

class StorageNotifier extends StateNotifier<String> {
  StorageNotifier(this.storage) : super('');

  final FlutterSecureStorage storage;

  Future<void> getLoginDate() async {}
}
