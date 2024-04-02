
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/const/utils/convertHelper.dart';

//////////////////////////////////////////////////////////////////////////
//
//  LARBA Api Methods
//


final LARBA_RESPONSE_SUCCESS = 200;

class LarbaApiService {
  static final LarbaApiService _singleton = LarbaApiService._internal();
  factory LarbaApiService() {
    return _singleton;
  }
  LarbaApiService._internal();

  var httpUrl = '';

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 중복 체크
  //  /user/email/{email}/dup
  //

  checkEmail(String email) async {
    try {
      LOG('--> checkEmail : $email');
      final response = await http.get(
          Uri.parse(httpUrl + '/user/email/${email}/dup'),
      );
      LOG('--> checkEmail response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = BOL(jsonDecode(response.body)['result']);
        return result;
      }
    } catch (e) {
      LOG('--> checkEmail error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 인증코드 전송
  //  /user/email/vfcode
  //

  sendEmailVfCode(String email, String vfCode) async {
    try {
      LOG('--> sendEmailVfCode : $email / $vfCode');
      final response = await http.post(
        Uri.parse(httpUrl + '/user/email/vfcode'),
        headers: {'accept': 'application/json'},
        body: {
          'email': email,
          'vfCode': vfCode,
        }
      );
      LOG('--> sendEmailVfCode response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = jsonDecode(response.body)['result'];
        return result;
      }
    } catch (e) {
      LOG('--> sendEmailVfCode error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 인증링크 클릭
  //  /user/email/vflink/{vfLinkID}
  //

  sendEmailVfCodeLink(String sha256Token) async {
    try {
      LOG('--> sendEmailVfCodeLink : $sha256Token');
      final response = await http.get(
          Uri.parse(httpUrl + '/user/email/vflink/{$sha256Token}'),
      );
      LOG('--> sendEmailVfCodeLink response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = jsonDecode(response.body)['result'];
        return result;
      }
    } catch (e) {
      LOG('--> sendEmailVfCodeLink error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 인증 완료 여부
  //  /user/email/{email}/dup
  //

  checkEmailVfComplete(String vfCode) async {
    try {
      LOG('--> checkEmailVfComplete : $vfCode');
      final response = await http.get(
        Uri.parse(httpUrl + '/user/email/vfcode/${vfCode}'),
      );
      LOG('--> checkEmailVfComplete response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = BOL(jsonDecode(response.body)['result']);
        return result;
      }
    } catch (e) {
      LOG('--> checkEmailVfComplete error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Nick 중복 체크
  //  /nick/{nickId}/dup
  //

  checkNickname(String nickId) async {
    try {
      LOG('--> checkNickname : $nickId');
      final response = await http.get(
        Uri.parse(httpUrl + ' /nick/${nickId}/dup'),
      );
      LOG('--> checkNickname response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = BOL(jsonDecode(response.body)['result']);
        return result;
      }
    } catch (e) {
      LOG('--> checkNickname error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  유저 생성
  //  /user
  //

  createUser(
    String name,
    String socialNo,
    String email,
    String nickId,
    String address,
    String sig) async {
    try {
      LOG('--> createUser : $name, $socialNo, $email, $nickId, $address, $sig');
      final response = await http.post(
          Uri.parse(httpUrl + '/user'),
          headers: {'accept': 'application/json'},
          body: {
            'name':     name,
            'socialNo': socialNo,
            'email':    email,
            'nickId':   nickId,
            'address':  address,
            'sig':      sig,
          }
      );
      LOG('--> createUser response : ${response.statusCode} / ${response.body}');
      if (INT(response.statusCode) == LARBA_RESPONSE_SUCCESS) {
        var result = jsonDecode(response.body)['result'];
        return result;
      }
    } catch (e) {
      LOG('--> createUser error : $e');
    }
    return null;
  }


}