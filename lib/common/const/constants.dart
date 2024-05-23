import 'package:flutter/foundation.dart';

// const String API_HOST = 'http://192.168.252.51:19000';
// const String DEVELOP_NET_URI = 'ws://192.168.252.60:26657/websocket';

const String API_HOST = 'http://13.209.81.51';
const String API_HOST_DEV = 'http://13.209.81.51';

const String MAIN_NET_URI = 'wss://mainnet.rigochain.io/websocket';
const String MAIN_HTTP_URL = 'https://mainnet.rigochain.io';
const String MAIN_NET_CHAIN_ID = "mainnet";

const String TEST_NET_URI = 'ws://testnet.rigochain.io:26657/websocket';
const String TEST_HTTP_URL = 'https://testnet.rigochain.io';
const String TEST_NET_CHAIN_ID = "testnet0";

// for Larba..
const String RWF_KEY = 'RWF_KEY';
const String JWT_KEY = 'JWT_KEY';
const String TOKEN_KEY = 'TOKEN_KEY';
const String VFCODE_KEY = 'VFCODE_KEY';
const String ACCOUNT_KEY = 'ACCOUNT_KEY';

// for Byffin..
const String LOGIN_TYPE_KEY = 'LOGIN_TYPE_KEY';
const String LOGIN_INFO_KEY = 'LOGIN_INFO_KEY';
const String USERID_KEY = 'USERID_KEY';
const String LOGIN_KEY = 'LOGIN_KEY';
const String IDENTITY_KEY = 'IDENTITY_KEY';
const String BIO_IDENTITY_KEY = 'BIO_IDENTITY_KEY';
const String UID_KEY = 'UID_KEY';
const String PUB_KEY = 'PUB_KEY';
const String FCM_KEY = 'FCM_KEY';
const String KEYPAIR_KEY = 'KEYPAIR_KEY';
const String LOGINDATE_KEY = 'LOGINDATE_KEY';
const String ADDRESS_KEY = 'ADDRESS_KEY';
const String COIN_LIST_KEY = 'COIN_LIST_KEY';
const String SELECTED_COIN_KEY = 'SELECTED_COIN_KEY';
const String SELECTED_MAINNET_KEY = 'SELECTED_MAINNET_KEY';
const String USELOCALAUTH_KEY = 'USELOCALAUTH_KEY';
const String TRASH_KEY = 'TRASH_KEY';
const String REGISTDATE_KEY = 'REGISTDATE_KEY';
const String FIRSTRUN_KEY = 'FIRSTRUN_KEY';
const String ROOT_KEY = 'ROOT_KEY';
const String MNEMONIC_KEY = 'MNEMONIC_KEY';
const String CHECK_MNEMONIC_KEY = 'CHECK_MNEMONIC_KEY';
const String ADDRESSLIST_KEY = 'ADDRESSLIST_KEY';
const String NETWORKLIST_KEY = 'NETWORKLIST_KEY';
const String MNEMONIC_CHECK = 'MNEMONIC_CHECK';

const String APP_VERSION_KEY = 'APP_VERSION_KEY';
const String APP_NOTICE_KEY = 'APP_NOTICE_KEY';

const bool IS_DEV_MODE = kDebugMode && false;
const bool IS_EMAIL_CHECK = true;
const bool IS_AUTO_LOCK_MODE = false;
const bool IS_AUTO_LOGIN_MODE = true; // 로컬에 패스워드 저장
const bool IS_ACCOUNT_NAME_SETDOC = false; // Account 이름 변경시 SetDoc API 이용
const bool IS_SWAP_ON = false;
const bool IS_PAYMENT_ON = true;
const bool IS_EXPORT_MN = true;

String CURRENT_CHAIN_ID = TEST_NET_CHAIN_ID;

const String IDENTITY_PG = 'danal'; // 본인인증
const String PAYMENT_PG = 'danal_tpay'; // PG사
// const String PORTONE_IMP_CODE = 'imp32281033'; // PortOne 가맹점 코드 // jubal2000@gmail.comI(test)
const String PORTONE_IMP_CODE = 'imp08730114'; // PortOne 가맹점 코드 // dev@xinno.io

// const String EX_TEST_MAIL_00 = 'test00@exsino.com';
// const String EX_TEST_PASS_00 = 'testpass00';
const String EX_TEST_MAIL_00 = 'jubal2000@gmail.com';
const String EX_TEST_PASS_00 = 'jubalpass00';
const String EX_TEST_REC_PASS_00 = '11111';

const String EX_TEST_MAIL_EX = 'test00@exsino.com';
const String EX_TEST_PASS_EX = 'testpass00';

const String EX_TEST_ACCCOUNT_00 = 'jubal0000';
const String EX_TEST_ACCCOUNT_00_1 = 'jubal0000_1';
const String EX_TEST_NAME_00 = 'jubal0000 입니다!';
const String EX_TEST_MN_EX = 'weekend minimum ribbon sing destroy vacuum cherry cement sock shell wear result'; // email: tester00
const String EX_TEST_MN_00 = 'weekend minimum ribbon sing destroy vacuum cherry cement sock shell wear result'; // email: tester00
const String EX_TEST_MN_01 = 'frown gadget pattern black quality staff connect throw mercy rookie valid swim'; // email: jubal2000@gmail.com
const String EX_TEST_MN_02 = 'layer replace clay dinosaur agree jazz unit peace roast combine chase relief'; // kakao: jubal2000@hanmail.net
const String EX_TEST_MN_03 = 'apart sand present sunny destroy police either idle gospel anxiety ranch junk'; // kakao: jubal2001@gmail.com(from home)

const String EMPTY_IMAGE = 'assets/images/app_icon_128_g.png';

const int DECIMAL_PLACES = 8;
const double PROFILE_RADIUS = 120.0;
const double PROFILE_RADIUS_S = 40.0;

late List DEFAULT_COIN_LIST = [
  ['RIGO', 'RIGO', MAIN_NET_CHAIN_ID, DECIMAL_PLACES.toString()],
  ['RIGO', 'RIGO', TEST_NET_CHAIN_ID, DECIMAL_PLACES.toString()]];

