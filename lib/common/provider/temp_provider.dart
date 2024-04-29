import 'package:larba_00/common/provider/coin_provider.dart';
import 'package:larba_00/presentation/view/account/account_manage_screen.dart';
import 'package:larba_00/presentation/view/asset/asset_screen.dart';
import 'package:larba_00/presentation/view/asset/token_add_screen.dart';
import 'package:larba_00/presentation/view/account/export_privatekey_screen.dart';
import 'package:larba_00/presentation/view/account/import_privatekey_screen.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/asset/coin_detail_screen.dart';
import 'package:larba_00/presentation/view/registLocalAuth_screen.dart';
import 'package:larba_00/presentation/view/asset/send_completed_screen.dart';
import 'package:larba_00/presentation/view/registMnemonic_check_screen.dart';
import 'package:larba_00/presentation/view/registMnemonic_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_policy_screent.dart';
import 'package:larba_00/presentation/view/settings/settings_security_screen.dart';
import 'package:larba_00/presentation/view/sign_password_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_terms_screen.dart';
import 'package:larba_00/presentation/view/staking/select_staking_list_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_confirm_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_input_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_main_screen.dart';
import 'package:larba_00/presentation/view/staking/unstaking_input_screen.dart';
import 'package:larba_00/presentation/view/terms_detail_screen.dart';
import 'package:larba_00/presentation/view/account/user_info_screen.dart';
import 'package:larba_00/presentation/view/user_leave_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larba_00/main.dart';
import 'package:larba_00/presentation/view/authcompleted_screen.dart';
import 'package:larba_00/presentation/view/authpassword_screen.dart';
import 'package:larba_00/presentation/view/registNumber_screen.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/home_screen.dart';
import 'package:larba_00/presentation/view/authlocal_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/myhome_screen.dart';
import 'package:larba_00/presentation/view/registPassword_screen.dart';
import 'package:larba_00/presentation/view/registComplete_screen.dart';
import 'package:larba_00/presentation/view/sign_generate_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larba_00/presentation/view/terms_screen.dart';

import '../../presentation/view/account/export_rwf_pass_screen.dart';
import '../../presentation/view/asset/networkScreens/network_list_screen.dart';
import '../../presentation/view/asset/send_asset_screen.dart';
import '../../presentation/view/asset/swapScreen/swap_asset_screen.dart';
import '../../presentation/view/market/market_screen.dart';
import '../../presentation/view/recover_wallet_complete_screen.dart';
import '../../presentation/view/recover_wallet_input_screen.dart';
import '../../presentation/view/recover_wallet_register_password.dart';
import '../../presentation/view/settings/settings_language_screen.dart';
import '../../presentation/view/settings/settings_screen.dart';
import '../../presentation/view/staking/staking_caution_screen.dart';
import '../const/utils/convertHelper.dart';

var isGlobalLogin = false;
var isRecoverLogin = false;

double totalDelegateAmount = 0.0;

//TODO: - 로그인 관련 Provider 작성 후 교체 예정. 2023.01.17 liam
final tempProvider = ChangeNotifierProvider<TempProvider>((ref) {
  return TempProvider(ref: ref);
});

class TempProvider extends ChangeNotifier {
  final Ref ref;
  bool? isLogin;
  bool? isError;

  TempProvider({
    required this.ref,
  }) {}

