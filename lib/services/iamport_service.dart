
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import '../common/const/utils/convertHelper.dart';

//////////////////////////////////////////////////////////////////////////
//
//  본인인증 확인
//  GET: /certifications/{imp_uid}
//

class IamPortApiService {
  static final IamPortApiService _singleton = IamPortApiService._internal();
  factory IamPortApiService() {
    return _singleton;
  }
  IamPortApiService._internal();

  final httpUrl    = 'https://api.iamport.kr';
  // final secretKey  = '1387052246675258';
  // final secretCode = 'O8P7PJu0dSIMwY8ZNRbApfPuN11pQ4Uno2vAqJPKyy7oR3TQoacEul0EpMXODpUHDYXkFKRhe0ysL3O8';
  final secretKey  = '1387052246675258';
  final secretCode = 'O8P7PJu0dSIMwY8ZNRbApfPuN11pQ4Uno2vAqJPKyy7oR3TQoacEul0EpMXODpUHDYXkFKRhe0ysL3O8';

  isSuccess(statusCode) {
    return INT(statusCode) == 200 || INT(statusCode) == 201;
  }

  Future<JSON?> checkCert(String impUid) async {
    try {
      var urlStr = '/users/getToken';
      LOG('--> API checkCert : $impUid');
      final response = await http.post(
          Uri.parse(httpUrl + urlStr),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'imp_key': secretKey,
            'imp_secret': secretCode,
          })
      );
      LOG('--> API checkCert response : ${response.statusCode} / ${response.body}');
      var message = STR(jsonDecode(response.body)['message']);
      LOG('---> result message : ${decoding(message)}');
    } catch (e) {
      LOG('--> API checkCert error : $e');
    }
    return null;
  }

  String decoding(String decodedText, [var decimals = 18]) {
    var result = '0';
    try {
      result = (double.parse(decodedText) / pow(10, decimals)).toStringAsFixed(decimals);
      // print('---> getTokenBalanceNo64 : $decodedText -> $result');
    } catch (e) {
      print('---> getTokenBalanceNo64 error : $e');
    }
    return result;
  }
}
