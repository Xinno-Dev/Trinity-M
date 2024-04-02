//
//  Generated code. Do not modify.
//  source: trx_pb.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use trxProtoDescriptor instead')
const TrxProto$json = {
  '1': 'TrxProto',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 13, '10': 'version'},
    {'1': 'time', '3': 2, '4': 1, '5': 3, '10': 'time'},
    {'1': 'nonce', '3': 3, '4': 1, '5': 4, '10': 'nonce'},
    {'1': 'from', '3': 4, '4': 1, '5': 12, '10': 'from'},
    {'1': 'to', '3': 5, '4': 1, '5': 12, '10': 'to'},
    {'1': '_amount', '3': 6, '4': 1, '5': 12, '10': 'Amount'},
    {'1': 'gas', '3': 7, '4': 1, '5': 4, '10': 'gas'},
    {'1': '_gasPrice', '3': 8, '4': 1, '5': 12, '10': 'GasPrice'},
    {'1': 'type', '3': 9, '4': 1, '5': 5, '10': 'type'},
    {'1': '_payload', '3': 10, '4': 1, '5': 12, '10': 'Payload'},
    {'1': 'sig', '3': 11, '4': 1, '5': 12, '10': 'sig'},
  ],
};

/// Descriptor for `TrxProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxProtoDescriptor = $convert.base64Decode(
    'CghUcnhQcm90bxIYCgd2ZXJzaW9uGAEgASgNUgd2ZXJzaW9uEhIKBHRpbWUYAiABKANSBHRpbW'
    'USFAoFbm9uY2UYAyABKARSBW5vbmNlEhIKBGZyb20YBCABKAxSBGZyb20SDgoCdG8YBSABKAxS'
    'AnRvEhcKB19hbW91bnQYBiABKAxSBkFtb3VudBIQCgNnYXMYByABKARSA2dhcxIbCglfZ2FzUH'
    'JpY2UYCCABKAxSCEdhc1ByaWNlEhIKBHR5cGUYCSABKAVSBHR5cGUSGQoIX3BheWxvYWQYCiAB'
    'KAxSB1BheWxvYWQSEAoDc2lnGAsgASgMUgNzaWc=');

@$core.Deprecated('Use trxPayloadAssetTransferProtoDescriptor instead')
const TrxPayloadAssetTransferProto$json = {
  '1': 'TrxPayloadAssetTransferProto',
};

/// Descriptor for `TrxPayloadAssetTransferProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadAssetTransferProtoDescriptor = $convert.base64Decode(
    'ChxUcnhQYXlsb2FkQXNzZXRUcmFuc2ZlclByb3Rv');

@$core.Deprecated('Use trxPayloadStakingProtoDescriptor instead')
const TrxPayloadStakingProto$json = {
  '1': 'TrxPayloadStakingProto',
};

/// Descriptor for `TrxPayloadStakingProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadStakingProtoDescriptor = $convert.base64Decode(
    'ChZUcnhQYXlsb2FkU3Rha2luZ1Byb3Rv');

@$core.Deprecated('Use trxPayloadUnstakingProtoDescriptor instead')
const TrxPayloadUnstakingProto$json = {
  '1': 'TrxPayloadUnstakingProto',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 12, '10': 'txHash'},
  ],
};

/// Descriptor for `TrxPayloadUnstakingProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadUnstakingProtoDescriptor = $convert.base64Decode(
    'ChhUcnhQYXlsb2FkVW5zdGFraW5nUHJvdG8SFwoHdHhfaGFzaBgBIAEoDFIGdHhIYXNo');

@$core.Deprecated('Use trxPayloadWithdrawProtoDescriptor instead')
const TrxPayloadWithdrawProto$json = {
  '1': 'TrxPayloadWithdrawProto',
  '2': [
    {'1': '_reqAmt', '3': 1, '4': 1, '5': 12, '10': 'ReqAmt'},
  ],
};

/// Descriptor for `TrxPayloadWithdrawProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadWithdrawProtoDescriptor = $convert.base64Decode(
    'ChdUcnhQYXlsb2FkV2l0aGRyYXdQcm90bxIXCgdfcmVxQW10GAEgASgMUgZSZXFBbXQ=');

