
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/provider/login_provider.dart';

import '../common/const/constants.dart';
import '../common/const/utils/appVersionHelper.dart';
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

  var httpUrl = IS_DEV_MODE ? LARBA_API_HOST_DEV : LARBA_API_HOST;

  isSuccess(statusCode) {
    return INT(statusCode) == 200 || INT(statusCode) == 201;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 중복 체크
  //  /users/email/{email}/dup
  //

  Future<bool> checkEmail(String email) async {
    try {
      LOG('--> checkEmail : $email');
      final response = await http.get(
        Uri.parse(httpUrl + '/users/email/${email}/dup'),
      );
      LOG('--> checkEmail response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        return BOL(jsonDecode(response.body)['result']);
      }
    } catch (e) {
      LOG('--> checkEmail error : $e');
    }
    return false;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 인증코드 전송
  //  /users/email/vfcode
  //

  Future<bool> sendEmailVfCode(String email, String vfCode) async {
    try {
      LOG('--> sendEmailVfCode : $email / $vfCode');
      final response = await http.post(
        Uri.parse(httpUrl + '/users/email/vfcode'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'vfCode': vfCode
        })
      );
      LOG('--> sendEmailVfCode response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        return true;
      }
    } catch (e) {
      LOG('--> sendEmailVfCode error : $e');
    }
    return false;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  Email 인증링크 클릭
  //  /users/email/vflink/{vfLinkID}
  //

  sendEmailVfCodeLink(String sha256Token) async {
    try {
      LOG('--> sendEmailVfCodeLink : $sha256Token');
      final response = await http.get(
          Uri.parse(httpUrl + '/users/email/vflink/{$sha256Token}'),
      );
      LOG('--> sendEmailVfCodeLink response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
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
  //  /users/email/{email}/dup
  //

  Future<bool?> checkEmailVfComplete(String vfCode) async {
    try {
      LOG('--> checkEmailVfComplete : $vfCode');
      final response = await http.get(
        Uri.parse(httpUrl + '/users/email/vfcode/${vfCode}'),
      );
      LOG('--> checkEmailVfComplete response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        var json = jsonDecode(response.body);
        var result = json['result'] != null ? STR(json['result']['email']) : '';
        LOG('--> checkEmailVfComplete result : ${json['result']}');
        return result.isNotEmpty;
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
        Uri.parse(httpUrl + '/users/nick/$nickId/dup'),
      );
      LOG('--> checkNickname response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        var result = BOL(jsonDecode(response.body)['result']);
        return !result;
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

  Future<String?> createUser(
    String name,
    String socialNo,
    String email,
    String nickId,
    String subTitle,
    String desc,
    String address,
    String sig,
    String type,
    String authToken,
    {
      Function(LoginErrorType, String?)? onError,
    }
  ) async {
    try {
      LOG('--> createUser : $name, $socialNo, $email, $nickId, '
          '$subTitle, $desc, $address, $sig, $type, $authToken');
      final response = await http.post(
          Uri.parse(httpUrl + '/users/createUser'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name':         name,
            'socialNo':     socialNo,
            'email':        email,
            'nickId':       nickId,
            'subTitle':     subTitle,
            'description':  desc,
            'address':      address,
            'sig':          sig,
            'type':         type,
            'authToken':    authToken,
          })
      );
      LOG('--> createUser response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        var resultJson = jsonDecode(response.body);
        var uId   = STR(resultJson['result']);
        var error = STR(resultJson['error' ]);
        LOG('--> createUser result : $uId / $error');
        if (error.isNotEmpty && onError != null) onError(LoginErrorType.signupFail, error);
        return uId.isNotEmpty ? uId : null; // null is success
      }
    } catch (e) {
      LOG('--> createUser error : $e');
    }
    return 'createUser error';
  }


  //////////////////////////////////////////////////////////////////////////
  //
  //  유저 로그인 Secret Key
  //  /auth/nick/{nickId}/secret-key
  //

  Future<String?> getSecretKey(
      String nickId,
      String publicKey,
    ) async {
    try {
      LOG('--> getSecretKey : $nickId / $publicKey');
      final response = await http.post(
        Uri.parse(httpUrl + '/auth/nick/$nickId/secret-key'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pubKey': publicKey,
        })
      );
      LOG('--> getSecretKey response : ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        var resultJson = jsonDecode(response.body);
        if (resultJson['result'] != null) {
          var serverKey = STR(resultJson['result']['pubKey']);
          return serverKey;
        }
      }
    } catch (e) {
      LOG('--> getSecretKey error : $e');
    }
    return null;
  }


  //////////////////////////////////////////////////////////////////////////
  //
  //  유저 로그인
  //  /auth/signIn/{email}
  //

  Future<bool> loginUser(
      String nickId,
      String type,
      String email,
      String authToken, // or Sig (for email)
      {
        Function(LoginErrorType, String?)? onError,
      }
    ) async {
    try {
      LOG('------> API loginUser [$email] : $nickId, $type, $authToken');
      final response = await http.post(
        Uri.parse(httpUrl + '/auth/signIn/$email'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': type,
          'authToken': authToken,
          'nickId': nickId,
        })
      );
      LOG('--> API loginUser response :'
          ' ${response.statusCode} / ${response.body}');
      if (isSuccess(response.statusCode)) {
        var resultJson = jsonDecode(response.body);
        if (resultJson['result'] != null) {
          var jwt       = STR(resultJson['result']['jwt']);
          var uid       = STR(resultJson['result']['uid']);
          var pass      = await AesManager().deviceIdPass;
          var jwtEnc    = await AesManager().encrypt(pass, jwt);
          await UserHelper().setUser(jwt: jwtEnc);
          await UserHelper().setUser(uid: uid);
          LOG('--> API loginUser success [$type] : $pass => $jwt');
          return true;
        } else {
          var error = STR(resultJson['error' ]);
          LOG('--> API loginUser error : $error');
          if (onError != null) onError(LoginErrorType.text, error);
          return false;
        }
      }
    } catch (e) {
      LOG('--> API loginUser error : $e');
    }
    return false;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  유저 Nick 추가
  //  /users/nick/{newNickId}
  //

  Future<bool> addAccount(
      String nickId,
      String address,
      String sig,
    {
      String? subTitle,
      String? desc,
    }
  ) async {
    var jwt = await AesManager().localJwt;
    if (jwt == null) {
      return false;
    }
    LOG('--> addAccount : $nickId, $address, $sig / $subTitle, $desc - $jwt');
    if (STR(jwt).isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(httpUrl + '/users/nick/$nickId'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode({
            'address'     : address,
            'sig'         : sig,
            'subTitle'    : subTitle ?? '',
            'description' : desc ?? '',
          })
        );
        LOG('--> addAddress response : ${response.statusCode} / ${response
            .body}');
        if (isSuccess(response.statusCode)) {
          var result = jsonDecode(response.body)['result'];
          return STR(result['address']).isNotEmpty;
        }
      } catch (e) {
        LOG('--> addAddress error : $e');
      }
    }
    return false;
  }

}