import 'package:equatable/equatable.dart';

import '../../domain/model/storage_model.dart';

enum StorageStatus {
  initial,
  submitting,
  success,
  error,
}

class StorageAPIState extends Equatable {
  final StorageStatus storageStatus;
  final CustomError error;
  final StorageModel storageModel;

  StorageAPIState({
    required this.storageStatus,
    required this.error,
    required this.storageModel,
  });

  factory StorageAPIState.initial() {
    return StorageAPIState(
      storageStatus: StorageStatus.initial,
      error: CustomError(),
      storageModel: StorageModel(),
    );
  }

  @override
  String toString() =>
      'StorageAPIState(storageStatus: $storageStatus, error: $error, storageModel: $storageModel)';

  @override
  List<Object> get props => [storageStatus, error, storageModel];

  StorageAPIState copyWith({
    StorageStatus? storageStatus,
    CustomError? error,
    StorageModel? storageModel,
  }) {
    return StorageAPIState(
      storageStatus: storageStatus ?? this.storageStatus,
      error: error ?? this.error,
      storageModel: storageModel ?? this.storageModel,
    );
  }
}

class CustomError extends Equatable {
  final String errMsg;
  CustomError({
    this.errMsg = '',
  });

  @override
  List<Object> get props => [errMsg];

  @override
  String toString() => 'CustomError(errMsg: $errMsg)';
}
