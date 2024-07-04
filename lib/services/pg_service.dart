import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../common/const/constants.dart';
import '../common/const/utils/convertHelper.dart';

class DanalApiService {
  static final _singleton = DanalApiService._internal();
  factory DanalApiService() {
    return _singleton;
  }
  DanalApiService._internal();

  final _host = IS_DEV_MODE ? CP_HOST_DEV : CP_HOST;

  final RESPONSE_SUCCESS = 200;
  final RESPONSE_SUCCESS_EX = 201;

  isSuccess(statusCode) {
    return INT(statusCode) == RESPONSE_SUCCESS ||
        INT(statusCode) == RESPONSE_SUCCESS_EX;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  구매 취소
  //

  Future<JSON?> cancelPurchase(String tid) async {
    LOG('--> API cancelPurchase : $tid');
    try {
      final response = await http.get(
        Uri.parse(_host + '/cancel?tid=$tid&amount=100'),
      );
      LOG('--> API cancelPurchase response : ${response.statusCode} / ${response.body}');
      return {
        'result': '0000'
      };
    } catch (e) {
      LOG('--> API cancelPurchase error : $e');
    }
    return null;
  }
}