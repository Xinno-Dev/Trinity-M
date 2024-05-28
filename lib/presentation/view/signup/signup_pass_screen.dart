import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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
        appBar: defaultAppBar(viewModel.title),
          body: LayoutBuilder(
            builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: constraints.maxHeight / 3,
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
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
                        )
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            children: [
                              for (var index = 0; index < 2; index++)
                                _buildInputBox(index),
                            ],
                          )
                        )
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: viewModel.comparePass
                      ? PrimaryButton(
                      text: TR(context, '다음'),
                      round: 0,
                      onTap: () async {
                        LOG('---> CloudPassCreateScreen ok : '
                          '${viewModel.password} / ${viewModel.comparePass} / '
                          '${viewModel.passType}');
                        if (!viewModel.checkPassMinLength) {
                          showToast(TR(context,
                            '$PASS_LENGTH_MIN 자 이상 입력해주세요.'));
                          return;
                        }
                        if (!viewModel.checkPassMaxLength) {
                          showToast(TR(context,
                            '$PASS_LENGTH_MAX 자 이하 입력해주세요.'));
                          return;
                        }
                        if (viewModel.comparePass) {
                          FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                          await Future.delayed(Duration(milliseconds: 200));
                          if (viewModel.passType == PassType.signUp) {
                            Navigator.of(context).push(
                              createAniRoute(SignUpTermsScreen()));
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
                ],
              )
            );
          }
        ),
      )
    );
  }

  _buildInputBox(int index) {
    final prov = ref.read(loginProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: TextField(
      controller: viewModel.passInputController[index],
      decoration: InputDecoration(
        hintText: TR(context, index == 0 ? '비밀번호 입력' : '비밀번호 재입력'),
      ),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: index == 0 ? TextInputAction.next : TextInputAction.done,
      obscureText: true,
      scrollPadding: EdgeInsets.only(bottom: 100),
      onChanged: (text) {
        if (viewModel.passType == PassType.cloudUp) {
          prov.cloudPass[index] = viewModel.passInputController[index].text;
        } else {
          prov.inputPass[index] = viewModel.passInputController[index].text;
        }
        prov.refresh();
      },
    ));
  }
}
