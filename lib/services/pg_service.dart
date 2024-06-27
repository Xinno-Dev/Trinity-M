import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/const/constants.dart';
import '../common/const/utils/convertHelper.dart';

class DanalApiService {
  static final _singleton = DanalApiService._internal();
  factory DanalApiService() {
    return _singleton;
  }
  DanalApiService._internal();

  var httpUrl = PG_HOST;

  final RESPONSE_SUCCESS = 200;
  final RESPONSE_SUCCESS_EX = 201;

  isSuccess(statusCode) {
    return INT(statusCode) == RESPONSE_SUCCESS ||
        INT(statusCode) == RESPONSE_SUCCESS_EX;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 중복 체크
  //  /users/email/{email}/dup
  //

  Future<bool> orderTest() async {
    try {
      LOG('--> API orderTest');
      final response = await http.get(
        Uri.parse(httpUrl + '/Order.php'),
      );
      LOG('--> API orderTest response : ${response.statusCode} / ${response
          .body}');
      if (isSuccess(response.statusCode)) {
        return BOL(jsonDecode(response.body)['result']);
      }
    } catch (e) {
      LOG('--> API orderTest error : $e');
    }
    return false;
  }
}