  List<GoRoute> get route => [
        GoRoute(
          path: '/init',
          name: MyHomePage.routeName,
          builder: (_, __) => MyHomePage(title: 'ChangeTitle'),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (context, state) => LoginScreen(
            isAppStart: BOL(state.queryParams['isAppStart']),
          ),
        ),
        GoRoute(
          path: '/signUpTerms',
          name: SignUpTermsScreen.routeName,
          builder: (_, __) => SignUpTermsScreen(),
        ),
        GoRoute(
          path: '/signGenerate',
          name: SignGenerateScreen.routeName,
          builder: (context, state) => SignGenerateScreen(
            noti: state.queryParams['noti'],
          ),
        ),
        GoRoute(
          path: '/firebaseSetup',
          name: FirebaseSetup.routeName,
          builder: (context, state) => FirebaseSetup(),
        ),
        GoRoute(
          path: '/terms',
          name: TermsScreen.routeName,
          builder: (_, __) => TermsScreen(),
        ),
        GoRoute(
          path: '/registNumber',
          name: RegistNumberScreen.routeName,
          builder: (_, __) => RegistNumberScreen(),
        ),
        GoRoute(
          path: '/registPassword',
          name: RegistPasswordScreen.routeName,
          builder: (context, state) => RegistPasswordScreen(
            reset: state.queryParams['reset'],
            prevPassword: state.queryParams['prevPassword'],
          ),
        ),
        GoRoute(
          path: '/registLocalAuth',
          name: RegistLocalAuthScreen.routeName,
          builder: (context, state) => RegistLocalAuthScreen(
            previousScreen: state.queryParams['previousScreen'],
          ),
        ),
        GoRoute(
          path: '/registComplete',
          name: RegistCompleteScreen.routeName,
          builder: (contetx, state) => RegistCompleteScreen(
            join: state.queryParams['join'],
            reset: state.queryParams['reset'],
            addAccount: state.queryParams['addAccount'],
            loadAccount: state.queryParams['loadAccount'],
          ),
        ),
        GoRoute(
          path: '/home',
          name: HomeScreen.routeName,
          builder: (_, __) => HomeScreen(),
        ),
        GoRoute(
          path: '/authlocal',
          name: AuthLocalScreen.routeName,
          builder: (_, __) => AuthLocalScreen(),
        ),
        GoRoute(
          path: '/authpassword',
          name: AuthPasswordScreen.routeName,
          builder: (context, state) => AuthPasswordScreen(
            auth: state.queryParams['auth'],
            reset: state.queryParams['reset'],
            mnemonic: state.queryParams['mnemonic'],
            export_privateKey: state.queryParams['export_privateKey'],
            export_rwf: state.queryParams['export_rwf'],
            addKeyPair: state.queryParams['addKeyPair'],
            import_privateKey: state.queryParams['import_privateKey'],
          ),
        ),
        GoRoute(
          path: '/mainScreen',
          name: MainScreen.routeName,
          builder: (context, state) => MainScreen(
            selectedPage: INT(state.queryParams['selectedPage']),
          ),
        ),
        GoRoute(
          path: '/history',
          name: HistoryScreen.routeName,
          builder: (_, __) => HistoryScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: SettingsScreen.routeName,
          builder: (_, __) => SettingsScreen(),
        ),
        GoRoute(
          path: '/authcompleted',
          name: AuthCompletedScreen.routeName,
          builder: (context, state) => AuthCompletedScreen(
            noti: state.queryParams['noti'],
          ),
        ),
        GoRoute(
          path: '/settings_language',
          name: SettingsLanguageScreen.routeName,
          builder: (context, state) => SettingsLanguageScreen(),
        ),
        GoRoute(
          path: '/settings_security',
          name: SettingsSecurityScreen.routeName,
          builder: (context, state) => SettingsSecurityScreen(),
        ),
        GoRoute(
          path: '/settings_policy',
          name: SettingsPolicyScreen.routeName,
          builder: (context, state) => SettingsPolicyScreen(),
        ),
        GoRoute(
          path: '/terms_detail',
          name: TermsDetailScreen.routeName,
          builder: (context, state) => TermsDetailScreen(
            title: state.queryParams['title'],
            type: state.queryParams['type'],
          ),
        ),
        GoRoute(
          path: '/marketScreen',
          name: MarketScreen.routeName,
          builder: (context, state) => MarketScreen(),
        ),
        GoRoute(
          path: '/assetScreen',
          name: AssetScreen.routeName,
          builder: (context, state) => AssetScreen(),
        ),
        GoRoute(
          path: '/userinfo',
          name: UserInfoScreen.routeName,
          builder: (context, state) => UserInfoScreen(),
        ),
        GoRoute(
          path: '/userleave',
          name: UserLeaveScreen.routeName,
          builder: (context, state) => UserLeaveScreen(),
        ),
        GoRoute(
          path: '/sendAssetScreen',
          name: SendAssetScreen.routeName,
          builder: (context, state) => SendAssetScreen(
            walletAddress: state.queryParams['walletAddress'],
          ),
        ),
        GoRoute(
          path: '/sendCompletedScreen',
          name: SendCompletedScreen.routeName,
          builder: (context, state) => SendCompletedScreen(
            sendAmount: state.queryParams['sendAmount'],
            symbol: state.queryParams['symbol'],
          ),
        ),
        GoRoute(
          path: '/${SwapAssetScreen.routeName}',
          name: SwapAssetScreen.routeName,
          builder: (context, state) => SwapAssetScreen(
            walletAddress: state.queryParams['walletAddress'],
          ),
        ),
        GoRoute(
          path: '/coinDetailScreen',
          name: CoinDetailScreen.routeName,
          builder: (context, state) => CoinDetailScreen(
            coinName: state.queryParams['coinName'],
          ),
        ),
        GoRoute(
          path: '/sign_password',
          name: SignPasswordScreen.routeName,
          builder: (context, state) => SignPasswordScreen(
            receivedAddress: state.queryParams['receivedAddress'],
            sendAmount: state.queryParams['sendAmount'],
            // coinName: state.queryParams['coinName'],
          ),
        ),
        GoRoute(
          path: '/staking_main',
          name: StakingMainScreen.routeName,
          builder: (context, state) => StakingMainScreen(),
        ),
        GoRoute(
          path: '/staking_input',
          name: StakingInputScreen.routeName,
          builder: (context, state) => StakingInputScreen(),
        ),
        GoRoute(
          path: '/unStaking_input',
          name: UnStakingInputScreen.routeName,
          builder: (context, state) => UnStakingInputScreen(),
        ),
        GoRoute(
          path: '/select_staking_list',
          name: SelectStakingListScreen.routeName,
          builder: (context, state) => SelectStakingListScreen(
            delegateAddress: state.queryParams['delegateAddress']!,
          ),
        ),
        GoRoute(
          path: '/${StakingCautionScreen.routeName}',
          name: StakingCautionScreen.routeName,
          builder: (context, state) => StakingCautionScreen(),
        ),
        GoRoute(
          path: '/staking_confirm',
          name: StakingConfirmScreen.routeName,
          builder: (context, state) => StakingConfirmScreen(),
        ),
        GoRoute(
          path: '/registMnemonic',
          name: RegistMnemonicScreen.routeName,
          builder: (context, state) => RegistMnemonicScreen(
            hasCheck: state.queryParams['hasCheck'],
          ),
        ),
        GoRoute(
          path: '/registMnemonicCheck',
          name: RegistMnemonicCheckScreen.routeName,
          builder: (context, state) => RegistMnemonicCheckScreen(),
        ),
        GoRoute(
          path: '/export_privateKey',
          name: ExportPrivateKeyScreen.routeName,
          builder: (context, state) => ExportPrivateKeyScreen(
            info: state.queryParams['info'],
          ),
        ),
        GoRoute(
          path: '/${ExportRWFPassScreen.routeName}',
          name: ExportRWFPassScreen.routeName,
          builder: (context, state) => ExportRWFPassScreen(
            privateKey: state.queryParams['privateKey'],
          ),
        ),
        GoRoute(
          path: '/account_manage',
          name: AccountManageScreen.routeName,
          builder: (context, state) => AccountManageScreen(),
        ),
        GoRoute(
          path: '/recover_wallet_input',
          name: RecoverWalletInputScreen.routeName,
          builder: (context, state) => RecoverWalletInputScreen(),
        ),
        GoRoute(
          path: '/recover_wallet_register_password',
          name: RecoverWalletRegisterPassword.routeName,
          builder: (context, state) => RecoverWalletRegisterPassword(
            mnemonic: state.queryParams['mnemonic'],
          ),
        ),
        GoRoute(
          path: '/recover_wallet_complete',
          name: RecoverWalletCompleteScreen.routeName,
          builder: (context, state) => RecoverWalletCompleteScreen(),
        ),
        GoRoute(
          path: '/import_privateKey',
          name: ImportPrivateKeyScreen.routeName,
          builder: (context, state) => ImportPrivateKeyScreen(),
        ),
        GoRoute(
          path: '/network_list',
          name: NetworkListScreen.routeName,
          builder: (context, state) => NetworkListScreen(),
        ),
      ];

  String? redirectLogic(BuildContext context, GoRouterState state) {
    print("redirectLogic" + state.location.toString());
    // juan : 'other' 단어가 mnemonic 에 포함 될 경우 분기 오류..
    if (state.location.contains('other=')) {
      return '/home';
    }
    return null;
  }
}

final errorProvider = StateProvider((ref) => false);

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/mainScreen';

  String get currentRoute => _currentRoute;

  void navigateTo(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  void navigateBack() {
    _currentRoute = '/mainScreen';
    notifyListeners();
  }
}
