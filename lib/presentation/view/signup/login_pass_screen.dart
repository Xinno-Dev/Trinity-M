import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../common/const/constants.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../domain/viewModel/profile_view_model.dart';
import '../../../../presentation/view/asset/networkScreens/network_input_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/identityHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/viewModel/pass_view_model.dart';
import '../main_screen.dart';
import 'signup_terms_screen.dart';

class LoginPassScreen extends ConsumerStatefulWidget {
  LoginPassScreen({Key? key, this.isFailBack = false}) : super(key: key);
  static String get routeName => 'loginPassScreen';
  bool isFailBack;

  @override
  ConsumerState createState() =>
    _LoginPassScreenState(PassViewModel(PassType.signIn), isFailBack);
}

class CloudPassScreen extends ConsumerStatefulWidget {
  const CloudPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'cloudPassScreen';

  @override
  ConsumerState createState() =>
      _LoginPassScreenState(PassViewModel(PassType.cloudDown), false);
}

class OpenPassScreen extends ConsumerStatefulWidget {
  const OpenPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'openPassScreen';

  @override
  ConsumerState createState() =>
      _LoginPassScreenState(PassViewModel(PassType.open), false);
}

class _LoginPassScreenState extends ConsumerState {
  _LoginPassScreenState(this.viewModel, this.isFailBack);
  final passInputController = TextEditingController();
  PassViewModel viewModel;
  bool isFailBack;
  var isCanBack = true;
  var isBioCheckDone = false;
  var passErrorText = '';

  _screenLockOff() {
    var prov = ref.read(loginProvider);
    prov.isScreenLocked = false;
    prov.enableLockScreen();
    prov.refresh();
  }

  _showBioCheck() {
    if (isBioCheckDone) return;
    isBioCheckDone = true;
    var prov = ref.read(loginProvider);
    prov.showBioIdentityCheck(context).then((result) {
      if (result) {
        context.pop();
        _screenLockOff();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    var prov = ref.read(loginProvider);
    prov.inputPass = List.generate(2, (index) => IS_DEV_MODE ? EX_TEST_PASS_00 : '');
    isCanBack = viewModel.passType != PassType.open;
    passInputController.text = IS_DEV_MODE ? EX_TEST_PASS_00 : '';
    LOG('--> _LoginPassScreenState : ${viewModel.passType} && ${prov.userBioYN}');
    if (viewModel.passType == PassType.open && prov.userBioYN) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          _showBioCheck();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return PopScope(
      canPop: isCanBack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: WHITE,
          appBar: defaultAppBar(TR(context, '비밀번호 입력'),
            isCanBack: isCanBack,
            leading: isCanBack ? IconButton(
              onPressed: context.pop,
              icon: Icon(Icons.close),
            ) : null,
          ),
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
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TR(context, viewModel.passType.info1),
                                style: typo24bold150,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                TR(context, viewModel.passType.info2),
                                style: typo16medium150.copyWith(
                                  color: GRAY_70,
                                ),
                              ),
                            ],
                          ),
                        )),
                        Expanded(
                          flex: constraints.maxHeight > 500 ? 2 : 1,
                          child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            children: [
                              _buildInputBox(),
                              if (viewModel.passType == PassType.open && prov.userBioYN)...[
                                SizedBox(height: 20),
                                InkWell(
                                  onTap: () {
                                    isBioCheckDone = false;
                                    _showBioCheck();
                                  },
                                  child: Icon(Icons.fingerprint, size: 50, color: SECONDARY_50)
                                )
                              ]
                            ],
                          )
                        )),
                      ],
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IS_DEV_MODE || _checkPassLength()
                      ? PrimaryButton(
                      text: TR(context, '확인'),
                      round: 0,
                      onTap: () async {
                        LOG('--> viewModel.passType : [${prov.userPass}] ${viewModel.passType}');
                        FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                        await Future.delayed(Duration(milliseconds: 200));
                        if (viewModel.passType == PassType.cloudDown) {
                          Navigator.of(context).pop(prov.cloudPass.first);
                        } else {
                          // 암호 검증..
                          prov.checkWalletPass(prov.userPass).then((result) async {
                            if (result) {
                              if (viewModel.passType == PassType.open) {
                                context.pop();
                                _screenLockOff();
                              } else {
                                Navigator.of(context).pop(prov.inputPass.first);
                              }
                            } else {
                              if (isCanBack && isFailBack) {
                                context.pop();
                              }
                              showToast(TR(context, '잘못된 비밀번호입니다.'));
                            }
                          });
                        }
                      },
                    ) : DisabledButton(
                      text: TR(context, '확인'),
                    ),
                  )
                ],
              )
            );
          }
        )
      )
      )
    );
  }

  _checkPassLength() {
    final prov = ref.read(loginProvider);
    if (viewModel.passType == PassType.cloudDown) {
      return prov.cloudPass.first.length >= PASS_LENGTH_MIN &&
             prov.cloudPass.first.length <= PASS_LENGTH_MAX;
    } else {
      return prov.inputPass.first.length >= PASS_LENGTH_MIN &&
             prov.inputPass.first.length <= PASS_LENGTH_MAX;
    }
  }

  _refreshPass(String? text) {
    final prov = ref.read(loginProvider);
    setState(() {
      if (viewModel.passType == PassType.cloudDown) {
        prov.cloudPass.first = passInputController.text;
      } else {
        prov.inputPass.first = passInputController.text;
      }
      passErrorText = '';
      if (passInputController.text.length < PASS_LENGTH_MIN) {
        passErrorText = '$PASS_LENGTH_MIN 자 이상 입력해 주세요';
      }
      if (passInputController.text.length > PASS_LENGTH_MAX) {
        passErrorText = '$PASS_LENGTH_MAX 자 이하 입력해 주세요';
      }
    });
  }

  _buildInputBox() {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          TextField(
            controller: passInputController,
            decoration: InputDecoration(
              hintText: TR(context, '비밀번호 입력'),
            ),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            scrollPadding: EdgeInsets.only(bottom: 200),
            onChanged: _refreshPass,
          ),
          if (passErrorText.isNotEmpty)...[
            SizedBox(height: 5),
            Text(TR(context, passErrorText), style: errorStyle)
          ],
        ],
      )
    );
  }
}
