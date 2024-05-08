import 'dart:convert';
import 'dart:math';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/widget/dialog_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web3dart/web3dart.dart';
import 'package:crypto/crypto.dart';

import '../../../common/const/utils/aesManager.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/rwfExportHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/custom_text_edit.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/model/ecckeypair.dart';
import 'export_rwf_screen.dart';

class ExportRWFPassScreen extends StatefulWidget {
  ExportRWFPassScreen({this.privateKey});
  String? privateKey;

  static String get routeName => 'export_rwf_pass';

  @override
  State createState() => _ScreenState();
}

class _ScreenState extends State<ExportRWFPassScreen> {
  final _passController = TextEditingController();
  final _passReController = TextEditingController();

  String inputPass = '';
  String inputPassRe = '';

  final fToast = FToast();

  _createWallet(pass) async {
    LOG('--> _createWallet : $pass / ${widget.privateKey}');
    final wallet = Wallet.createNew(
        EthPrivateKey.fromHex(widget.privateKey!), pass, Random());
    LOG('--> _createWallet result : ${wallet.toJson()}');
    return wallet.toJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GRAY_5,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '개인키 보기'), style: typo18semibold
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('암호화 비밀번호를 설정해 주세요.', style: typo14bold),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/icon_info.svg'),
                        SizedBox(width: 5),
                        Text('분실 시 비밀번호 찾기 또는 재설정이 불가능', style: typo14medium150),
                      ],
                    ),
                    Text('하므로 설정 후에 안전한 곳에 보관해주세요.', style: typo14medium150),
                    SizedBox(height: 10.h),
                    showTextEdit('비밀번호 입력',
                      controller: _passController,
                      showPassStatus: true,
                      onChanged: (value) {
                        inputPass = value;
                      }
                    ),
                    SizedBox(height: 20.h),
                    showTextEdit('비밀번호 재입력',
                      controller: _passReController,
                      showPassStatus: true,
                      onChanged: (value) {
                        inputPassRe = value;
                      }
                    ),
                  ],
                )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: PrimaryButton(
                    text: TR(context, '다음'),
                    onTap: () async {
                      if (inputPass.length >= 6 && inputPass == inputPassRe) {
                        // var rwfText = await _createWallet(inputPass);
                        // var rwfText = await UserHelper().get_rwf();
                        showLoadingDialog(context, 'RWF 변환중 입니다.', isShowIcon: false);
                        Future.delayed(Duration(milliseconds: 200)).then((_) async {
                          var walletAddress = await UserHelper().get_address();
                          var rwfText = await RWFExportHelper.encrypt(inputPass, walletAddress, widget.privateKey!);
                          LOG('---> rwfText : $rwfText');
                          // var rwfTextDec = await RWFExportHelper().decrypt(inputPass, rwfText);
                          // LOG('---> rwfTextDec : $rwfTextDec');
                          // var rwfText = '';
                          hideLoadingDialog();
                          Navigator.of(context).push(
                              createAniRoute(ExportPassScreen(rwfText))
                          ).then((result) {
                            if (BOL(result)) {
                              Navigator.of(context).pop(true);
                            }
                          });
                        });
                      } else {
                        _showToast('비밀번호를 확인해 주세요');
                      }
                    }
                  ),
                ),
              ),
            ]
          )
        )
      ),
    );
  }

  showTextEdit(
      title, {
        String? desc,
        String? error,
        TextEditingController? controller, String? hint,
        bool isEnabled = true,
        bool isShowOutline = true,
        bool isShowPass = false,
        bool showPassStatus = false,
        Function(String)? onChanged,
        Function()? onTap,
      }) {
    return CustomTextEdit(
      context,
      title,
      desc: desc,
      error: error,
      controller: controller,
      hint: hint,
      isEnabled: isEnabled,
      isShowOutline: isShowOutline,
      isShowPass: isShowPass,
      showPassStatus: showPassStatus,
      onChanged: onChanged,
      onTap: onTap,
    );
  }

  _showToast(String msg) {
    fToast.init(context);
    fToast.showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

