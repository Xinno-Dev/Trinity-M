import 'dart:convert';

import 'package:larba_00/common/const/widget/basic_appBar.dart';
import 'package:larba_00/common/const/widget/wrong_password_dialog.dart';
import 'package:larba_00/presentation/view/registLocalAuth_screen.dart';
import 'package:crypto/crypto.dart';

import '../../common/common_package.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/PinBox.dart';
import '../../common/const/widget/num_pad.dart';
import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/repository/ecc_repository.dart';
import '../../domain/usecase/ecc_usecase.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';

class RecoverWalletRegisterPassword extends StatefulWidget {
  const RecoverWalletRegisterPassword({super.key, required this.mnemonic});
  static String get routeName => 'recover_wallet_register_password';
  final String? mnemonic;

  @override
  State<RecoverWalletRegisterPassword> createState() =>
      _RecoverWalletRegisterPasswordState();
}

class _RecoverWalletRegisterPasswordState
    extends State<RecoverWalletRegisterPassword> {
  List<int> pin = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  String inputPin = '';
  String checkPin = '';
  bool isChecked = false;

  void _deletePress() {
    setState(() {
      if (isChecked) {
        if (checkPin.length > 0) {
          checkPin = checkPin.substring(0, checkPin.length - 1);
        }
      } else {
        if (inputPin.length > 0) {
          inputPin = inputPin.substring(0, inputPin.length - 1);
        }
      }
    });
  }

  void _refreshPress() {
    setState(() {
      if (isChecked) {
        checkPin = '';
      } else {
        inputPin = '';
      }
    });
  }

  void _inputPin(BuildContext context, String pinNum) async {
    setState(() {
      if (isChecked) {
        checkPin += pinNum;
      } else {
        inputPin += pinNum;
        if (inputPin.length == 6) {
          pin.shuffle();
          isChecked = true;
        }
      }
    });

    if (inputPin.length == checkPin.length) {
      if (inputPin == checkPin) {
        //핀번호 일치 다음화면으로 이동
        final EccRepository _eccrepository = EccRepositoryImpl();
        final EccUseCase _eccusecase = EccUseCaseImpl(_eccrepository);

        var utf8List = utf8.encode(inputPin);
        var shaConvert = sha256.convert(utf8List);

        var generateKeyResult = await _eccusecase
            .generateKeyPair(shaConvert.toString(), mnemonic: widget.mnemonic!);
        print('generateKeyResult : $generateKeyResult');
        if (!generateKeyResult) {
          //TODO: 핀 저장하는 부분을 분리할 필요성이 있음
          //TODO: 생체인증을 하지 않았을 경우 예외처리
          //TODO: 입력된 핀으로 암호화
          return;
        }
        context.pushNamed(
          RegistLocalAuthScreen.routeName,
          queryParams: {'previousScreen': 'recover'},
        );
        print('Pin 일치');
      } else {
        //핀번호 불일치 안내 팝업 띄운 후 초기화
        inputPin = '';
        checkPin = '';
        isChecked = false;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WrongPasswordDialog();
          },
        );
        print('Pin 불일치');
      }
    }
  }

  @override
  void initState() {
    pin.shuffle();
    super.initState();
    print(widget.mnemonic!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: BasicAppBar(title: TR(context, '지갑 복구')),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80.h),
                    Container(
                      // color: GRAY_20,
                      height: 176.h,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.r, right: 20.r),
                              child: Text(
                                isChecked
                                    ? TR(context, '비밀번호를 한번 더\n등록해주세요')
                                    : TR(context, '비밀번호를 등록해주세요'),
                                style: isChecked ? typo24bold150 : typo24bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.only(left: 20.r, right: 20.r),
                              child: Text(
                                isChecked
                                    ? TR(context, '비밀번호 확인을 위해 필요합니다.')
                                    : TR(context, 'BYFFIN 지갑 사용을 위한 비밀번호\n숫자 6자리를 등록합니다.'),
                                style: typo16medium150.copyWith(color: GRAY_70),
                              ),
                            ),
                            // SizedBox(height: 56.h),
                          ]),
                    ),
                    SizedBox(height: 8.h),
                    PinBox(
                        pinLength:
                            isChecked ? checkPin.length : inputPin.length),
                    SizedBox(height: 26.h),
                    NumPad(
                      initialPin: pin,
                      delete: _deletePress,
                      refresh: _refreshPress,
                      onChanged: ((pinNum) => _inputPin(context, pinNum)),
                    ),
                    SizedBox(height: 34.h)
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
