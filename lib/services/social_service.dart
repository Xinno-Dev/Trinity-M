import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:firebase_auth/firebase_auth.dart' as google;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../common/const/utils/md5Helper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/provider/login_provider.dart';
import '../../../common/rlp/hash.dart';
import 'package:crypto/crypto.dart' as crypto;
import '../../../domain/model/user_model.dart';
import '../../../services/google_service.dart';
import 'package:uuid/uuid.dart';

import '../common/const/constants.dart';
import '../common/const/utils/convertHelper.dart';


////////////////////////////////////////////////////////////////////////////////
//
//
//  EMAIL
//
//

Future<String?> startEmailSend(String emailAddr, Function(LoginErrorType) onError) async {
  var vfCode    = crypto.sha256.convert(utf8.encode(emailAddr)).toString();
  var vfCodeStr = emailAddr + vfCode;
  var vfCodeEnc = crypto.sha256.convert(utf8.encode(vfCodeStr));
  if (IS_EMAIL_CHECK) {
    try {
      var host = IS_DEV_MODE ? LARBA_API_HOST_DEV : LARBA_API_HOST;
      LOG('--> startEmailSend [$host] : $vfCodeStr => $vfCodeEnc');
      // final email = Email(
      //   body: 'Email body',
      //   subject: 'Email subject',
      //   recipients: [emailAddr],
      //   // cc: ['cc@example.com'],
      //   // bcc: ['bcc@example.com'],
      //   // attachmentPaths: ['/path/to/attachment.zip'],
      //   isHTML: false,
      // );
      // FlutterEmailSender.send(email)
      //   .onError((error, stackTrace) {
      //     LOG('---> email send error : $error');
      //     onResult(null);
      //   }).then((value) => onResult(vfCode));
      var acs = ActionCodeSettings(
          url: '${host}/users/email/vflink/$vfCodeEnc',
          handleCodeInApp: true,
          iOSBundleId: 'com.xinno.trinity_m_00',
          androidPackageName: 'com.xinno.trinity_m_00',
          androidInstallApp: true,
          androidMinimumVersion: '12');
      await FirebaseAuth.instance.sendSignInLinkToEmail(
          email: emailAddr, actionCodeSettings: acs)
          .catchError((error) {
        LOG('--> FirebaseAuth error : $error');
      });
    } catch (e) {
      LOG('--> startEmailLogin error : $e');
      onError(LoginErrorType.mailSend);
      return null;
    }
  }
  LOG('--------> vfCode : $vfCode / $vfCodeEnc');
  // return '768d185a2e8770c15556c36ec6fc9615a62f031e1dbc670de2b4aa11b08eb087';
  return vfCode;
}

startEmailLogin(String emailAuth, Function(bool) onResult) {

}

startEmailLogout() async {

}

////////////////////////////////////////////////////////////////////////////////
//
//
//  KAKAO
//
//


checkKakaoLogin() async {
  try {
    final accessInfo = await kakao.UserApi.instance.accessTokenInfo();
    LOG('--> checkKakaoLogin : $accessInfo');
    if (accessInfo.id != null && accessInfo.expiresIn > 0) {
      return true;
    }
  } catch (e) {
    LOG('--> checkKakaoLogin error : $e');
  }
  return false;
}

startKakaoLogin({Function(String)? onError}) async {
  final isKakaoTalkReady = await kakao.isKakaoTalkInstalled();
  LOG('--> startKakaoLogin $isKakaoTalkReady');
  kakao.OAuthToken? token;
  if (isKakaoTalkReady) {
    try {
      token = await kakao.UserApi.instance.loginWithKakaoTalk();
      LOG('--> 카카오톡으로 로그인 성공 ${token.accessToken}');
    } catch (error) {
      LOG('--> 카카오톡으로 로그인 실패 $error');
      if (error is PlatformException && error.code == 'CANCELED') {
      }
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        LOG('--> 카카오계정으로 로그인 성공 ${token.accessToken}');
      } catch (error) {
        LOG('--> 카카오계정으로 로그인 실패 $error');
      }
    }
  }
  if (token == null) {
    try {
      token = await kakao.UserApi.instance.loginWithKakaoAccount();
      LOG('--> 카카오계정으로 로그인 성공 ${token.accessToken}');
    } catch (error) {
      LOG('--> 카카오계정으로 로그인 실패 $error');
    }
  }
  if (token != null) {
    return await getKakaoUserInfo(token.accessToken);
  }
  return null;
}

startKakaoLogout() async {
  try {
    await kakao.UserApi.instance.unlink();
    return true;
  } catch (e) {
    LOG('--> startKakaoLogout error : $e');
  }
  return false;
}

Future<kakao.User?> getKakaoUserInfo(String token) async {
  try {
    final user = await kakao.UserApi.instance.me();
    LOG('사용자 정보 요청 성공'
        '\n회원ID: ${user.id}'
        '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
        '\n프로필: ${user.kakaoAccount?.profile?.profileImageUrl}'
        '\n이메일: ${user.kakaoAccount?.email}');
    user.properties ??= {};
    user.properties!['token'] = token;
    return user;
  } catch (error) {
    LOG('--> getKakaoUserInfo error : $error');
  }
  return null;
}


////////////////////////////////////////////////////////////////////////////////
//
//
//  GOOGLE
//
//


checkGoogleLogin() async {
  return await getGoogleUserInfo() != null;
}

startGoogleLogin() async {
  // Trigger the authentication flow
  return await GoogleService.signIn();
}

startGoogleLogout() async {
  return await GoogleService.signOut();
}

getGoogleUserInfo() async {
  return await GoogleService.userInfo();
}


////////////////////////////////////////////////////////////////////////////////
//
//
//  FACEBOOK
//
//


checkFacebookLogin() async {
  return false;
}

startFacebookLogin() async {

}

startFacebookLogout() async {

}

getFacebookUserInfo() async {

}


