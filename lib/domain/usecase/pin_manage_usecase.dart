abstract class PinManageUseCase {
  Future<bool> writePin(String pin);
  Future<String> readPin();
}
