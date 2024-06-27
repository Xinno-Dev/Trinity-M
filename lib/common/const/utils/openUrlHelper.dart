import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher_string.dart';

import 'convertHelper.dart';

class OpenUrl {
  late String url;
  String? appScheme;
  String? appUrl;
  String? package; // Android only

  OpenUrl(String incomeUrl) {
    this.url = incomeUrl;

    List<String> splittedUrl =
    this.url.replaceFirst(RegExp(r'://'), ' ').split(' ');
    this.appScheme = splittedUrl[0];

    if (Platform.isAndroid) {
      /*
        Android scheme은 크게 3가지 형태
        1. intent://
        2. [app]://
        3. intent:[app]://
        이 세가지를 정상적으로 launch가 가능한 2번 형태로 변환한다
      */
      if (this.isAppLink()) {
        if (this.appScheme!.contains('intent')) {
          List<String> intentUrl = splittedUrl[1].split('#Intent;');
          String host = intentUrl[0];
          // 농협카드 일반결제 예외처리
          if (host.contains(':')) {
            host = host.replaceAll(RegExp(r':'), '%3A');
          }
          List<String> arguments = intentUrl[1].split(';');

          // scheme이 intent로 시작하면 뒷쪽의 정보를 통해 appscheme과 package 정보 추출
          if (this.appScheme! != 'intent') {
            // 현대카드 예외처리
            this.appScheme = this.appScheme!.split(':')[1];
            this.appUrl = this.appScheme! + '://' + host;
          }
          arguments.forEach((s) {
            if (s.startsWith('scheme')) {
              String scheme = s.split('=')[1];
              this.appUrl = scheme + '://' + host;
              this.appScheme = scheme;
            } else if (s.startsWith('package')) {
              String package = s.split('=')[1];
              this.package = package;
            }
          });
        } else {
          this.appUrl = this.url;
        }
      } else {
        this.appUrl = this.url;
      }
    } else {
      this.appUrl = this.url;
    }
  }

  bool isAppLink() {
    String? scheme;
    try {
      scheme = Uri.parse(this.url).scheme;
    } catch (e) {
      scheme = this.appScheme;
    }

    if (Platform.isAndroid && this.appScheme == 'https') {
      if (this
          .url
          .startsWith('https://play.google.com/store/apps/details?id=')) {
        return true;
      }
    }

    return !['http', 'https', 'about', 'data', ''].contains(scheme);
  }

  Future<String?> getAppUrl() async {
    return this.appUrl;
  }

