import 'package:equatable/equatable.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/data/repository/storage_state.dart';
import 'package:larba_00/domain/model/storage_model.dart';
import 'package:larba_00/services/storage_api_services.dart';

class RegistController extends StateNotifier<RegistState> {
  RegistController(this.ref) : super(RegistState.initial());
  final Ref ref;
  Future<void> create(
      String uid, String publicKey, String pushToken, String inputPin) async {
    // state = RegistStateLoading();
    state = state.copyWith(registStatus: RegistStatus.submitting);
    try {
      final StorageModel storageModel = await ref
          .read(storageServiceProvider)
          .create(uid, publicKey, pushToken);
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(
          registStatus: RegistStatus.success, storageModel: storageModel);
    } on CustomError catch (e) {
      state = state.copyWith(registStatus: RegistStatus.error, customError: e);
      rethrow;
    }
  }
}

final registControllerProvider =
    StateNotifierProvider.autoDispose<RegistController, RegistState>((ref) {
  return RegistController(ref);
});

enum RegistStatus {
  initial,
  submitting,
  success,
  error,
}

class RegistState extends Equatable {
  final RegistStatus registStatus;
  final CustomError customError;
  final StorageModel storageModel;

  const RegistState(
    this.registStatus,
    this.customError,
    this.storageModel,
  );

  factory RegistState.initial() {
    return RegistState(
      RegistStatus.initial,
      CustomError(),
      StorageModel(),
    );
  }

  @override
  List<Object> get props => [registStatus, customError];

  @override
  String toString() =>
      'RegistState(registStatus: $registStatus, cursorColor: $customError)';

  RegistState copyWith({
    RegistStatus? registStatus,
    CustomError? customError,
    StorageModel? storageModel,
  }) {
    return RegistState(
      registStatus ?? this.registStatus,
      customError ?? this.customError,
      storageModel ?? this.storageModel,
    );
  }
}

// class RegistStateInitial extends RegistState {
//   const RegistStateInitial();

//   @override
//   List<Object> get props => [];
// }

// class RegistStateLoading extends RegistState {
//   const RegistStateLoading();

//   @override
//   List<Object> get props => [];
// }

// class RegistStateSuccess extends RegistState {
//   const RegistStateSuccess();

//   @override
//   List<Object> get props => [];
// }

// class RegistStateError extends RegistState {
//   final String error;

//   const RegistStateError(this.error);

//   @override
//   List<Object> get props => [error];
// }
