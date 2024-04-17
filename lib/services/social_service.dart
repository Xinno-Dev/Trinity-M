import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:firebase_auth/firebase_auth.dart' as google;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:larba_00/common/const/utils/md5Helper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/rlp/hash.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:larba_00/services/google_service.dart';

import '../common/const/utils/convertHelper.dart';


////////////////////////////////////////////////////////////////////////////////
//
//
//  EMAIL
//
//


checkEmailLogin() async {
  if (FirebaseAuth.instance.currentUser != null) {
    Fluttertoast.showToast(
      msg: "E-Mail 로그인",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
    );
    return true;
  }
  return false;
}

startEmailSend(String emailAuth, Function(String?) onResult) {
  // var vfCode = Uuid().v4();
  // final vfJson = {
  //   'email': emailAuth,
  //   'vfCode': vfCode,
  // };
  // final vfCodeEnc = encryptAES(vfJson.toString());
  var vfCode = 'vfCode-test-0000';
  var vfCodeEnc = crypto.sha256.convert(utf8.encode(vfCode));
  LOG('--> vfCodeEnc : $vfCodeEnc');
  try {
    var acs = ActionCodeSettings(
        url: 'https://exino.com/user/email/vflink?vfcode=$vfCodeEnc',
        handleCodeInApp: true,
        iOSBundleId: 'com.exino.larba_00',
        androidPackageName: 'com.exino.larba_00',
        androidInstallApp: true,
        androidMinimumVersion: '12');
    FirebaseAuth.instance.sendSignInLinkToEmail(
        email: emailAuth, actionCodeSettings: acs)
        .catchError((error) {
          LOG('--> startEmailLogin error : $error');
          onResult(null);
        }).then((value) {
          LOG('--> startEmailLogin success : $emailAuth');
          onResult(vfCode);
        });
  } catch (e) {
    LOG('--> startEmailLogin error : $e');
    onResult(null);
  }
}

startEmailLogin(String emailAuth, Function(bool) onResult) {

}

startEmailLogout() async {

}

getEmailUserInfo(emailAuth) async {
  final emailLink = 'https://www.exino.com/emailSignUp?cartId=1234&apiKey=AIzaSyBYHfihYZDw6KjXraK36CaBfk7t_pM8XKc&oobCode=c00by8i1u40rEroOg_URCgqFdgsyM8WcM7qfP9XewTEAAAGOWiVL0A&mode=signIn&lang=ko';
  if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
    try {
      // The client SDK will parse the code from the link for you.
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailLink(email: emailAuth, emailLink: emailLink);
      // You can access the new user via userCredential.user.
      // final emailAddress = userCredential.user?.email;
      LOG('--> Successfully signed in with email link! : ${userCredential.user}');
      return userCredential.user;
    } catch (error) {
      LOG('--> Error signing in with email link.');
    }
  }
  return null;
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
      final formatter = DateFormat('HH 시간 mm 분 ss 초');
      var date = DateTime.fromMillisecondsSinceEpoch(accessInfo.expiresIn * 1000);
      Fluttertoast.showToast(
          msg: "카카오 로그인\n${formatter.format(date)} 남음",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return true;
    }
  } catch (e) {
    LOG('--> checkKakaoLogin error : $e');
  }
  return false;
}

startKakaoLogin() async {
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
    await UserHelper().setUser(token: token.accessToken);
    return await getKakaoUserInfo();
  } else {
    await UserHelper().setUser(token: '');
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

Future<kakao.User?> getKakaoUserInfo() async {
  try {
    final user = await kakao.UserApi.instance.me();
    LOG('사용자 정보 요청 성공'
        '\n회원ID: ${user.id}'
        '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
        '\n프로필: ${user.kakaoAccount?.profile?.profileImageUrl}'
        '\n이메일: ${user.kakaoAccount?.email}');
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