  Future<String?> getMarketUrl() async {
    if (Platform.isIOS) {
      switch (this.appScheme) {
        case 'kftc-bankpay': // 뱅크페이
          return UrlData.IOS_MARKET_PREFIX + 'id398456030';
        case 'ispmobile': // ISP/페이북
          return UrlData.IOS_MARKET_PREFIX + 'id369125087';
        case 'hdcardappcardansimclick': // 현대카드 앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id702653088';
        case 'shinhan-sr-ansimclick': // 신한 앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id572462317';
        case 'kb-acp': // KB국민 앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id695436326';
        case 'mpocket.online.ansimclick': // 삼성앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id535125356';
        case 'lottesmartpay': // 롯데 모바일결제
          return UrlData.IOS_MARKET_PREFIX + 'id668497947';
        case 'lotteappcard': // 롯데 앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id688047200';
        case 'cloudpay': // 하나1Q페이(앱카드)
          return UrlData.IOS_MARKET_PREFIX + 'id847268987';
        case 'citimobileapp': // 시티은행 앱카드
          return UrlData.IOS_MARKET_PREFIX + 'id1179759666';
        case 'payco': // 페이코
          return UrlData.IOS_MARKET_PREFIX + 'id924292102';
        case 'kakaotalk': // 카카오톡
          return UrlData.IOS_MARKET_PREFIX + 'id362057947';
        case 'lpayapp': // 롯데 L.pay
          return UrlData.IOS_MARKET_PREFIX + 'id1036098908';
        case 'wooripay': // 우리페이
          return UrlData.IOS_MARKET_PREFIX + 'id1201113419';
        case 'com.wooricard.wcard': // 우리WON카드
          return UrlData.IOS_MARKET_PREFIX + 'id1499598869';
        case 'nhallonepayansimclick': // NH농협카드 올원페이(앱카드)
          return UrlData.IOS_MARKET_PREFIX + 'id1177889176';
        case 'hanawalletmembers': // 하나카드(하나멤버스 월렛)
          return UrlData.IOS_MARKET_PREFIX + 'id1038288833';
        case 'shinsegaeeasypayment': // 신세계 SSGPAY
          return UrlData.IOS_MARKET_PREFIX + 'id666237916';
        case 'naversearchthirdlogin': // 네이버페이 앱 로그인
          return UrlData.IOS_MARKET_PREFIX + 'id393499958';
        case 'lguthepay-xpay': // 페이나우
          return UrlData.IOS_MARKET_PREFIX + 'id760098906';
        case 'lmslpay': // 롯데 L.POINT
          return UrlData.IOS_MARKET_PREFIX + 'id473250588';
        case 'liivbank': // Liiv 국민
          return UrlData.IOS_MARKET_PREFIX + 'id1126232922';
        case 'supertoss': // 토스
          return UrlData.IOS_MARKET_PREFIX + 'id839333328';
        case 'newsmartpib': // 우리WON뱅킹
          return UrlData.IOS_MARKET_PREFIX + 'id1470181651';
        case 'v3mobileplusweb': // V3 Mobile Plus
          return UrlData.IOS_MARKET_PREFIX + 'id1481938658';
        case 'kbbank': // KB스타뱅킹
          return UrlData.IOS_MARKET_PREFIX + 'id373742138';
        case 'newliiv': // 리브 Next
          return UrlData.IOS_MARKET_PREFIX + 'id1573528126';
        default:
          return this.url;
      }
    } else if (Platform.isAndroid) {
      if (this.package != null) {
        // 앱이 설치되어 있지 않아 실행 불가능할 경우 추출된 package 정보를 이용해 플레이스토어 열기
        return UrlData.ANDROID_MARKET_PREFIX + this.package!;
      }
      switch (this.appScheme) {
        case UrlData.ISP:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_ISP;
        case UrlData.BANKPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_BANKPAY;
        case UrlData.KB_BANKPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KB_BANKPAY;
        case UrlData.NH_BANKPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_NH_BANKPAY;
        case UrlData.MG_BANKPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_MG_BANKPAY;
        case UrlData.KN_BANKPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KN_BANKPAY;
        case UrlData.KAKAOPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KAKAOPAY;
        case UrlData.SMILEPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_SMILEPAY;
        case UrlData.CHAIPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_CHAIPAY;
        case UrlData.PAYCO:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_PAYCO;
        case UrlData.HYUNDAICARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_HYUNDAICARD;
        case UrlData.TOSS:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_TOSS;
        case UrlData.SHINHANCARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_SHINHANCARD;
        case UrlData.HANACARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_HANACARD;
        case UrlData.SAMSUNGCARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_SAMSUNGCARD;
        case UrlData.KBCARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KBCARD;
        case UrlData.NHCARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_NHCARD;
        case UrlData.CITICARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_CITICARD;
        case UrlData.LOTTECARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_LOTTECARD;
        case UrlData.LPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_LPAY;
        case UrlData.SSGPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_SSGPAY;
        case UrlData.KPAY:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KPAY;
        case UrlData.PAYNOW:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_PAYNOW;
        case UrlData.WOORIWONCARD:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_WOORIWONCARD;
        case UrlData.LPOINT:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_LPOINT;
        case UrlData.WOORIWONBANK:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_WOORIWONBANK;
        case UrlData.KTFAUTH:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KTFAUTH;
        case UrlData.LGTAUTH:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_LGTAUTH;
        case UrlData.SKTAUTH:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_SKTAUTH;
        case UrlData.V3_MOBILE_PLUS:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_V3_MOBILE_PLUS;
        case UrlData.KBBANK:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_KBBANK;
        case UrlData.LIIV_NEXT:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_LIIV_NEXT;
        case UrlData.NAVER:
          return UrlData.ANDROID_MARKET_PREFIX + UrlData.PACKAGE_NAVER;
        default:
          return this.url;
      }
    }
    return null;
  }

  Future<bool> launchApp() async {
    bool opened = false;
    String appUrl = (await this.getAppUrl())!;
    LOG('--> launchApp : $appUrl');
    try {
      opened = await launchUrlString(appUrl);
    } catch (e) {}

    if (!opened) {
      opened = await launchUrlString((await this.getMarketUrl())!);
    }

    return opened;
  }
}

class UrlData {
  static const String ANDROID_MARKET_PREFIX = 'market://details?id=';
  static const String IOS_MARKET_PREFIX = 'itms-apps://itunes.apple.com/app/';

  static const String ISP = 'ispmobile';
  static const String PACKAGE_ISP = 'kvp.jjy.MispAndroid320';

  static const String BANKPAY = 'kftc-bankpay';
  static const String PACKAGE_BANKPAY = 'com.kftc.bankpay.android';