@$core.Deprecated('Use trxPayloadContractProtoDescriptor instead')
const TrxPayloadContractProto$json = {
  '1': 'TrxPayloadContractProto',
  '2': [
    {'1': '_data', '3': 1, '4': 1, '5': 12, '10': 'Data'},
    {'1': 'token', '3': 2, '4': 1, '5': 12, '10': 'token'},
    {'1': 'from', '3': 3, '4': 1, '5': 12, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 12, '10': 'to'},
    {'1': 'amount', '3': 5, '4': 1, '5': 12, '10': 'amount'},
    {'1': 'decimal', '3': 6, '4': 1, '5': 12, '10': 'decimal'},
  ],
};

/// Descriptor for `TrxPayloadContractProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadContractProtoDescriptor = $convert.base64Decode(
    'ChdUcnhQYXlsb2FkQ29udHJhY3RQcm90bxITCgVfZGF0YRgBIAEoDFIERGF0YRIUCgV0b2tlbh'
    'gCIAEoDFIFdG9rZW4SEgoEZnJvbRgDIAEoDFIEZnJvbRIOCgJ0bxgEIAEoDFICdG8SFgoGYW1v'
    'dW50GAUgASgMUgZhbW91bnQSGAoHZGVjaW1hbBgGIAEoDFIHZGVjaW1hbA==');

@$core.Deprecated('Use trxPayloadProposalProtoDescriptor instead')
const TrxPayloadProposalProto$json = {
  '1': 'TrxPayloadProposalProto',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'start_voting_height', '3': 2, '4': 1, '5': 3, '10': 'startVotingHeight'},
    {'1': 'voting_blocks', '3': 3, '4': 1, '5': 3, '10': 'votingBlocks'},
    {'1': 'applying_height', '3': 6, '4': 1, '5': 3, '10': 'applyingHeight'},
    {'1': 'opt_type', '3': 4, '4': 1, '5': 5, '10': 'optType'},
    {'1': 'options', '3': 5, '4': 3, '5': 12, '10': 'options'},
  ],
};

/// Descriptor for `TrxPayloadProposalProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadProposalProtoDescriptor = $convert.base64Decode(
    'ChdUcnhQYXlsb2FkUHJvcG9zYWxQcm90bxIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdlEi4KE3'
    'N0YXJ0X3ZvdGluZ19oZWlnaHQYAiABKANSEXN0YXJ0Vm90aW5nSGVpZ2h0EiMKDXZvdGluZ19i'
    'bG9ja3MYAyABKANSDHZvdGluZ0Jsb2NrcxInCg9hcHBseWluZ19oZWlnaHQYBiABKANSDmFwcG'
    'x5aW5nSGVpZ2h0EhkKCG9wdF90eXBlGAQgASgFUgdvcHRUeXBlEhgKB29wdGlvbnMYBSADKAxS'
    'B29wdGlvbnM=');

@$core.Deprecated('Use trxPayloadVotingProtoDescriptor instead')
const TrxPayloadVotingProto$json = {
  '1': 'TrxPayloadVotingProto',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 12, '10': 'txHash'},
    {'1': 'choice', '3': 2, '4': 1, '5': 5, '10': 'choice'},
  ],
};

/// Descriptor for `TrxPayloadVotingProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadVotingProtoDescriptor = $convert.base64Decode(
    'ChVUcnhQYXlsb2FkVm90aW5nUHJvdG8SFwoHdHhfaGFzaBgBIAEoDFIGdHhIYXNoEhYKBmNob2'
    'ljZRgCIAEoBVIGY2hvaWNl');

@$core.Deprecated('Use trxPayloadSetDocProtoDescriptor instead')
const TrxPayloadSetDocProto$json = {
  '1': 'TrxPayloadSetDocProto',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `TrxPayloadSetDocProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trxPayloadSetDocProtoDescriptor = $convert.base64Decode(
    'ChVUcnhQYXlsb2FkU2V0RG9jUHJvdG8SEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKA'
    'lSA3VybA==');

