import 'dart:developer';
import 'dart:math';
import "dart:typed_data";
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

Uint8List createUint8ListFromString(String s) {
  var ret = new Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

Uint8List createUint8ListFromHexString(String hex) {
  var result = new Uint8List(hex.length ~/ 2);
  for (var i = 0; i < hex.length; i += 2) {
    var num = hex.substring(i, i + 2);
    var byte = int.parse(num, radix: 16);
    result[i ~/ 2] = byte;
  }
  return result;
}

Uint8List createUint8ListFromSequentialNumbers(int len) {
  var ret = new Uint8List(len);
  for (var i = 0; i < len; i++) {
    ret[i] = i;
  }
  return ret;
}


//x
Uint8List serializeBigInt(BigInt bi) {
  Uint8List array = Uint8List((bi.bitLength / 8).ceil());
  for (int i = 0; i < array.length; i++) {
    array[i] = (bi >> (i * 8)).toUnsigned(8).toInt();
  }
  return array;
}

//x
Uint8List writeBigInt(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  int bytes = (number.bitLength + 7) >> 3;
  var b256 = BigInt.from(256);
  var result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}

class ConvertHelper {
  Map<String, dynamic> stringToMap(String? str) {
    Map<String, dynamic> val = json.decode(str!);
    return val;
  }
}

String CommaText(value, [int decimal = 8]) {
  if (value == null) return '0';
  var numStr = value is String ? double.parse(value) : value;
  return NumberFormat(',###.${'#' * decimal}').format(numStr);
}

String CommaIntText(value) {
  if (value == null) return '0';
  var numStr = value is String ? double.parse(value) : value;
  return NumberFormat(',###').format(numStr);
}

double balanceFloor(double value, [int decimal = 8]) {
  final String toString = Decimal.parse(value.toString()).toString();
  final List<String> split = toString.split('.');
  final String integer = split[0];

  String tmp = '';
  if (split.length == 2) {
    var length = split[1].length;
    var end = length > decimal ? decimal : length;
    tmp = split[1].substring(0, end);
  }
  final _value = integer + '.' + tmp;
  return double.parse(_value);
}

bool checkSendAmount(String balance, String amount, [int decimal = 18]) {
  var curBalance = getSendAmount(balance, decimal);
  var sendAmount = getSendAmount(amount, decimal);
  return curBalance.toInt() >= sendAmount.toInt();
}

BigInt getSendAmount(String amount, [int decimal = 18]) {
  amount = amount.replaceAll(',', '');
  var result = EtherAmount.inWei(etherToWei(double.parse(amount), decimal)).getInWei;
  print('---> getSendAmount : $amount => $result [$decimal]');
  return result;
}

BigInt etherToWei(double ether, [int decimal = 18]) {
  // print('ether $ether');
  final dEther = Decimal.parse(ether.toString());
  // print('_dEther $_dEther');
  final tmp = dEther * Decimal.fromJson(pow(10, decimal).toString());
  // print('_decimal $_decimal');
  var result = BigInt.parse(tmp.toString());
  return result;
}

class Util {
  static List<int> convertInt2Bytes(value, Endian order, int bytesSize) {
    try {
      final kMaxBytes = 8;
      var bytes = Uint8List(kMaxBytes)
        ..buffer.asByteData().setInt64(0, value, order);
      List<int> intArray;
      if (order == Endian.big) {
        intArray = bytes.sublist(kMaxBytes - bytesSize, kMaxBytes).toList();
      } else {
        intArray = bytes.sublist(0, bytesSize).toList();
      }
      return intArray;
    } catch (e) {
      print('util convert error: $e');
    }
    return [];
  }
}

String removeOxAddr(String? textOrg) {
  final text = STR(textOrg);
  return text.substring(0, 2) == '0x' ? text.substring(2, text.length) : text;
}

String getShortAddressText(String fullAddress, int showCharacterCount) {
  if (fullAddress.substring(0, 2) != '0x') {
    fullAddress = '0x' + fullAddress;
  }
  String front = fullAddress.substring(0, showCharacterCount);
  String back = fullAddress.substring(
      fullAddress.length - showCharacterCount, fullAddress.length);
  return front + '...' + back;
}

String getFormattedText({int decimalPlaces = 0, required num value}) {
  return NumberFormat.currency(
          locale: "ko_KR", symbol: '', decimalDigits: decimalPlaces)
      .format(value);
}

// ignore: non_constant_identifier_names
LOG(String msg) {
  print(msg);
}

// ignore: non_constant_identifier_names
bool BOL(dynamic value, {bool defaultValue = false}) {
  if (value != null && value.runtimeType == bool) return value;
  return value != null && value.runtimeType != Null &&
    value != 'null' && value.toString().isNotEmpty ?
    value.toString() == '1' ||
    value.toLowerCase().toString() == 'on' ||
    value.toLowerCase().toString() == 'true' : defaultValue;
}

// ignore: non_constant_identifier_names
int INT(dynamic value, {int defaultValue = 0}) {
  if (value is double) {
    value = value.toInt();
  }
  return value.runtimeType != Null && value != 'null' &&
    value.toString().isNotEmpty ? int.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
double DBL(dynamic value, {double defaultValue = 0.0}) {
  return value.runtimeType != Null && value != 'null' &&
    value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
String STR(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' &&
      value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  return result;
}

// ignore: non_constant_identifier_names
String ADDR(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' &&
      value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  if (!result.contains('0x')) {
    result =  '0x$result';
  }
  return result;
}

// ignore: non_constant_identifier_names
LIST_NOT_EMPTY(dynamic data) {
  return data != null && List.from(data).isNotEmpty;
}

typedef JSON = Map<String, dynamic>;




