
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class AppLocalization {
  AppLocalization(this.locale);

  final Locale locale;

  // static AppLocalization? of(BuildContext context) {
  //   return Localizations.of<AppLocalization>(context, AppLocalization);
  // }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // global.....................
      '확인': 'OK',
      '취소': 'Cancel',
      '닫기': 'Close',
      '앱 업데이트': 'App update',
      '마켓으로 이동': 'Go to market',
      '다시 보지 않기': 'don\'t see it again',

      // AccountManageScreen......
      '계정 관리': 'Account manage',
      '계정 불러오기': 'Import account',
      '불러옴': 'Imported',
      '새 계정을 추가하시겠어요?': 'Would you like to add a new account?',
      '새 계정이 목록에 추가됩니다.': 'Your new account will be added to the list.',
      '추가하기': 'Add',
      '계정 추가하기': 'Add account',
      '계정 정보를 가져오는 중입니다': 'Retrieving account information',
      '편집': 'Edit',
      '계정 정보': 'Account Information',
      '주소 복사': 'Copy address',
      // AuthCompletedScreen.......
      '로그인 완료': 'Log in complete',
      // AuthLocalScreen...........
      '본인 확인을 위해 생체인증을 사용합니다.':
      'We use biometric authentication to verify your identity.',
      '본인확인': 'Identification',
      'Mauth에서 본인확인을 진행할 수 있도록\n생체인증을 진행해 주세요.':
      'Please proceed with biometric authentication so that Mauth can verify your identity.',
      '비밀번호 인증하기': 'Verify password',
      // AuthPasswordScreen........
      '비밀번호 변경': 'Change password',
      '지갑 복구용 문구 보기': 'View wallet recovery phrase',
      '개인키 보기': 'View private key',
      '계정 불러오기에 실패했습니다.': 'Failed to load account.',
      '본인인증에 실패하였습니다.': 'Identity verification failed.',
      '비밀번호를 입력해주세요': 'Please enter a password',
      '사용중인 비밀번호를 입력합니다.': 'Enter the password you are using.',
      // ExportPrivateKeyScreen....
      '개인키가 타인에게 노출되지 않도록 주의하세요.\n개인키가 있으면 누구든 귀하의 자산에 접근 할 수\n있습니다.':
      'Be careful not to expose\nyour private key to others.\nIf you have a private key,\nanyone can access your assets.',
      '개인키': 'Private key',
      '숨기기': 'Hide',
      '감추기': 'Hide',
      '보이기': 'Show',
      '보기': 'Show',
      'RWF 파일로 변환되었습니다.': 'Converted to RWF file.',
      '복사하기': 'Copy',
      '지갑주소가 복사되었습니다': 'Wallet address has been copied',
      '개인키가 복사되었습니다': 'Private key has been copied',
      // HistoryScreen.............
      '인증내역': 'Certification details',
      '인증 목록': 'Certification list',
      // HomeScreen................
      // ImportPrivateKeyScreen....
      '불러오기': 'Import',
      '개인키 문자열을 붙여넣으세요': 'Paste your private key string',
      '불러온 계정이 계정 목록에 추가됩니다.':
      'The imported account will be added to the account list.',
      '개인키 문자열': 'Private key string',
      '개인키는 각 지갑마다 설정되는 64자리의 문자와 숫자 조합입니다.':
      'The private key is a 64-character combination\nof letters and numbers set for each wallet.',
      '지갑 복구 시, 불러온 계정은 바이핀의 지갑 복구용 문구로는\n복구 할 수 없습니다.':
      'When recovering a wallet, the loaded account cannot be\nrestored using BYFFIN\'s wallet recovery phrase.',
      '개인키가 일치하지 않습니다': 'Private key does not match',
      '확인 후 다시 시도해 주세요.': 'Please check and try again.',
      // LoginScreen...............
      '지갑 초기화 유의사항': 'Wallet reset precautions',
      '지갑 복구는 비밀 복구 구문을 입력하여\n'
          '복구하는 과정이며, 먼저 지갑을\n'
          '초기화 한 후 진행할 수 있습니다.\n\n'
          '지갑을 초기화 하면 지갑의 계정 정보 및 자산이 본 기기에서 제거 되며\n'
          '취소할 수 없습니다.\n\n'
          '정말로 지갑을 초기화 하시겠습니까?':
      'Wallet recovery is done by entering the secret recovery phrase\n'
          'This is a recovery process, first open your wallet\n'
          'You can proceed after initialization.\n\n'
          'If you initialize the wallet, the wallet\'s account information and assets will be removed from the device\n'
          'Cannot be cancelled.\n\n'
          'Are you sure you want to reset your wallet?',
      'reset_00': 'If you want to reset,\n',
      'reset_01': 'please enter ',
      'reset_02': 'reset ',
      'reset_03': 'below',
      '입력하기': 'Enter',
      '문구가 일치하지 않습니다': 'Phrase does not match',
      '지갑이 초기화되었습니다': 'Your wallet has been reset',
      '초기화': 'Reset',
      '초기화 하기': 'Reset',
      // MainScreen................
      '계정이 여러개 있으신가요?': 'Do you have multiple accounts?',
      '복구용 문구에 여러 계정이'
      '\n연결 되어도, 최초로 생성한 계정만'
      '\n복구됩니다.'
      '\n\n계정이 한개 이상이실 경우,'
      '\n계정 추가하기 메뉴를 통해 직접 계정을'
      '\n추가하여 나머지 계정을 복구해주세요.' :
      'Multiple accounts in recovery text'
      '\nEven if connected, only the first account created'
      '\nIt will be restored.'
      '\n\nIf you have more than one account,'
      '\nCreate an account directly through the Add Account menu'
      '\nPlease restore the remaining accounts by adding them.',
      '_자산': 'Asset',
      '자산': 'ASSET',
      '스테이킹': 'STAKING',
      '설정': 'SETUP',
      'RIGO 코인에서만 사용가능합니다': 'Can only be used with RIGO Coin',
      // UserInfoScreen....
      '계정 이름 변경': 'Change account name',
      '계정 이름을 입력해주세요': 'Account name',
      // RecoverWalletCompleteScreen.....
      'BYFFIN 지갑이\n복구되었습니다': 'BYFFIN wallet\nhas been restored',
      'BYFFIN의 여러 디앱 서비스를\n사용해 보세요!':
      'Try out BYFFIN\'s various DApp services!',
      '지갑 사용하기': 'Use wallet',
      // RecoverWalletInputScreen........
      '지갑 복구용 문구를 확인합니다': 'Check the phrase for wallet recovery',
      '문구 12개를 순서대로 입력하세요': 'Enter 12 phrases in order',
      '지갑 복구용 문구란': 'Wallet recovery phrase',
      '지갑 복구 문구가 일치하지 않습니다': 'Wallet recovery phrase does not match',
      '다시 입력해주세요.': 'Please enter again.',
      '다시 입력하기': 'Enter again',
      '복구용 문구는 지갑을 만들때 보안을 위해 자동으로\n생성된 단어이며, 자산을 복구하기 위한 유일한 수단\n입니다.':
      'The recovery phrase is a word automatically generated for security purposes when creating a wallet, and is the only means to recover assets.',
      'BYFFIN 지갑-> 설정메뉴-> 내 지갑 복구용 문구 보기\n메뉴에서 확인할 수 있습니다.':
      'You can check it in the BYFFIN Wallet-> Settings Menu-> View My Wallet Recovery Phrases\n menu.',
      '문구 입력': 'Enter phrase',
      // RecoverWalletRegisterPassword.....
      '비밀번호를 한번 더\n등록해주세요': 'Please register\npassword again',
      '비밀번호를 등록해주세요': 'Please register password',
      '비밀번호 확인을 위해 필요합니다.': 'Required to confirm password.',
      'BYFFIN 지갑 사용을 위한 비밀번호\n숫자 6자리를 등록합니다.':
      'Register a 6-digit password\nto use BYFFIN wallet.',
      // RegistCompleteScreen..............
      '로그인하기': 'Log in',
      '자산으로 가기': 'Go to asset',
      'BYFFIN 지갑 을\n만들었습니다': 'BYFFIN wallet\ncreated',
      '비밀번호 변경이\n완료되었습니다': 'Password change\ncompleted',
      '새로운 비밀번호로 로그인을 해주세요': 'Please Login with a new password',
      '새 계정을 추가했습니다': 'A new account has been added',
      '계정을 불러왔습니다': 'Your account has been loaded',
      // RegistLocalAuthScreen.............
      '권한이 허용되지 않았습니다.': 'Permission not granted.',
      '생체인증 사용동의': 'Consent to use biometric authentication',
      '빠른 이용을 위해\n생체인증을 설정하세요.': 'For quick use\nSet up biometric authentication.',
      '본인 확인 목적으로 기기에 등록된 생체정보를\n'
          '이용하여 로그인 및 인증작업을 진행하며,\n'
          '서버로 전송/저장되지 않습니다.':
      'Biometric information registered on the device\nfor identity verification purposes\n'
          'Proceed with login and authentication using,\n'
          'It will not be sent/saved to the server.',
      '생체인증 사용 동의': 'Consent to use biometric authentication',
      '다음에 하기': 'Do it next time',
      '생체인증 사용': 'Use biometric authentication',
      // RegistMnemonicCheckScreen..........보
      '문구를 다시 입력해 주세요.': 'Please re-enter the phrase.',
      '돌아가기': 'Back',
      '문구 보관을 확인합니다': 'Check stationery storage',
      '빈칸의 번호에 맞는 문구를 입력해주세요': 'Please enter the phrase that matches the number in the blank space.',
      // RegistMnemonicScreen...............
      '지갑 복구용 문구': 'Wallet recovery phrase',
      '복구용 문구는 지갑을 만들때 '
          '\n보안을 위해 자동으로 생성된 단어이며,'
          '\n자산을 복구하기 위한'
          '\n유일한 수단입니다.':
      'The recovery phrase is used when making a wallet'
          '\nThis is a word automatically generated for security purposes,'
          '\nTo recover assets'
          '\nIt is the only means.',
      '문구를 안전한 곳에 보관해주세요.\n문구가 없으실 경우엔 계정 복구가 불가합니다.':
      'Please keep the phrase in a safe place.\nIf you do not have the phrase,\naccount recovery is not possible.',
      '지갑 복구용 문구를 보관하세요': 'Keep the wallet recovery phrase',
      '문구를 복사하여 안전한 곳에 보관해주세요.\n문구를 잃어버리실 경우 지갑 복구가 불가합니다.':
      'Please copy the phrase and\nkeep it in a safe place.'
      'If you lose the phrase, your wallet cannot be recovered.',
      '문구 복사하기': 'Copy phrase',
      '문구가 복사되었습니다': 'The phrase has been copied',
      '문구 보관을 확인하세요': 'Have you stored the words?',
      '지갑 복구용 문구를 보관하셨나요?\n'
          '보관 확인 과정을 진행하세요\n\n'
          '문구를 잃어버리실 경우 지갑 복구가\n'
          '불가하며,  바이핀은 사용자의 지갑\n'
          '복구용 문구를 보관하지 않습니다.':
      'Have you stored the wallet recovery phrase?\n'
          'Proceed with the storage confirmation process.\n\n'
          'If you lose the phrase, wallet recovery will not be possible,\n'
          'and BYFFIN does not store the user\'s\n'
          'wallet recovery phrase.',
      '넘어가기': 'Skip',
      '보관 확인하기': 'Check storage',
      // RegistNumberScreen.....................
      '이미 등록되어 있는 이메일 입니다': 'This email is already registered',
      '사용가능한 이메일을 입력해 주세요.': 'Please enter a valid email address.',
      '사용 가능한 이메일 입니다': 'This email is available',
      '회원가입': 'Signup',
      '이메일을 입력해 주세요': 'Please enter your e-mail',
      'BYFFIN 지갑을 이용하기 위해 필요합니다': 'Required to use BYFFIN wallet',
      '이메일': 'E-mail',
      // RegistPasswordScreen...................
      '이전 비밀번호와 동일한\n비밀번호를 등록할 수 없습니다.':
      'You cannot register a password that is\nthe same as your previous password.',
      // ScanQRScreen...........................
      'QR 코드 스캔': 'QR code scan',
      'BYFFIN 이용약관': 'BYFFIN Terms of Service',
      '개인정보처리방침': 'Privacy Policy',
      '마케팅 활용 및 광고성 정보 수신 동의': 'Consent for Marketing Use and Receipt of Advertising Information',
      '약관 및 정책': 'Terms and Policies',
      // SettingsScreen.........................
      '언어 설정': 'Language setting',
      '보안 및 개인정보 보호': 'Security and Privacy Protection',
      '앱 버전': 'App version',
      '마켓 버전': 'Market version',
      '지갑 잠금': 'Lock wallet',
      '지갑 잠금 유의사항': 'Wallet lock precautions',
      '지갑 복구용 문구를 보관하지 않고\n지갑을 잠그실 경우,\n보유하신 자산에 접근할 수 없습니다.':
      'If you lock your wallet without\n'
          'saving the wallet recovery phrase,\n'
          'you will not be able to access your assets.',
      '잠금': 'Lock',
      // SettingsSecurityScreen.................
      '생체 인증 사용': 'Use biometric authentication',
      // SignPasswordScreen.....................
      '스테이킹이 진행중 입니다.': 'Staking is in progress.',
      '스테이킹이 종료중 입니다.': 'Staking is ending.',
      '위임이 진행중 입니다.': 'Delegation is in progress.',
      '위임이 종료중 입니다.': 'The delegation is ending.',
      '전송 요청중 입니다.': 'Requesting transmission.',
      '락업 종료일 이후에\n자동으로 입금됩니다.':
      'Deposit will be made automatically\nafter the lockup end date.',
      '전송이 실패했습니다.': 'Transmission failed.',
      '다시 시도해주세요.': 'please try again.',
      // TermsScreen.............................
      '약관에 동의해 주세요': 'Please agree to the terms and conditions',
      'BYFFIN 지갑을 이용해주셔서 감사합니다.\n서비스 이용을 위해 약관 동의가 필요합니다.':
      'Thank you for using BYFFIN wallet.\nYou must agree to the terms and\nconditions to use the service.',
      '전체 동의': 'Agree all',
      '(필수)': '(Essential)',
      '(선택)': '(Select)',
      // TradeDetailScreen.......................
      '상태': 'Status',
      '완료': 'Completed',
      '날짜': 'Date',
      '수량': 'Amount',
      '_수량': 'amount',
      '수수료': 'Fee',
      '총 수량': 'Total amount',
      '보내는 주소': 'Send address',
      '받는 주소': 'Receive address',
      '지갑주소': 'Wallet address',
      '탈퇴하기': 'Withdrawal',
      'BYFFIN 월렛 이용을\n그만하시겠어요?':
      'Would you prefer not to use the BYFFIN service?',
      '탈퇴할 경우 더이상 서비스를 이용할 수 없으며\n아래 동의가 필요합니다.':
      'If you withdraw, you will no longer be able to use the service.\nThe consent below is required.',
      '보유중인 자산을 모두 확인했으며,\n이를 다른 지갑으로 이전할 수 있다는 안내를 확인했습니다':
      'I have checked all the assets I hold,\nand I have seen the instructions that I can transfer them to another wallet.',
      '탈퇴 시 개인 키가 파기되어 회사 및 누구도 이전하지 않은 자산에 접근할 수 없으며 복구가 불가능함을 확인했습니다':
      'We have confirmed that upon withdrawal, private keys will be destroyed, making the company and no one else accessible to untransferred assets, and recovery is impossible.',
      '이전하지 않은 자산의 소유권(소수점 7자리 이하 소량 잔고 포함)을 포함한 일체의 권리를 포기하는데 동의합니다':
      'I agree to give up all rights, including ownership of assets not transferred (including small balances to 7 decimal places)',
      '동의 후 탈퇴': 'Withdraw after consent',
      '계속 이용하기': 'Continue using',
      // AssetScreen..............................
      '네트워크': 'Network',
      '네트워크 추가': 'Add network',
      '네트워크 정보 확인': 'Network information',
      '네트워크 수동 추가': 'Add network manually',
      '네트워크 확인중입니다.': 'Checking the network.',

      'RPC 주소를 입력해 주세요.': 'Please enter the RPC address',
      'RPC 주소': 'RPC address',
      'RPC 소켓 주소': 'RPC socket address',
      '네트워크 이름을 입력해 주세요.': 'Please enter the network name',
      '이미 등록된 네트워크 이름입니다.': 'This network name is already registered.',
      '* 이미 등록된 네트워크입니다.': '* This network is already registered.',
      '네트워크 채널 선택': 'Select network channel',
      '채널을 선택해 주세요.': 'Please select a channel',
      '채널 이름': 'Channel name',
      '체인 아이디': 'Chain ID',
      '통화 기호': 'Currency symbol',
      '네트워크 이름': 'Network name',
      '블록 탐색기 주소(선택)': 'Block explorer address(optional)',
      '블록 탐색기 주소를 확인해 주세요.': 'Please check the block explorer address.',
      '네트워크를 삭제하시겠습니까?': 'Are you sure you want to delete the network?',
      '네트워크가 삭제되었습니다.': 'Network has been deleted.',
      '삭제': 'Delete',
      '저장': 'Complete',
      '자산이 없습니다.\n토큰을 추가해 주세요': 'There are no assets.\nPlease add a token',

      '네트워크를 변경했습니다': 'You have changed your network',
      '보내기': 'Send',
      '받기': 'Receive',
      '내 주소로 받기': 'Receive to my address',
      '거래': 'Trade',
      '전송 내역': 'Transfer History',
      '계정 정보 없음': 'No account information found',
      '복사를 완료했습니다': 'Copy completed',
      '네트워크 변경': 'Change network',
      '올바르지 않은 토큰 주소입니다.\n주소를 다시 확인해 주세요.':
      'That is an invalid token address.\nPlease double-check the address.',
      '추가하였습니다.': 'Token added.',
      // NetworkInfoScreen........................
      '네트워크 편집': 'Network edit',
      '네트워크 정보': 'Network information',
      '네트워크 편집이 완료되었습니다.': 'Network editing completed.',
      '네트워크를 추가했습니다.': 'Network addition completed.',
      '잘못된 네트워크입니다.': 'Invalid network.',
      '네트워크 조회': 'Network inquiry',
      '이미 추가한 네트워크입니다.\n다시 입력해 주세요.':
      'This network has already been added.\nPlease enter it again.',
      // CoinListScreen...........................
      '토큰이 보이지 않나요?': 'Don\'t see your token?',
      '토큰 추가': 'Add token',
      '토큰 편집': 'Edit token',
      '편집 완료': 'Edit complete',
      '토큰 추가 기능은 리고 메인 네트워크에서\n발행된 토큰(REP-20) 만 지원됩니다.':
      'The token addition feature only supports tokens\n(REP-20) issued on the Rigo main network.',
      '체인코드를 입력해 주세요.': 'Please enter chaincode.',
      '체인코드': 'Chain code',
      '채널': 'Channel',

      '+ 토큰 가져오기': '+ Import tokens',
      '토큰 정보 확인': 'Token contract address inquiry',
      '토큰 주소 조회': 'Token address inquiry',
      '\'Ox\' 문자를 제외한 토큰 주소를 입력해 주세요.':
      'Please enter the token address excluding the \'0x\' characters.',
      '토큰 주소를 입력해 주세요': 'Please enter the token address',
      '토큰 주소': 'Token contract address',
      '토큰 이름': 'Token name',
      '토큰 심볼': 'Token symbol',
      '토큰 소수점': 'Token decimal',
      'REP-20 기반의 토큰 추가만 지원합니다.': 'Only support adding REP-20 tokens.',
      '조 회': 'Inquiry',
      '조회': 'Inquiry',
      '추 가': 'Import',
      '추가': 'Import',
      // CoinDetailScreen.........................
      '거래내역': 'Transaction details',
      'RIGO 네트워크 자산만 받을 수 있습니다.\n'
          '지원하지 않는 자산을 입금한 경우, 회사의 고의나\n'
          '과실이 있지 않는 한 회사는 책임지지 않습니다.':
      'Only RIGO network assets can be received.\n'
          'If you deposit assets that are not supported,\n'
          'it may be due to the company\'s intention\n'
          'The company is not responsible unless there is negligence'
          'You can only receive network assets.',
      '공유': 'Share',
      '복사': 'Copy',
      '공유하기 실패': 'Sharing failed',
      // SendAssetScreen........유..................
      '받는 사람': 'Recipient',
      '확인할 수 없는 지갑 주소입니다': 'The wallet address cannot be verified',
      'QR코드 스캔': 'QR code scan',
      '붙여넣기': 'Paste',
      '수수료(예상)': 'Fees (Estimated)',
      '다시 시도해주세요': 'Please try again',
      '보유한 수량이 부족합니다': 'You don\'t have enough quantity',
      '보내는 자산': 'Send asset',
      '잔고': 'Balance',
      '보낼 수량': 'Send amount',
      '0x로 시작하는 주소를 입력해주세요.': 'Please enter an address starting with 0x.',
      '변경': 'Change',
      '전송할 토큰 변경': 'Change token to send',
      '토큰 변경': 'Change token',
      // SendCompletedScreen.....................
      '코인 전송이 요청되었습니다.': 'Coin transfer requested.',
      // SendConfirmScreen.......................
      '아래 정보로 전송할까요?': 'Shall we send the information below?',
      '예상 수수료': 'Estimated fees',
      '전송': 'Send',
      // TrxHistoryListScreen....................
      '에러가 발생했습니다': 'An error occurred',
      '거래내역이 없습니다': 'There is no transaction history',
      // SelectStakingListScreen.................
      '스테이킹 종료': 'Staking end',
      '스테이킹 리스트 선택': 'Select staking list',
      '_스테이킹': 'staking',
      '위임': 'Delegate',
      '_위임': 'delegate',
      '검증인 선택': 'Choose a validator',
      '위임 종료': 'Delegate end',
      '위임 중인 검증인 선택': 'Select the validator being delegated',
      '위임 리스트': 'Delegate list',
      '다음': 'Next',
      // StakingBottomSheetScreen................
      '금액': 'Amount',
      '연 수익율': 'Annual rate of return',
      '예상 수익(연)': 'Expected profit (per year)',
      '총 스테이킹 금액': 'Total staking amount',
      '스테이킹 기능 이용 주의사항': 'Precautions for using the staking function',
      '스테이킹의 위험을 이해하고 진행합니다.': 'Understand the risks of staking before proceeding.',
      '가스(예상치)': 'Gas(Estimated)',
      '최대요금': 'Maximum fee',
      '합계': 'Total',
      '100,000개의 RIGO 토큰의\n스테이킹이 완료되었습니다.':
      'Staking of 100,000 RIGO tokens\nhas been completed.',
      // StakingCautionScreen.....................
      '기능 이용 주의 사항': 'Precautions for using functions',
      '1.스테이킹을 신청한 디지털 자산은 스테이킹 신청 시부터 언스테이킹이 완료되기 전까지 계정 내 보유 자산 및 출금 가능 자산에서 제외됩니다.\n\n'
      '2.스테이킹 보상은 블록체인 네트워크 상황에 따라 상시 변동합니다. 회사는 이에 관여할 수 없고, 보상 수준에 대해 어떠한 보장도 하지 않습니다.\n\n'
      '3.스테이킹 및 언스테이킹 대기 상태에서는 보상이 발생하지 않습니다.\n\n'
      '4.서비스 와 무관 하게 디지털 자산 자체의 시세 변동이 발생할 수 있으며,서비스 이용중 디지털 자산 시세 변동에 의한 손실은 회사에서는 책임지지 않습니다.\n\n'
      '5.블록체인 네트워크의 지연, 오류, 점검 등에 문제가 발생한 경우,본 서비스 관련 디지털 자산의 입출금 등이 일시적으로 제한될 수 있습니다.\n\n'
      '6.회원은 본 서비스와 관련한 회원의 권리의 전부나 일부 또는 그 계약상 지위를 제3자에게 이전, 양도, 담보제공 등 여하한 방법으로 처분할 수 없습니다.\n\n'
      '※ 스테이킹은 투자 방식 중 하나이며, 부주의하게 진행할 경우 손실을 입을 수 있습니다. 따라서 스테 이킹을 진행하기 전에 원리와 리워드 수령 방식, 수수료율, 예치하는 자산의 안정성과 위험성, 자금 운 용 계획 등을 충분히 검토하고 신중하게 판단하여 진행해야 합니다.':
      '1.Digital assets applied for staking are excluded from the assets held in the account and assets available for withdrawal from the time of staking application until unstaking is completed.\n\n'
      '2.Staking rewards always fluctuate depending on the blockchain network situation. The company has no involvement in this and makes no guarantees regarding the level of compensation.\n\n'
      '3.Rewards do not occur while staking and unstaking are pending.\n\n'
      '4.The price of the digital asset itself may fluctuate regardless of the service, and the company is not responsible for any losses resulting from fluctuations in the digital asset price while using the service.\n\n'
      '5.If problems such as delays, errors, or maintenance occur in the blockchain network, deposits and withdrawals of digital assets related to this service may be temporarily restricted.\n\n'
      '6.Members may not dispose of all or part of their rights related to this service or their contractual status in any way, such as transferring, assigning, or providing collateral to a third party.\n\n'
      '※ Staking is one of the investment methods, and if done carelessly, you may suffer losses. Therefore, before proceeding with staking, you must thoroughly review and carefully consider the principles, reward receipt method, commission rate, stability and risk of deposited assets, fund management plan, etc.',
      '1.위임을 신청한 디지털 자산은 위임 신청 시부터 위임종료가 완료되기 전까지 계정 내 보유 자산 및 출금 가능 자산에서 제외됩니다.\n\n'
      '2.위임 보상은 블록체인 네트워크 상황에 따라 상시 변동합니다. 회사는 이에 관여할 수 없고, 보상 수준에 대해 어떠한 보장도 하지 않습니다.\n\n'
      '3.위임 및 위임종료 대기 상태에서는 보상이 발생하지 않습니다.\n\n'
      '4.서비스 와 무관 하게 디지털 자산 자체의 시세 변동이 발생할 수 있으며,서비스 이용중 디지털 자산 시세 변동에 의한 손실은 회사에서는 책임지지 않습니다.\n\n'
      '5.블록체인 네트워크의 지연, 오류, 점검 등에 문제가 발생한 경우,본 서비스 관련 디지털 자산의 입출금 등이 일시적으로 제한될 수 있습니다.\n\n'
      '6.회원은 본 서비스와 관련한 회원의 권리의 전부나 일부 또는 그 계약상 지위를 제3자에게 이전, 양도, 담보제공 등 여하한 방법으로 처분할 수 없습니다.\n\n'
      '※ 위임은 투자 방식 중 하나이며, 부주의하게 진행할 경우 손실을 입을 수 있습니다. 따라서 스테 이킹을 진행하기 전에 원리와 리워드 수령 방식, 수수료율, 예치하는 자산의 안정성과 위험성, 자금 운 용 계획 등을 충분히 검토하고 신중하게 판단하여 진행해야 합니다.':
      '1.Digital assets applied for delegation are excluded from the assets held in the account and assets available for withdrawal from the time of application for delegation until the end of delegation.\n\n'
      '2.Delegation rewards always fluctuate depending on the blockchain network situation. The company has no involvement in this and makes no guarantees regarding the level of compensation.\n\n'
      '3.Compensation does not occur while waiting for delegation or completion of delegation.\n\n'
      '4.The price of the digital asset itself may fluctuate regardless of the service, and the company is not responsible for any losses resulting from fluctuations in the digital asset price while using the service.\n\n'
      '5.If problems such as delays, errors, or maintenance occur in the blockchain network, deposits and withdrawals of digital assets related to this service may be temporarily restricted.\n\n'
      '6.Members may not dispose of all or part of their rights related to this service or their contractual status in any way, such as transferring, assigning, or providing collateral to a third party.\n\n'
      '※ Delegation is one of the investment methods, and if done carelessly, you may suffer losses. Therefore, before proceeding with staking, you must carefully review and carefully consider the principles, reward receipt method, commission rate, stability and risk of deposited assets, fund management plan, etc.',
      '스테이킹 신청 시, 취소 또는 변경 하실 수 없습니다.': 'When applying for staking, you cannot cancel or change it.',
      // StakingMainScreen........................
      '검증인': 'Validator',
      // StakingConfirmScreen.....................
      '오류가 발생했습니다. 다시 시도해주세요.': 'An error occurred. please try again.',
      '총 수량\n(수수료 포함)': 'Total amount\n(including fees)',
      '정보를 확인해 주세요': 'Please check send information',
      // StakingInputScreen.......................
      '코인 보유량': 'Coin holding',
      '위임 금액': 'Delegated amount',
      '총 위임 금액': 'Total delegation amount',
      '총': 'Total',
      ' 금액': ' amount',
      '기능 이용 주의사항': 'Precautions for using functions',
      '의 위험을 이해하고 진행합니다.': 'Understand the risks and proceed.',
      // UnStakingBottomSheetScreen...............
      '스테이킹 종료금액': 'Staking end amount',
      '종료': 'end',
      '보유량': 'Reserves',
      '종료 금액': 'End amount',
      '남은': 'Remain',
      ' 기능 이용 주의사항': ' precautions for using functions',
      // StakingScreen............................
      '내': 'My',
      '보상': 'reward',
      '년': 'year',
      '월': 'month',
      '일': 'day',
      // StakingListRadioColumn....................
      '지분 비율': 'Equity ratio',
      '스테이킹 비율': 'Staking Ratio',
      '총 스테이킹': 'Total staking',
      '일일 보상량': 'Daily reward amount',
      '보상량': 'Reward amount',
      '언스테이킹': 'Unstaking',
      // NetworkErrorScreen......................
      '네트워크에 문제가 생겼어요': 'There is a problem with the network',
      '문제를 해결하기 위해 열심히 노력하고 있습니다.\n잠시 후 다시 확인해주세요.':
      'We are working hard to resolve the issue.\nPlease check back later.',
      // WrongPasswordDialog.....................
      '비밀번호가 일치하지 않습니다': 'Passwords do not match',
      '비밀번호를 다시 입력해 주세요.': 'Please re-enter your password.',
      // SimpleCheckDialog.......................
      '옵션 텍스트': 'Option text',
      // SettingsMenu............................
      '최신 버전 사용 중': 'Using the latest version',
      // QuantityColumn..........................
      '스테이킹 보유량': 'Staking holdings',

      '잠금 해제': 'Unlock',
      '지갑 초기화': 'Reset wallet',
      '지갑 만들기': 'Create wallet',
      '지갑 복구': 'Recover wallet',
      '_예': 'ex',

      // trinity M
      'Market': 'Market',
      '내 정보': 'My Info',
      'ID(닉네임)': 'ID(nickname)',
      '사용자 이름': 'User name',
      '본인인증': 'Identity verification',
      '계정': 'Account',
      '인증': 'Verification',
      '인증 완료': 'Verification completed',
      '계정 복구 단어 보기': 'View account recovery words',
      '회원 탈퇴 신청': 'Apply for membership withdrawal',
      '신청': 'Application',
      '로그아웃 & 앱 초기화': 'Log out & reset app',
      '구매 내역': 'Purchase history',
      '이용약관': 'Terms of use',
      '개인정보처리 방침': 'Privacy policy',
      '버전 정보': 'App version',
      '로그아웃': 'Log out',
      '조회 기간': 'Inquiry period',
      '상품 정보': 'Product information',
      '구매 상세': 'Purchase details',
      '선택완료': 'Complete',
      '상품이 없습니다.': 'There are no products.',
      '구매하기': 'Purchase',
      '구매 상품': 'Purchase product',
      '결제 금액': 'Amount of payment',
      '거래 일시': 'Transaction time',
      '결제 수단': 'Payment method',
      '바코드': 'Barcode',
      '결제 예정 금액을 확인해 주세요.': 'Please check the amount to be paid.',
      '상품 금액': 'Product amount',
      '결제 예정 금액': 'Payment amount',
      '결제하기': 'Make payment',
      '프로필 편집': 'Edit profile',
      '보유 상품': 'Products you own',
      '판매중인 상품이 없습니다.': 'There are no products for sale.',
      '계정 추가': 'Add account',
      '계정 선택': 'Select account',
      '계정명을 입력해 주세요.': 'Please enter your account name.',
      '프로필 변경': 'Change profile',
      '변경할 프로필 내용을 입력해 주세요.': 'Please enter the profile information you want to change.',
      '비밀번호 입력': 'Enter password',
      '현재 버전': 'Current version',
      '앱 버전정보': 'App version information',
      '현재 최신 버전 사용 중입니다.': 'This is currently the latest version.',
      '사용자 이름 변경': 'Change username',
      '변경할 이름을 입력해 주세요.': 'Please enter the name you want to change.',
      'ID(닉네임) 변경': 'Change ID(nickname)',
      '프로필 정보가 없습니다.': 'There is no profile information.',
      '사업자명: 주식회사 엑시노\n'
          '대표이사: 이지민\n'
          '등록번호: 644-86-03081\n'
          '대표번호: 070-4304-5778\n'
          '서울시 서초구 서운로 13 126-나94호':
      'Business name: Xinno Inc.\n'
          'CEO: Ji-min Lee\n'
          'Registration number: 644-86-03081\n'
          'Phone number: 070-4304-5778\n'
          '#126-Na94, 13 Seoun-ro, Seocho-gu, Seoul',
      '(주)엑시노는 통신판매 중개자이며,\n통신판매의 당사자가 아닙니다.\n'
          '이에 따라, 당사는 상품, 거래정보 및\n거래에 대하여 책임을 지지 않습니다.':
      'Exino Co., Ltd. is a mail order intermediary\nand is not a party to the mail order.\n'
          'Accordingly, we are not responsible for products,\ntransaction information, or transactions.',

      '새 버전': 'New version',
      '비밀번호를\n입력해 주세요.': 'Please enter\nyour password.',
      '복구 비밀번호를\n등록해 주세요.': 'Please register\nyour recovery password.',
      '복구 비밀번호를\n입력해 주세요.': 'Please enter\nthe recovery password.',
      '새 비밀번호를\n입력해 주세요.': 'Please enter\nthe new password.',
      '비밀번호를\n등록해 주세요.': 'Please register\nyour password.',
      '회원가입시 생성한\n비밀번호를 입력해 주세요.': 'Please enter the password\nyou created when signing up.',
      '클라우드에 복구 단어를 백업합니다.\n'
          '앱 재설치시 복구 비밀번호를 사용하여\n지갑복구가 가능합니다.':
      'Backup your recovery words to the cloud.\n'
          'When reinstalling the app, you can recover\nyour wallet using the recovery password.',
      '클라우드에 백업시 생성한\n비밀번호를 입력해 주세요.':
          'Please enter the password you\ncreated when backing up to the cloud.',
      '비밀번호 등록을 진행합니다.': 'Proceed with password registration.',
      '상품 목록 마지막입니다.': 'This is the last product list.',
      '계정 복구 단어 백업': 'Recovery Word Backup',
      '계정 복구를 위한\n복구 단어를 보관하세요.': 'Please save the Recovery word\nfor account recovery.',
      '계정 복구 단어를 안전한 곳에 보관해 주세요.\n잃어버리실 경우 계정 복구가 불가합니다.':
          'Please keep your account recovery words in a safe place.\n'
              'If you lose your account, recovery is not possible.',
      '클라우드 백업': 'Cloud backup',
      '복구 단어 복사하기': 'Copy recovery word',
      '문구가 복사되었습니다.': 'The text has been copied.',
      '회원가입 완료.': 'Membership registration completed.',
      '보유중인 상품이 없슴니다.': 'There are no products in stock.',
      '비밀번호 재입력': 'Re-enter password',
      '클라우드 백업을 위해\n구글 로그인을 진행합니다.':
        'For cloud backup\nProceed to Google login.',
      '클라우드 접근을 위해\n구글 로그인을 진행합니다.':
        'To access the cloud\nProceed to login to Google.',
      '전체': 'All',
      '골프': 'Golf',
      'F&B': 'F&B',
      '숙박': 'Hotel',
      '여행': 'Tour',
      '공연': 'Show',
      '레저': 'Leisure',
      '영화': 'Movie',
      '게임': 'Game',
      '저장 위치 선택': 'Select storage location',
      '파일명': 'Filename',
      '저장 폴더': 'Save folder',
      '선택 파일': 'Select file',
      '복구 파일 선택': 'Select recovery file',
      '업로드': 'Upload',
      '다운로드': 'Download',
      '복구키를 백업중 입니다..': 'Backing up the recovery key..',
      '복구키를 내려받는 중 입니다..': 'Downloading recovery key..',
      '복구키 백업 완료': 'Recovery key backup completed',
      '복구키 백업 실패': 'Recovery key backup failed',
      '복구키 받기 완료': 'Completed receiving recovery key',
      '복구키 받기 실패': 'Failed to receive recovery key',
      '계정 복구중입니다...': 'Account is being restored...',
      '로그아웃 완료': 'Logout complete',
      '로그인이 필요한 서비스입니다.': 'This service requires login.',
      '로그인': 'Log in',
      '이메일로 로그인': 'Log in with Email',
      '카카오로 로그인': 'Log in with Kakao',
      '이메일로 회원가입': 'Signup by Email',
      '카카오로 회원가입': 'Signup by Kakao',
      '이메일 로그인': 'Log in with Email',
      '이메일 형식을 확인해 주세요.': 'Please check your email format.',
      '로그인중입니다...': 'Logging in...',
      '로그인 성공': 'log-in succeed',
      '이메일 인증을 진행합니다.': 'Proceed with email verification.',
      '이메일을\n등록해 주세요.': 'Please register\nyour email address.',
      '이메일 주소 입력': 'Input email address',
      '인증 링크 받기': 'Get verification link',
      '발송 완료 / 재발송': 'Sent completed / Resend',
      '이메일 인증 완료': 'Email verification completed',
      '이메일 등록': 'Email registration',
      '인증 링크가 발송 되었습니다.': 'A verification link has been sent.',

      '서버에 접속할 수 없습니다.': 'Unable to connect to server.',
      '이미 사용중인 이메일주소입니다.': 'This email address is already in use.',
      '메일전송에 실패했습니다.': 'Email sending failed.',
      '메일확인에 실패했습니다.': 'Email verification failed.',
      '인증이 완료되지않았습니다.\n(받은 이메일을 확인해 주세요)':
        'Authentication has not been completed.\n(Please check the email you received)',
      '이미 사용중인 닉네임입니다.': 'this nickname is already using.',
      '잘못된 계정이나 패스워드 입니다.': 'Invalid account or password.',
      '잘못된 패스워드 입니다.': 'This is an incorrect password.',
      '카카오 로그인에 실패했습니다.': 'Kakao login failed.',
      '로그인에 실패했습니다.': 'Log in failed.',
      '복구가 필요한 이메일입니다.': 'This email needs recovery.',
      '복구에 실패했습니다.': 'Recovery failed.',
      '회원가입이 필요한 메일입니다.': 'This email requires membership registration.',
      '회원가입에 실패했습니다.': 'Membership registration failed.',
      '트리니티M 을 이용해주셔서 감사합니다.\n서비스 이용을 위해 약관 동의가 필요합니다.':
        'Thank you for using Trinity M.\n'
        'Agreement to the terms and conditions\nis required to use the service.',
      '사용자 이름을\n등록해 주세요.': 'Please register\nyour user name.',
      '서비스에서 사용 될 ID(닉네임)입니다.\n가입 후 변경 가능합니다.':
        'This is the ID (nickname) that will be used in the service.\nYou can change it after signing up.',
      '사용자 이름 입력': 'Enter your username',
      '중복 확인': 'Double check',
      '중복 확인 완료': 'Duplicate check completed',
      '회원 가입중입니다...': 'Signing up as a member...',
      '회원가입 성공': 'Membership registration successful',
      '회원가입 실패': 'Membership registration failed',
      '생체인증 등록': 'Biometric authentication registration',
      '건너뛰기': 'Skip',
      '본인 인증': 'Identity verification',
      '잠시만 기다려주세요...': 'please wait for a moment...',
      '본인인증 성공': 'Identity verification successful',
      '본인인증 실패': 'Identity verification failed',
      '이미 본인인증을 완료했습니다.': 'Already completed your identity verification.',
      '인증 미완료': 'Authentication incomplete',
      '신청후 일주일후에\n탈퇴 처리가 완료됩니다.':
        'Withdrawal processing will be\ncompleted one week after application.',
      '*주의: 탈퇴 처리가 완료된 후에는\n'
        '본 계정으로 접속이 불가능하며,\n'
        '보유한 자산이 있으면 잃어버리게 됩니다.': '*Caution: After withdrawal processing\nis completed\n'
        'Connection is not possible with this account,\n'
        'If you have any assets, you will lose them.',
      '탈퇴 신청': 'Withdrawal',
      '회원 탈퇴 신청 완료': 'Withdrawal application completed',
      '회원 탈퇴 신청 실패': 'Withdrawal application failed',
      '앱 초기화 완료': 'App initialization complete',
      '복구단어로 복구': 'Recover with recovery word',
      '클라우드로 복구': 'Recovery with Cloud',
      '지갑 복구 수단을\n선택해 주세요.': 'Please select\nyour wallet recovery method.',
      '서비스 이용을 위해 지갑 복구가 필요합니다.\n'
          '지갑 복구방식을 선택해 주세요.':
      'Wallet recovery is required to use the service.\n'
          'Please select a wallet recovery method.',
      '계정 복구 실패': 'Account recovery failed',
      '잘못된 계정입니다.\n복구한 계정일 경우,\n복구 파일이나 단어를 확인해 주세요.':
          'This is the wrong account.\nIf the account has been recovered,\n'
          'Please check the recovered file or word.',
      '백업에 실패했습니다.': 'Backup failed.',
      '백업 대상을 선택해 주세요.': 'Please select a backup destination.',
      '애플 iCloud': 'Apple iCloud',
      '구글 드라이브': 'Google Drive',
      '다운로드에 실패했습니다.': 'Download failed.',
      'iCloud에 로그인 되어있지 않습니다.': 'You are not logged in to iCloud.',
      '대상을 찾을 수 없습니다.': 'Target not found.',
      'iCloud 활성화가 필요합니다.\n설정 > Apple ID, iCloud':
        'iCloud activation is required.\nSettings > Apple ID, iCloud',
      '백업이 완료됬습니다.': 'Backup has been completed.',
      '복구에 성공했습니다.': 'Recovery was successful.',
      '결제방식을 선택해주세요.': 'Please select a payment method.',
      '신용카드': 'Credit card',
      '계좌이체': 'Account transfer',
      '이체금액': 'Transfer amount',
      '은행명': 'Name of bank',
      '계좌번호': 'Account number',
      '생체인증 설정 완료': 'Biometric authentication setup complete',
      '변경할 닉네임 입력해 주세요.': 'Please enter the nickname you want to change.',
      '구매한 상품이 없습니다.': 'No products have been purchased.',
      '계정 변경 성공': 'Account change successful',
      '계정 변경 실패': 'Account change failed',
      '잘못된 비밀번호입니다.': 'Invalid password.',
      '회원 탈퇴 신청중': 'Applying for membership withdrawal',
      '탈퇴 완료까지 남은시간': 'Time remaining until withdrawal is completed',
      '시간': 'ours',
      '탈퇴 신청을 취소하시겠습니까?': 'Would you like to cancel\nyour withdrawal request?',
      '회원 탈퇴 취소': 'Cancel membership withdrawal',
      '회원 탈퇴 취소 완료': 'Cancellation completed',
      '': '',
      '': '',
    },
    'ko': {
      '_예': '예',
      '_자산': '자산',
      '_수량': '수량',
      '_스테이킹': '스테이킹',
      '_위임': '위임',
      'reset_00': '초기화를 진행하시려면,\n',
      'reset_01': '아래에 ',
      'reset_02': '초기화 ',
      'reset_03': '라고 입력해주세요',
    }
  };

  String translate(String key) {
    if (_localizedValues[locale.languageCode] == null) return key;
    if (_localizedValues[locale.languageCode]![key] == null) {
      if (locale.languageCode != 'ko') {
        log('************ [$key] not fount! *************');
      }
      return key;
    }
    return _localizedValues[locale.languageCode]![key] ?? key;
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  AppLocalizationDelegate();
  late AppLocalization appLocale;

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) {
    appLocale = AppLocalization(locale);
    return SynchronousFuture<AppLocalization>(appLocale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  translate(String text) {
    return appLocale.translate(text);
  }
}
