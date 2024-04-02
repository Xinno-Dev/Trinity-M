// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ecckeypair.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EccKeyPair _$EccKeyPairFromJson(Map<String, dynamic> json) {
  return _EccKeyPair.fromJson(json);
}

/// @nodoc
mixin _$EccKeyPair {
  String get publicKey => throw _privateConstructorUsedError;
  String get d => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EccKeyPairCopyWith<EccKeyPair> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EccKeyPairCopyWith<$Res> {
  factory $EccKeyPairCopyWith(
          EccKeyPair value, $Res Function(EccKeyPair) then) =
      _$EccKeyPairCopyWithImpl<$Res, EccKeyPair>;
  @useResult
  $Res call({String publicKey, String d});
}

/// @nodoc
class _$EccKeyPairCopyWithImpl<$Res, $Val extends EccKeyPair>
    implements $EccKeyPairCopyWith<$Res> {
  _$EccKeyPairCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? d = null,
  }) {
    return _then(_value.copyWith(
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EccKeyPairCopyWith<$Res>
    implements $EccKeyPairCopyWith<$Res> {
  factory _$$_EccKeyPairCopyWith(
          _$_EccKeyPair value, $Res Function(_$_EccKeyPair) then) =
      __$$_EccKeyPairCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String publicKey, String d});
}

/// @nodoc
class __$$_EccKeyPairCopyWithImpl<$Res>
    extends _$EccKeyPairCopyWithImpl<$Res, _$_EccKeyPair>
    implements _$$_EccKeyPairCopyWith<$Res> {
  __$$_EccKeyPairCopyWithImpl(
      _$_EccKeyPair _value, $Res Function(_$_EccKeyPair) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? d = null,
  }) {
    return _then(_$_EccKeyPair(
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EccKeyPair implements _EccKeyPair {
  const _$_EccKeyPair({required this.publicKey, required this.d});

  factory _$_EccKeyPair.fromJson(Map<String, dynamic> json) =>
      _$$_EccKeyPairFromJson(json);

  @override
  final String publicKey;
  @override
  final String d;

  @override
  String toString() {
    return 'EccKeyPair(publicKey: $publicKey, d: $d)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EccKeyPair &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.d, d) || other.d == d));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, publicKey, d);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EccKeyPairCopyWith<_$_EccKeyPair> get copyWith =>
      __$$_EccKeyPairCopyWithImpl<_$_EccKeyPair>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EccKeyPairToJson(
      this,
    );
  }
}

abstract class _EccKeyPair implements EccKeyPair {
  const factory _EccKeyPair(
      {required final String publicKey,
      required final String d}) = _$_EccKeyPair;

  factory _EccKeyPair.fromJson(Map<String, dynamic> json) =
      _$_EccKeyPair.fromJson;

  @override
  String get publicKey;
  @override
  String get d;
  @override
  @JsonKey(ignore: true)
  _$$_EccKeyPairCopyWith<_$_EccKeyPair> get copyWith =>
      throw _privateConstructorUsedError;
}
