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

  _startMain(int page) {
    LOG('---> _startMain');
    final prov = ref.read(loginProvider);
    prov.isScreenLocked = false;
    prov.mainPageIndexOrg = 1;
    context.pushReplacementNamed(
        MainScreen.routeName, queryParams: {'selectedPage': page.toString()});
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
        showBioIdentity(context, onError: (err) {
          showLoginErrorTextDialog(context, err);
        }).then((result) {
          if (BOL(result)) {
            _startMain(0);
          }
        });
      });
    }
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
              TR(context, '비밀번호 입력'),
              style: typo18semibold,
            ),
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            leading: isCanBack ? IconButton(
              onPressed: context.pop,
              icon: Icon(Icons.close),
            ) : null,
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
                ),
                SizedBox(height: 30.h),
                Container(
                  height: 240,
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    children: [
                      _buildInputBox(),
                    ],
                  )
                ),
              ],
            )
          ),
          bottomNavigationBar: IS_DEV_MODE || prov.userPassReady
              ? PrimaryButton(
            text: TR(context, '확인'),
            round: 0,
            onTap: () {
              LOG('--> viewModel.passType : [${prov.userPass}] ${viewModel.passType}');
              if (viewModel.passType == PassType.cloudDown) {
                Navigator.of(context).pop(prov.userPass);
              } else {
                prov.checkWalletPass(prov.userPass).then((result) async {
                  if (result) {
                    if (viewModel.passType == PassType.open) {
                      _startMain(0);
                    } else {
                      Navigator.of(context).pop(prov.userPass);
                    }
                  } else {
                    if (isCanBack && isFailBack) {
                      Navigator.of(context).pop();
                    }
                    Fluttertoast.showToast(
                        msg: TR(context, '잘못된 비밀번호입니다.'));
                  }
                });
              }
            },
          ) : DisabledButton(
            text: TR(context, '확인'),
          ),
        )
    );
  }

  _buildInputBox() {
    final prov = ref.read(loginProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: TextField(
        controller: passInputController,
        decoration: InputDecoration(
          hintText: TR(context, '비밀번호 입력'),
        ),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        scrollPadding: EdgeInsets.only(bottom: 200),
        onChanged: (text) {
          setState(() {
            prov.inputPass.first = passInputController.text;
          });
        },
      )
    );
  }
}
