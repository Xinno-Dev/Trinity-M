import 'package:biometric_storage/biometric_storage.dart';
import '../../domain/usecase/pin_manage_usecase.dart';

class PinManageUseCaseImpl implements PinManageUseCase {
  final String storageName = 'pin_manage';
  BiometricStorageFile? _biometricStorageFile;
  @override
  Future<bool> writePin(String pin) async {
    _biometricStorageFile = await BiometricStorage().getStorage(
      storageName,
      options: StorageFileInitOptions(authenticationValidityDurationSeconds: 5),
    );

    try {
      await _biometricStorageFile!.write(pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> readPin() async {
    _biometricStorageFile = await BiometricStorage().getStorage(
      storageName,
      options: StorageFileInitOptions(authenticationValidityDurationSeconds: 5),
    );

    try {
      String pinString = await _biometricStorageFile!.read() as String;
      return pinString;
    } catch (e) {
      return 'Failure';
    }
  }
}
