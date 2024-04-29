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
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:larba_00/services/larba_api_service.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/pointycastle.dart' as po;
import 'package:provider/provider.dart';
import 'package:secp256k1cipher/secp256k1cipher.dart';
import 'package:web3dart/credentials.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/eccManager.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/walletHelper.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/rlp/hash.dart';
import '../recover_wallet_input_screen.dart';

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
                  _buildMenuButton('복구단어로 복구', () async {
                    Navigator.of(context).push(createAniRoute(RecoverWalletInputScreen())).then((mnemonic) {
                      LOG('--> RecoverWalletInputScreen result : $mnemonic');
                      if (STR(mnemonic).isNotEmpty) {
                        loginProv.recoverUser(mnemonic).then((result) {
                          if (loginProv.isLogin) {
                            // TODO: check email and address compare from server..
                            context.pop(true);
                          }
                        });
                      }
                    });
                  }),
                  _buildMenuButton('클라우드로 복구', () async {
                    var privKey  = await getPrivateKey(loginProv.userPass);
                    var pubKey   = await getPublicKey(privKey);
                    var shareKey = formatBytesAsHexString(pubKey.Q!.getEncoded());
                    LOG('----> keyPair [${loginProv.userPass}]: $shareKey');
                    var secretKey = await LarbaApiService().getSecretKey('jubal2000', shareKey);
                    if (secretKey != null) {
                      var curve  = getS256();
                      var pKey = PublicKey.fromHex(curve, secretKey);
                      LOG('---> pubKey : $pKey');
                      var signKey = computeSecretHex(PrivateKey.fromHex(curve, privKey), pKey);
                      LOG('---> signKey : $signKey');
                      var message = 'jubal2000@hanmail.netjubal2000$signKey';
                      var sign = await loginProv.createSign(loginProv.userPass, message);
                      LOG('---> sign : $sign');
                      var error = await LarbaApiService().loginUser('jubal2000', 'email', 'jubal2000@hanmail.net', sign);
                      LOG('---> error : $error');
                    }
                    // var ec   = getS256();
                    // var priv = ec.generatePrivateKey();
                    // var pub  = priv.publicKey;
                    // // LOG('----> privateKey: 0x$priv');
                    // // LOG('----> publicKey: 0x$pub');
                    // LOG('--> pub : ${pub.toCompressedHex()}');
                    // var secretKey = await LarbaApiService().getSecretKey('jubal2000', pub.toCompressedHex());
                    // if (secretKey != null) {
                    //   LOG('---> secretKey : $secretKey');
                    //   var pubKey = PublicKey.fromHex(ec, secretKey);
                    //   LOG('---> pubKey : $pubKey');
                    //   var signKey = computeSecretHex(priv, pubKey);
                    //   LOG('---> signKey : $signKey');
                    //   var sign = await EccManager().signingEx(signKey, 'jubal2000@hanmail.netjubal2000$signKey');
                    //   LOG('---> sign : $sign');
                    //   var error = await LarbaApiService().loginUser('jubal2000', 'email', 'jubal2000@hanmail.net', sign);
                    //   LOG('---> error : $error');
                    // }
                  }),
                ],
              )
            ),
          ],
        )
      ),
    );
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
