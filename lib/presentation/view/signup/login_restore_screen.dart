
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/dialog_utils.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/signup/signup_pass_screen.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/rwfExportHelper.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../services/google_service.dart';
import '../../../services/icloud_service.dart';
import '../main_screen.dart';
import '../recover_wallet_input_screen.dart';
import 'login_pass_screen.dart';

class LoginRestoreScreen extends ConsumerStatefulWidget {
  const LoginRestoreScreen({Key? key}) : super(key: key);
  static String get routeName => 'loginRestoreScreen';

  @override
  ConsumerState createState() => _LoginRestoreScreenState();
}

class _LoginRestoreScreenState extends ConsumerState<LoginRestoreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR('지갑 복구')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.only(top: 30.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TR('지갑 복구 수단을\n선택해 주세요.'),
                    style: typo24bold150,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    TR('서비스 이용을 위해 지갑 복구가 필요합니다.\n'
                       '지갑 복구방식을 선택해 주세요.'),
                    style: typo16medium150.copyWith(
                      color: GRAY_70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 160.h),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildMenuButton('복구단어로 복구', startRecoverMnemonic),
                  _buildMenuButton('클라우드로 복구', startRecoverCloud),
                ],
              )
            ),
          ],
        )
      ),
    );
  }

  // 니모닉으로 계정 복구..
  startRecoverMnemonic() {
    final prov = ref.read(loginProvider);
    Navigator.of(context).push(
      createAniRoute(RecoverWalletInputScreen())).then((mnemonic) {
      LOG('--> RecoverWalletInputScreen result : ${prov.userEmail} / $mnemonic');
      if (STR(mnemonic).isNotEmpty) {
        // create password..
        Navigator.of(context).push(
          createAniRoute(RecoverPassScreen())).then((newPass) {
            prov.setUserPass(newPass);
            showLoadingDialog(context, TR('계정 복구중입니다...'));
            prov.recoverUser(
              newPass,
              mnemonic: mnemonic,
              onError: (type, code) {
                hideLoadingDialog();
                showLoginErrorDialog(context, type, text: code);
                UserHelper().clearUser();
              }).then((result) {
            LOG('--> startRecoverMnemonic mn result : $result');
            hideLoadingDialog();
            _recoverResult(result);
          });
        });
      }
    });
  }

  // 클라우드로 계정 복구..
  startRecoverCloud() {
    final prov = ref.read(loginProvider);
    if (defaultTargetPlatform == TargetPlatform.android) {
      _startGoogleCloud();
      return;
    }
    showSelectDialog(context, TR('대상을 선택해 주세요.'),
        ['Apple iCloud', 'Google Drive']).then((result) {
      switch (result) {
        case 0:
          _startAppleCloud();
          break;
        case 1:
          _startGoogleCloud();
          break;
      }
    });
  }

  _startGoogleCloud() async {
    GoogleService.downloadKeyFromDrive(context).then((rwfStr) {
      if (STR(rwfStr).isNotEmpty) {
        _startRecover(rwfStr);
      }
    });
  }

  _startAppleCloud() async {
    final prov = ref.read(loginProvider);
    ICloudService.downloadKeyFromDrive(context, prov.userEmail,
      (rwfStr) => _startRecover(rwfStr),
      (err) => showToast('${TR('복구에 실패했습니다.')}\n$err'));
  }

  _startRecover(rwfStr) {
    Navigator.of(context).push(
        createAniRoute(CloudPassScreen())).then((pass) async {
      // cloud pass check..
      if (STR(pass).isNotEmpty) {
        // recover mnemonic..
        var result = await RWFExportHelper.decrypt(pass, rwfStr);
        if (result != null && result.length > 1) {
          LOG('--> RWFExportHelper.decrypt result : $pass / ${result.length}');
          // new pass create..
          var mnemonic = result.length > 1 ? result[1] : result[0];
          Navigator.of(context)
              .push(createAniRoute(RecoverPassScreen()))
              .then((newPass) async {
            if (STR(newPass).isNotEmpty) {
              final prov = ref.read(loginProvider);
              prov.setUserPass(newPass!);
              showLoadingDialog(context, TR('계정 복구중입니다...'));
              // start recover user..
              prov.recoverUser(
                newPass,
                mnemonic: mnemonic,
                onError: (type, code) {
                  hideLoadingDialog();
                  showLoginErrorDialog(context, type, text: code);
                  UserHelper().clearUser();
                }).then((result) {
                LOG('--> startRecoverCloud mn result : $result');
                hideLoadingDialog();
                _recoverResult(result);
              });
            } else {
              LOG('--> startRecoverCloud mn cancel');
            }
          });
        } else {
          showLoginErrorTextDialog(context, TR('잘못된 복구 비밀번호입니다.'));
        }
      }
    });
  }

  _recoverResult(result) {
    if (result != null) {
      _moveToMainProfile();
      showToast(TR('복구에 성공했습니다.'));
    } else {
      showToast(TR('복구에 실패했습니다.'));
    }
  }

  // _recoverRwfKey(String pass, String rwfStr) async {
  //   LOG('--> _recoverRwfKey : $pass / $rwfStr');
  //   final loginProv = ref.read(loginProvider);
  //   // if (STR(pass).isNotEmpty) {
  //   //   final shaConvert = crypto.sha256.convert(utf8.encode(pass));
  //   //   final keyStr = await AesManager().decrypt(shaConvert.toString(), keyData);
  //   //   LOG('---> privateKey create : $pass -> $keyStr');
  //   //   if (keyStr != 'fail') {
  //   //     var keyJson = jsonDecode(keyStr);
  //   //     var privateKey = STR(keyJson['publicKey']);
  //   //   var utf8List = utf8.encode(pass);
  //   //   var rwfPass = crypto.sha256.convert(utf8List).toString();
  //   //   // var privateKeyStr = await AesManager().decrypt(shaConvert.toString(), encPrivateKey!);
  //     var privateKey = await RWFExportHelper.decrypt(pass, rwfStr);
  //     LOG('--> recoverUser privateKey : $privateKey');
  //     if (STR(privateKey).isNotEmpty) {
  //       var keyPair = EccKeyPair.fromJson(jsonDecode(privateKey!));
  //       LOG('--> recoverUser keyPair : ${keyPair.toJson()}');
  //       if (STR(privateKey).isNotEmpty) {
  //         loginProv.recoverUser(loginProv.userPass, privateKey: keyPair.d).then((result) {
  //           LOG('--> recoverUser cloud success : $result / ${loginProv.isLogin}');
  //           if (loginProv.isLogin) {
  //             _moveToMainProfile();
  //           }
  //         });
  //       }
  //     }
  //   // }
  //   //   }
  //   // }
  // }

  // 프로필 화면으로 이동..
  _moveToMainProfile() {
    hideLoadingDialog();
    final loginProv = ref.read(loginProvider);
    if (!loginProv.isLogin) {
      // showToast(TR('로그인 실패'));
      return;
    }
    // showToast(TR('로그인 성공'));
    ref.read(loginProvider).mainPageIndexOrg = 0;
    context.pushReplacementNamed(
        MainScreen.routeName, queryParams: {'selectedPage': '1'});
  }

  Uint8List _btcAddress(Uint8List compressed) {
    final sha256 = SHA256Digest();
    final ripemd160 = RIPEMD160Digest();
    final hash = sha256.process(compressed);
    final addr = ripemd160.process(hash);
    return Uint8List.fromList(addr);
  }

  _buildMenuButton(String title, Function() onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: PrimaryButton(
        onTap: onTap,
        text: TR(title),
      ),
    );
  }
}
