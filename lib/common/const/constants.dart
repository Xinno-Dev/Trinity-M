import 'package:flutter/foundation.dart';

const String API_HOST = 'http://192.168.252.51:19000';
const String DEVELOP_NET_URI = 'ws://192.168.252.60:26657/websocket';

const String MAIN_NET_URI = 'wss://mainnet.rigochain.io/websocket';
const String MAIN_HTTP_URL = 'https://mainnet.rigochain.io';
const String MAIN_NET_CHAIN_ID = "mainnet";

const String TEST_NET_URI = 'ws://testnet.rigochain.io:26657/websocket';
const String TEST_HTTP_URL = 'https://testnet.rigochain.io';
const String TEST_NET_CHAIN_ID = "testnet0";

const String USERID_KEY = 'USERID_KEY';
const String UID_KEY = 'UID_KEY';
const String PUB_KEY = 'PUB_KEY';
const String FCM_KEY = 'FCM_KEY';
const String KEYPAIR_KEY = 'KEYPAIR_KEY';
const String LOGINDATE_KEY = 'LOGINDATE_KEY';
const String ADDRESS_KEY = 'ADDRESS_KEY';
const String COIN_LIST_KEY = 'COIN_LIST_KEY';
const String SELECTED_COIN_KEY = 'SELECTED_COIN_KEY';
const String SELECTED_MAINNET_KEY = 'SELECTED_MAINNET_KEY';
const String RWF_KEY = 'RWF_KEY';
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

const bool IS_DEV_MODE = kDebugMode && true;
const bool IS_AUTO_LOCK_MODE = false;
const bool IS_ACCOUNT_NAME_SETDOC = false; // Account 이름 변경시 SetDoc API 이용
const bool IS_SWAP_ON = false;

String CURRENT_CHAIN_ID = TEST_NET_CHAIN_ID;

const int DECIMAL_PLACES = 8;

late List DEFAULT_COIN_LIST = [
  ['RIGO', 'RIGO', MAIN_NET_CHAIN_ID, DECIMAL_PLACES.toString()],
  ['RIGO', 'RIGO', TEST_NET_CHAIN_ID, DECIMAL_PLACES.toString()]];
