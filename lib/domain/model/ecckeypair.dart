import 'package:freezed_annotation/freezed_annotation.dart';

part 'ecckeypair.freezed.dart';
part 'ecckeypair.g.dart';

@freezed
class EccKeyPair with _$EccKeyPair {
  const factory EccKeyPair({
    required String publicKey,
    required String d,
  }) = _EccKeyPair;

  factory EccKeyPair.fromJson(Map<String, Object?> json) =>
      _$EccKeyPairFromJson(json);
}
