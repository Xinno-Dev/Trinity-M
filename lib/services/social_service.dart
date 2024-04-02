import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:firebase_auth/firebase_auth.dart' as google;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:larba_00/common/const/utils/md5Helper.dart';
import 'package:larba_00/common/rlp/hash.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../common/const/utils/convertHelper.dart';


////////////////////////////////////////////////////////////////////////////////
//
//
//  EMAIL
//
//


checkEmailLogin() async {
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
  final emailLink = 'https://www.medium.com/emailSignUp?cartId=1234&apiKey=AIzaSyBYHfihYZDw6KjXraK36CaBfk7t_pM8XKc&oobCode=c00by8i1u40rEroOg_URCgqFdgsyM8WcM7qfP9XewTEAAAGOWiVL0A&mode=signIn&lang=ko';
  if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
    try {
      // The client SDK will parse the code from the link for you.
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailLink(email: emailAuth, emailLink: emailLink);
      // You can access the new user via userCredential.user.
      // final emailAddress = userCredential.user?.email;
      print('Successfully signed in with email link! : ${userCredential.user}');
      return userCredential.user;
    } catch (error) {
      print('Error signing in with email link.');
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
    return accessInfo.id != null;
  } catch (e) {
    LOG('--> checkKakaoLogin error : $e');
  }
  return false;
}

startKakaoLogin() async {
  if (await kakao.isKakaoTalkInstalled()) {
    try {
      final token = await kakao.UserApi.instance.loginWithKakaoTalk();
      LOG('--> 카카오톡으로 로그인 성공 ${token.accessToken}');
    } catch (error) {
      LOG('--> 카카오톡으로 로그인 실패 $error');
      if (error is PlatformException && error.code == 'CANCELED') {
        return false;
      }
      try {
        await kakao.UserApi.instance.loginWithKakaoAccount();
        LOG('--> 카카오계정으로 로그인 성공');
      } catch (error) {
        LOG('--> 카카오계정으로 로그인 실패 $error');
        return false;
      }
    }
  } else {
    try {
      await kakao.UserApi.instance.loginWithKakaoAccount();
      LOG('--> 카카오계정으로 로그인 성공');
    } catch (error) {
      LOG('--> 카카오계정으로 로그인 실패 $error');
      return false;
    }
  }
  return await getKakaoUserInfo();
}

startKakaoLogout() async {
  try {
    await kakao.UserApi.instance.logout();
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
        '\n회원번호: ${user.id}'
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
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = google.GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  final result = await google.FirebaseAuth.instance.signInWithCredential(credential);
  LOG('---> google result : $result');
  return result;
}

startGoogleLogout() async {
  try {
    await google.FirebaseAuth.instance.signOut();
    return true;
  } catch (e) {
    LOG('--> startGoogleLogout error : $e');
  }
  return false;
}

getGoogleUserInfo() async {
  try {
    final user = await google.FirebaseAuth.instance.currentUser;
    LOG('---> getGoogleUserInfo : $user');
    return user;
  } catch (e) {
    LOG('--> getGoogleUserInfo error : $e');
  }
  return null;
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


