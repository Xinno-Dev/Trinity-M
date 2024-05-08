import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/dialog_utils.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:larba_00/presentation/view/signup/signup_pass_screen.dart';
import 'package:larba_00/services/api_service.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/pointycastle.dart' as po;
import 'package:provider/provider.dart';
import 'package:secp256k1cipher/secp256k1cipher.dart';
import 'package:web3dart/credentials.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../../common/common_package.dart';
import '../../../common/const/utils/aesManager.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/eccManager.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/rwfExportHelper.dart';
import '../../../common/const/utils/walletHelper.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/rlp/hash.dart';
import '../../../services/google_service.dart';
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
        appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          title: Text(
            TR(context, '지갑 복구'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
        ),
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
                    TR(context, '지갑 복구 수단을\n선택해 주세요.'),
                    style: typo24bold150,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    TR(context,
                        '서비스 이용을 위해 지갑 복구가 필요합니다.\n'
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
                  _buildMenuButton('복구단어로 복구', () {
                    Navigator.of(context).push(
                      createAniRoute(RecoverWalletInputScreen())).then((mnemonic) {
                      LOG('--> RecoverWalletInputScreen result : $mnemonic');
                      if (STR(mnemonic).isNotEmpty) {
                        showLoadingDialog(context, TR(context, '계정 복구중입니다...'));
                        loginProv.recoverUser(mnemonic: mnemonic).then((result) {
                          LOG('--> recoverUser mn result : $result');
                          _moveToMainProfile();
                        });
                      }
                    });
                  }),
                  _buildMenuButton('클라우드로 복구', () {
                    GoogleService.downloadKeyFromGoogleDrive(context).then((rwfStr) {
                      LOG('---> downloadKeyFromGoogleDrive rwfStr : $rwfStr');
                      if (STR(rwfStr).isNotEmpty) {
                        Navigator.of(context).push(
                          createAniRoute(CloudPassScreen())).then((pass) async {
                          LOG('---> CloudPassScreen pass : $pass');
                          var mnemonic = await RWFExportHelper.decrypt(pass, rwfStr);
                          loginProv.recoverUser(mnemonic: mnemonic).then((result) {
                            LOG('--> recoverUser mn result : $result');
                            _moveToMainProfile();
                          });
                          // _recoverRwfKey(pass, rwfStr);
                        });
                      }
                    });
                  }),
                ],
              )
            ),
          ],
        )
      ),
    );
  }

  _recoverRwfKey(String pass, String rwfStr) async {
    LOG('--> _recoverRwfKey : $pass / $rwfStr');
    final loginProv = ref.read(loginProvider);
    // if (STR(pass).isNotEmpty) {
    //   final shaConvert = crypto.sha256.convert(utf8.encode(pass));
    //   final keyStr = await AesManager().decrypt(shaConvert.toString(), keyData);
    //   LOG('---> privateKey create : $pass -> $keyStr');
    //   if (keyStr != 'fail') {
    //     var keyJson = jsonDecode(keyStr);
    //     var privateKey = STR(keyJson['publicKey']);
    //   var utf8List = utf8.encode(pass);
    //   var rwfPass = crypto.sha256.convert(utf8List).toString();
    //   // var privateKeyStr = await AesManager().decrypt(shaConvert.toString(), encPrivateKey!);
      var privateKey = await RWFExportHelper.decrypt(pass, rwfStr);
      LOG('--> recoverUser privateKey : $privateKey');
      if (STR(privateKey).isNotEmpty) {
        var keyPair = EccKeyPair.fromJson(jsonDecode(privateKey!));
        LOG('--> recoverUser keyPair : ${keyPair.toJson()}');
        if (STR(privateKey).isNotEmpty) {
          loginProv.recoverUser(privateKey: keyPair.d).then((result) {
            LOG('--> recoverUser cloud success : $result / ${loginProv.isLogin}');
            if (loginProv.isLogin) {
              _moveToMainProfile();
            }
          });
        }
      }
    // }
    //   }
    // }
  }

  _moveToMainProfile() {
    hideLoadingDialog();
    final loginProv = ref.read(loginProvider);
    if (!loginProv.isLogin) {
      Fluttertoast.showToast(msg: TR(context, '로그인 실패'));
      return;
    }
    Fluttertoast.showToast(msg: TR(context, '로그인 성공'));
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
        text: TR(context, title),
      ),
    );
  }
}
