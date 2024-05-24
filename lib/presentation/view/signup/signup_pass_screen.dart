import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/rwfExportHelper.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/asset/networkScreens/network_input_screen.dart';
import '../../../../presentation/view/registMnemonic_screen.dart';
import '../../../../services/google_service.dart';
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

class RecoverPassScreen extends ConsumerStatefulWidget {
  RecoverPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'recoverPassScreen';

  @override
  ConsumerState createState() => _SignUpPassScreenState(
    PassViewModel(PassType.recover),
  );
}

class CloudPassCreateScreen extends ConsumerStatefulWidget {
  CloudPassCreateScreen({Key? key}) : super(key: key);
  static String get routeName => 'cloudPassCreateScreen';

  @override
  ConsumerState createState() => _SignUpPassScreenState(
    PassViewModel(PassType.cloudUp),
  );
}

class _SignUpPassScreenState extends ConsumerState {
  _SignUpPassScreenState(this.viewModel);

  PassViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.init(ref);
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
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
        bottomNavigationBar: viewModel.comparePass
            ? PrimaryButton(
          text: TR(context, '다음'),
          round: 0,
          onTap: () async {
            LOG('---> CloudPassCreateScreen ok : ${viewModel.password} / ${viewModel.comparePass} / ${viewModel.passType}');
            if (!viewModel.checkPassMinLength) {
              showToast(TR(context, '$PASS_LENGTH_MIN 자 이상 입력해주세요.'));
              return;
            }
            if (!viewModel.checkPassMaxLength) {
              showToast(TR(context, '$PASS_LENGTH_MAX 자 이하 입력해주세요.'));
              return;
            }
            if (viewModel.comparePass) {
              if (viewModel.passType == PassType.signUp) {
                Navigator.of(context).push(createAniRoute(SignUpTermsScreen()));
              } else {
                var result = viewModel.passInputController.first.text;
                context.pop(result);
              }
            }
          },
        ) : DisabledButton(
          text: TR(context, '다음'),
        ),
      )
    );
  }

  _buildInputBox(int index) {
    final prov = ref.read(loginProvider);
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
        if (viewModel.passType == PassType.recover) {
          prov.cloudPass[index] = viewModel.passInputController[index].text;
        } else {
          prov.inputPass[index] = viewModel.passInputController[index].text;
        }
        prov.refresh();
      },
    ));
  }
}