  static const String KB_BANKPAY = 'kb-bankpay';
  static const String PACKAGE_KB_BANKPAY = 'com.kbstar.liivbank';

  static const String NH_BANKPAY = 'nhb-bankpay';
  static const String PACKAGE_NH_BANKPAY = 'com.nh.cashcardapp';

  static const String MG_BANKPAY = 'mg-bankpay';
  static const String PACKAGE_MG_BANKPAY = 'kr.co.kfcc.mobilebank';

  static const String KN_BANKPAY = 'kn-bankpay';
  static const String PACKAGE_KN_BANKPAY = 'com.knb.psb';

  static const String KAKAOPAY = 'kakaotalk';
  static const String PACKAGE_KAKAOPAY = 'com.kakao.talk';

  static const String SMILEPAY = 'smilepayapp';
  static const String PACKAGE_SMILEPAY = 'com.mysmilepay.app';
  static const String SMILEPAY_BASE_URL = "https://www.mysmilepay.com/";

  static const String CHAIPAY = 'chaipayment';
  static const String PACKAGE_CHAIPAY = 'finance.chai.app';

  static const String PAYCO = 'payco';
  static const String PACKAGE_PAYCO = 'com.nhnent.payapp';

  static const String HYUNDAICARD = 'hdcardappcardansimclick';
  static const String PACKAGE_HYUNDAICARD = 'com.hyundaicard.appcard';

  static const String TOSS = 'supertoss';
  static const String PACKAGE_TOSS = 'viva.republica.toss';

  static const String SHINHANCARD = 'shinhan-sr-ansimclick';
  static const String PACKAGE_SHINHANCARD = 'com.shcard.smartpay';

  static const String HANACARD = 'cloudpay';
  static const String PACKAGE_HANACARD = 'com.hanaskcard.paycla';

  static const String SAMSUNGCARD = 'mpocket.online.ansimclick';
  static const String PACKAGE_SAMSUNGCARD = 'kr.co.samsungcard.mpocket';

  static const String KBCARD = 'kb-acp';
  static const String PACKAGE_KBCARD = 'com.kbcard.cxh.appcard';

  static const String NHCARD = 'nhallonepayansimclick';
  static const String PACKAGE_NHCARD = 'nh.smart.nhallonepay';

  static const String CITICARD = 'citimobileapp';
  static const String PACKAGE_CITICARD = 'kr.co.citibank.citimobile';

  static const String LOTTECARD = 'lotteappcard';
  static const String PACKAGE_LOTTECARD = 'com.lcacApp';

  static const String LPAY = 'lpayapp';
  static const String PACKAGE_LPAY = 'com.lotte.lpay';

  static const String SSGPAY = 'shinsegaeeasypayment';
  static const String PACKAGE_SSGPAY =
      'com.ssg.serviceapp.android.egiftcertificate';

  static const String KPAY = 'kpay';
  static const String PACKAGE_KPAY = 'com.inicis.kpay';

  static const String PAYNOW = 'lguthepay-xpay';
  static const String PACKAGE_PAYNOW = 'com.lguplus.paynow';

  static const String WOORIWONCARD = 'com.wooricard.smartapp';
  static const String PACKAGE_WOORIWONCARD = 'com.wooricard.smartapp';

  static const String LPOINT = 'lmslpay';
  static const String PACKAGE_LPOINT = 'com.lottemembers.android';

  static const String WOORIWONBANK = 'wooribank';
  static const String PACKAGE_WOORIWONBANK = 'com.wooribank.smart.npib';

  static const String KTFAUTH = 'ktauthexternalcall';
  static const String PACKAGE_KTFAUTH = 'com.kt.ktauth';

  static const String LGTAUTH = 'upluscorporation';
  static const String PACKAGE_LGTAUTH = 'com.lguplus.smartotp';

  static const String SKTAUTH = 'tauthlink';
  static const String PACKAGE_SKTAUTH = 'com.sktelecom.tauth';

  static const String V3_MOBILE_PLUS = 'v3mobileplusweb';
  static const String PACKAGE_V3_MOBILE_PLUS = 'com.ahnlab.v3mobileplus';

  static const String KBBANK = 'kbbank';
  static const String PACKAGE_KBBANK = 'com.kbstar.kbkank';

  static const String LIIV_NEXT = 'newliiv';
  static const String PACKAGE_LIIV_NEXT = 'com.kbstar.reboot';

  static const String NAVER = 'nidlogin';
  static const String PACKAGE_NAVER = 'com.nhn.android.search';
}

