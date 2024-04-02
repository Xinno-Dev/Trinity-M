//
//  Generated code. Do not modify.
//  source: trx_pb.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class TrxProto extends $pb.GeneratedMessage {
  factory TrxProto({
    $core.int? version,
    $fixnum.Int64? time,
    $fixnum.Int64? nonce,
    $core.List<$core.int>? from,
    $core.List<$core.int>? to,
    $core.List<$core.int>? amount,
    $fixnum.Int64? gas,
    $core.List<$core.int>? gasPrice,
    $core.int? type,
    $core.List<$core.int>? payload,
    $core.List<$core.int>? sig,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (time != null) {
      $result.time = time;
    }
    if (nonce != null) {
      $result.nonce = nonce;
    }
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (gas != null) {
      $result.gas = gas;
    }
    if (gasPrice != null) {
      $result.gasPrice = gasPrice;
    }
    if (type != null) {
      $result.type = type;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (sig != null) {
      $result.sig = sig;
    }
    return $result;
  }
  TrxProto._() : super();
  factory TrxProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'time')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'from', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'to', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'Amount', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'gas', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'GasPrice', $pb.PbFieldType.OY, protoName: '_gasPrice')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(10, _omitFieldNames ? '' : 'Payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(11, _omitFieldNames ? '' : 'sig', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxProto clone() => TrxProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxProto copyWith(void Function(TrxProto) updates) => super.copyWith((message) => updates(message as TrxProto)) as TrxProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxProto create() => TrxProto._();
  TrxProto createEmptyInstance() => create();
  static $pb.PbList<TrxProto> createRepeated() => $pb.PbList<TrxProto>();
  @$core.pragma('dart2js:noInline')
  static TrxProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxProto>(create);
  static TrxProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get time => $_getI64(1);
  @$pb.TagNumber(2)
  set time($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get nonce => $_getI64(2);
  @$pb.TagNumber(3)
  set nonce($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNonce() => $_has(2);
  @$pb.TagNumber(3)
  void clearNonce() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get from => $_getN(3);
  @$pb.TagNumber(4)
  set from($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFrom() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrom() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get to => $_getN(4);
  @$pb.TagNumber(5)
  set to($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTo() => $_has(4);
  @$pb.TagNumber(5)
  void clearTo() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get amount => $_getN(5);
  @$pb.TagNumber(6)
  set amount($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get gas => $_getI64(6);
  @$pb.TagNumber(7)
  set gas($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasGas() => $_has(6);
  @$pb.TagNumber(7)
  void clearGas() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get gasPrice => $_getN(7);
  @$pb.TagNumber(8)
  set gasPrice($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasGasPrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearGasPrice() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get type => $_getIZ(8);
  @$pb.TagNumber(9)
  set type($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.int> get payload => $_getN(9);
  @$pb.TagNumber(10)
  set payload($core.List<$core.int> v) { $_setBytes(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasPayload() => $_has(9);
  @$pb.TagNumber(10)
  void clearPayload() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<$core.int> get sig => $_getN(10);
  @$pb.TagNumber(11)
  set sig($core.List<$core.int> v) { $_setBytes(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSig() => $_has(10);
  @$pb.TagNumber(11)
  void clearSig() => clearField(11);
}

class TrxPayloadAssetTransferProto extends $pb.GeneratedMessage {
  factory TrxPayloadAssetTransferProto() => create();
  TrxPayloadAssetTransferProto._() : super();
  factory TrxPayloadAssetTransferProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadAssetTransferProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadAssetTransferProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadAssetTransferProto clone() => TrxPayloadAssetTransferProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadAssetTransferProto copyWith(void Function(TrxPayloadAssetTransferProto) updates) => super.copyWith((message) => updates(message as TrxPayloadAssetTransferProto)) as TrxPayloadAssetTransferProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadAssetTransferProto create() => TrxPayloadAssetTransferProto._();
  TrxPayloadAssetTransferProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadAssetTransferProto> createRepeated() => $pb.PbList<TrxPayloadAssetTransferProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadAssetTransferProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadAssetTransferProto>(create);
  static TrxPayloadAssetTransferProto? _defaultInstance;
}

class TrxPayloadStakingProto extends $pb.GeneratedMessage {
  factory TrxPayloadStakingProto() => create();
  TrxPayloadStakingProto._() : super();
  factory TrxPayloadStakingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadStakingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadStakingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadStakingProto clone() => TrxPayloadStakingProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadStakingProto copyWith(void Function(TrxPayloadStakingProto) updates) => super.copyWith((message) => updates(message as TrxPayloadStakingProto)) as TrxPayloadStakingProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadStakingProto create() => TrxPayloadStakingProto._();
  TrxPayloadStakingProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadStakingProto> createRepeated() => $pb.PbList<TrxPayloadStakingProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadStakingProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadStakingProto>(create);
  static TrxPayloadStakingProto? _defaultInstance;
}

class TrxPayloadUnstakingProto extends $pb.GeneratedMessage {
  factory TrxPayloadUnstakingProto({
    $core.List<$core.int>? txHash,
  }) {
    final $result = create();
    if (txHash != null) {
      $result.txHash = txHash;
    }
    return $result;
  }
  TrxPayloadUnstakingProto._() : super();
  factory TrxPayloadUnstakingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadUnstakingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadUnstakingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txHash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadUnstakingProto clone() => TrxPayloadUnstakingProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadUnstakingProto copyWith(void Function(TrxPayloadUnstakingProto) updates) => super.copyWith((message) => updates(message as TrxPayloadUnstakingProto)) as TrxPayloadUnstakingProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadUnstakingProto create() => TrxPayloadUnstakingProto._();
  TrxPayloadUnstakingProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadUnstakingProto> createRepeated() => $pb.PbList<TrxPayloadUnstakingProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadUnstakingProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadUnstakingProto>(create);
  static TrxPayloadUnstakingProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txHash => $_getN(0);
  @$pb.TagNumber(1)
  set txHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => clearField(1);
}

class TrxPayloadWithdrawProto extends $pb.GeneratedMessage {
  factory TrxPayloadWithdrawProto({
    $core.List<$core.int>? reqAmt,
  }) {
    final $result = create();
    if (reqAmt != null) {
      $result.reqAmt = reqAmt;
    }
    return $result;
  }
  TrxPayloadWithdrawProto._() : super();
  factory TrxPayloadWithdrawProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadWithdrawProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadWithdrawProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'ReqAmt', $pb.PbFieldType.OY, protoName: '_reqAmt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadWithdrawProto clone() => TrxPayloadWithdrawProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadWithdrawProto copyWith(void Function(TrxPayloadWithdrawProto) updates) => super.copyWith((message) => updates(message as TrxPayloadWithdrawProto)) as TrxPayloadWithdrawProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadWithdrawProto create() => TrxPayloadWithdrawProto._();
  TrxPayloadWithdrawProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadWithdrawProto> createRepeated() => $pb.PbList<TrxPayloadWithdrawProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadWithdrawProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadWithdrawProto>(create);
  static TrxPayloadWithdrawProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get reqAmt => $_getN(0);
  @$pb.TagNumber(1)
  set reqAmt($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReqAmt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReqAmt() => clearField(1);
}

class TrxPayloadContractProto extends $pb.GeneratedMessage {
  factory TrxPayloadContractProto({
    $core.List<$core.int>? data,
    $core.List<$core.int>? token,
    $core.List<$core.int>? from,
    $core.List<$core.int>? to,
    $core.List<$core.int>? amount,
    $core.List<$core.int>? decimal,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (token != null) {
      $result.token = token;
    }
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (decimal != null) {
      $result.decimal = decimal;
    }
    return $result;
  }
  TrxPayloadContractProto._() : super();
  factory TrxPayloadContractProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadContractProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadContractProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'Data', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'token', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'from', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'to', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'decimal', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadContractProto clone() => TrxPayloadContractProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadContractProto copyWith(void Function(TrxPayloadContractProto) updates) => super.copyWith((message) => updates(message as TrxPayloadContractProto)) as TrxPayloadContractProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadContractProto create() => TrxPayloadContractProto._();
  TrxPayloadContractProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadContractProto> createRepeated() => $pb.PbList<TrxPayloadContractProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadContractProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadContractProto>(create);
  static TrxPayloadContractProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get token => $_getN(1);
  @$pb.TagNumber(2)
  set token($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get from => $_getN(2);
  @$pb.TagNumber(3)
  set from($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get to => $_getN(3);
  @$pb.TagNumber(4)
  set to($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get amount => $_getN(4);
  @$pb.TagNumber(5)
  set amount($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get decimal => $_getN(5);
  @$pb.TagNumber(6)
  set decimal($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDecimal() => $_has(5);
  @$pb.TagNumber(6)
  void clearDecimal() => clearField(6);
}

class TrxPayloadProposalProto extends $pb.GeneratedMessage {
  factory TrxPayloadProposalProto({
    $core.String? message,
    $fixnum.Int64? startVotingHeight,
    $fixnum.Int64? votingBlocks,
    $core.int? optType,
    $core.Iterable<$core.List<$core.int>>? options,
    $fixnum.Int64? applyingHeight,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (startVotingHeight != null) {
      $result.startVotingHeight = startVotingHeight;
    }
    if (votingBlocks != null) {
      $result.votingBlocks = votingBlocks;
    }
    if (optType != null) {
      $result.optType = optType;
    }
    if (options != null) {
      $result.options.addAll(options);
    }
    if (applyingHeight != null) {
      $result.applyingHeight = applyingHeight;
    }
    return $result;
  }
  TrxPayloadProposalProto._() : super();
  factory TrxPayloadProposalProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadProposalProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadProposalProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aInt64(2, _omitFieldNames ? '' : 'startVotingHeight')
    ..aInt64(3, _omitFieldNames ? '' : 'votingBlocks')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'optType', $pb.PbFieldType.O3)
    ..p<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'options', $pb.PbFieldType.PY)
    ..aInt64(6, _omitFieldNames ? '' : 'applyingHeight')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadProposalProto clone() => TrxPayloadProposalProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadProposalProto copyWith(void Function(TrxPayloadProposalProto) updates) => super.copyWith((message) => updates(message as TrxPayloadProposalProto)) as TrxPayloadProposalProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadProposalProto create() => TrxPayloadProposalProto._();
  TrxPayloadProposalProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadProposalProto> createRepeated() => $pb.PbList<TrxPayloadProposalProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadProposalProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadProposalProto>(create);
  static TrxPayloadProposalProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startVotingHeight => $_getI64(1);
  @$pb.TagNumber(2)
  set startVotingHeight($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartVotingHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartVotingHeight() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get votingBlocks => $_getI64(2);
  @$pb.TagNumber(3)
  set votingBlocks($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVotingBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearVotingBlocks() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get optType => $_getIZ(3);
  @$pb.TagNumber(4)
  set optType($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOptType() => $_has(3);
  @$pb.TagNumber(4)
  void clearOptType() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.List<$core.int>> get options => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get applyingHeight => $_getI64(5);
  @$pb.TagNumber(6)
  set applyingHeight($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasApplyingHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearApplyingHeight() => clearField(6);
}

class TrxPayloadVotingProto extends $pb.GeneratedMessage {
  factory TrxPayloadVotingProto({
    $core.List<$core.int>? txHash,
    $core.int? choice,
  }) {
    final $result = create();
    if (txHash != null) {
      $result.txHash = txHash;
    }
    if (choice != null) {
      $result.choice = choice;
    }
    return $result;
  }
  TrxPayloadVotingProto._() : super();
  factory TrxPayloadVotingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadVotingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadVotingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txHash', $pb.PbFieldType.OY)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'choice', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadVotingProto clone() => TrxPayloadVotingProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadVotingProto copyWith(void Function(TrxPayloadVotingProto) updates) => super.copyWith((message) => updates(message as TrxPayloadVotingProto)) as TrxPayloadVotingProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadVotingProto create() => TrxPayloadVotingProto._();
  TrxPayloadVotingProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadVotingProto> createRepeated() => $pb.PbList<TrxPayloadVotingProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadVotingProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadVotingProto>(create);
  static TrxPayloadVotingProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txHash => $_getN(0);
  @$pb.TagNumber(1)
  set txHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get choice => $_getIZ(1);
  @$pb.TagNumber(2)
  set choice($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChoice() => $_has(1);
  @$pb.TagNumber(2)
  void clearChoice() => clearField(2);
}

class TrxPayloadSetDocProto extends $pb.GeneratedMessage {
  factory TrxPayloadSetDocProto({
    $core.String? name,
    $core.String? url,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (url != null) {
      $result.url = url;
    }
    return $result;
  }
  TrxPayloadSetDocProto._() : super();
  factory TrxPayloadSetDocProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TrxPayloadSetDocProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TrxPayloadSetDocProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'types'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TrxPayloadSetDocProto clone() => TrxPayloadSetDocProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TrxPayloadSetDocProto copyWith(void Function(TrxPayloadSetDocProto) updates) => super.copyWith((message) => updates(message as TrxPayloadSetDocProto)) as TrxPayloadSetDocProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrxPayloadSetDocProto create() => TrxPayloadSetDocProto._();
  TrxPayloadSetDocProto createEmptyInstance() => create();
  static $pb.PbList<TrxPayloadSetDocProto> createRepeated() => $pb.PbList<TrxPayloadSetDocProto>();
  @$core.pragma('dart2js:noInline')
  static TrxPayloadSetDocProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrxPayloadSetDocProto>(create);
  static TrxPayloadSetDocProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
