import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/rwfExportHelper.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';
import 'package:larba_00/presentation/view/registMnemonic_screen.dart';
import 'package:larba_00/services/google_service.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../../common/common_package.dart';
import '../../../common/const/utils/aesManager.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/model/ecckeypair.dart';
import '../../../domain/viewModel/pass_view_model.dart';
import '../main_screen.dart';
import 'signup_terms_screen.dart';

class SignUpPassScreen extends ConsumerStatefulWidget {
  SignUpPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'signUpPassScreen';

  @override
  ConsumerState createState() => _SignUpPassScreenState(
    PassViewModel(PassType.signUp),
  );
}

class CloudPassScreen extends ConsumerStatefulWidget {
  CloudPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'cloudPassScreen';

  @override
  ConsumerState createState() => _SignUpPassScreenState(
    PassViewModel(PassType.recover),
  );
}

class _SignUpPassScreenState extends ConsumerState {
  _SignUpPassScreenState(this.viewModel);

  var inputPass = List.generate(2, (index) => '');
  PassViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.init(ref);
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
              TR(context, viewModel.title),
              style: typo18semibold,
            ),
            titleSpacing: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
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
                        TR(context, viewModel.info1),
                        style: typo24bold150,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        TR(context, viewModel.info2),
                        style: typo16medium150.copyWith(
                          color: GRAY_70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Container(
                  height: 240,
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    children: [
                      for (var index=0; index<2; index++)
                        _buildInputBox(index),
                    ],
                  )
                ),
              ],
            )
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: IS_DEV_MODE || loginProv.isPassCheckDone
                ? PrimaryButton(
              text: TR(context, '다음'),
              round: 0,
              onTap: () async {
                if (viewModel.passType == PassType.signUp) {
                  Navigator.of(context).push(createAniRoute(SignUpTermsScreen()));
                } else {
                  // var passOrg = loginProv.inputPass.first;
                  // var pin = crypto.sha256.convert(utf8.encode(passOrg)).toString();
                  // var encMnemonic = await UserHelper().get_mnemonic();
                  // var encPrivateKey = await UserHelper().get_key();
                  // var walletAddress = await UserHelper().get_address();
                  // var mnemonic  = await AesManager().decrypt(pin, encMnemonic);
                  // var keyStr = await AesManager().decrypt(pin, encPrivateKey);
                  // var privateKey = EccKeyPair.fromJson(jsonDecode(keyStr)).d;
                  // var desc = await RWFExportHelper().encrypt(pin, walletAddress, privateKey);
                  // LOG('---> mnemonic upload : $pin / $mnemonic / $desc');
                  if (Platform.isAndroid) {
                    GoogleService.uploadKeyToGoogleDrive(context).then((result) {
                      LOG('---> startGoogleDriveUpload result [Android] : $result');
                    });
                  }
                }
              },
            ) : DisabledButton(
              text: TR(context, '다음'),
            ),
          ),
        )
    );
  }

  _buildInputBox(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: TextField(
      controller: viewModel.passInputController[index],
      decoration: InputDecoration(
        hintText: TR(context, index == 0 ? '비밀번호 입력' : '비밀번호 재입력'),
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      scrollPadding: EdgeInsets.only(bottom: 200),
      onChanged: (text) {
        inputPass[index] = viewModel.passInputController[index].text;
      },
    ));
  }
}
