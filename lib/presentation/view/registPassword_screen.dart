import 'dart:convert';

import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/widget/wrong_password_dialog.dart';
import 'package:larba_00/presentation/view/registMnemonic_screen.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/PageNumbers.dart';
import 'package:larba_00/common/const/widget/PinBox.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/const/widget/num_pad.dart';
import 'package:larba_00/common/provider/storage_data_provider.dart';
import 'package:larba_00/data/repository/ecc_repository_impl.dart';
import 'package:larba_00/domain/repository/ecc_repository.dart';
import 'package:larba_00/domain/usecase/ecc_usecase.dart';
import 'package:larba_00/domain/usecase/ecc_usecase_impl.dart';
import 'package:larba_00/presentation/view/registComplete_screen.dart';
import 'package:crypto/crypto.dart';

import '../../common/const/constants.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/localStorageHelper.dart';
import '../../common/const/widget/back_button.dart';

class RegistPasswordScreen extends ConsumerStatefulWidget {
  const RegistPasswordScreen({
    super.key,
    this.reset = 'false',
    this.prevPassword = '',
  });

  static String get routeName => 'registPassword';
  final String? reset;
  final String? prevPassword;
  @override
  ConsumerState<RegistPasswordScreen> createState() =>
      _RegistPasswordScreenState();
}

class _RegistPasswordScreenState extends ConsumerState<RegistPasswordScreen> {
  List<int> pin = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  String inputPin = '';
  String checkPin = '';
  bool isChecked = false;
  bool isReset = false;
  @override
  void initState() {
    pin.shuffle();
    super.initState();

    //TODO: reset 이 true이면
    if (widget.reset == 'true') {
      isReset = true;
    }
  }

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

    print('inputPin $inputPin');
    print('checkPin $checkPin');

    if (inputPin.length == checkPin.length) {
      if (inputPin == checkPin) {
        //핀번호 일치 다음화면으로 이동
        if (isReset) {
          //TODO: 비밀번호 변경 프로세스
          var utf8List = utf8.encode(inputPin);
          var shaConvert = sha256.convert(utf8List);
          if (shaConvert.toString() == widget.prevPassword) {
            inputPin = '';
            checkPin = '';
            isChecked = false;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleCheckDialog(
                    infoString: TR(context, '이전 비밀번호와 동일한\n비밀번호를 등록할 수 없습니다.'),
                    defaultButtonText: TR(context, '돌아가기'));
              },
            );
          } else {
            String keyStr = await UserHelper().get_key();

            UserHelper().get_key().then((value) {
              keyStr = value;
            });

            AesManager aesManager = AesManager();

            String decKeyJson =
                await aesManager.decrypt(widget.prevPassword!, keyStr);
            aesManager = AesManager();
            String encResult =
                await aesManager.encrypt(shaConvert.toString(), decKeyJson);

            decKeyJson = '';
            UserHelper().setUser(key: encResult);

            aesManager = AesManager();
            String trash = await UserHelper().get_trash();
            String trashResult =
                await aesManager.decrypt(widget.prevPassword!, trash);
            String encTrashResult =
                await aesManager.encrypt(shaConvert.toString(), trashResult);
            print('trashResult : $trashResult');
            UserHelper().setUser(trash: encTrashResult);
            print('안같음');
            context.pushReplacementNamed(RegistCompleteScreen.routeName,
                queryParams: {'reset': 'true'});
          }
        } else {
          //TODO: 회원가입 프로세스

          final EccRepository _eccrepository = EccRepositoryImpl();
          final EccUseCase _eccusecase = EccUseCaseImpl(_eccrepository);

          var utf8List = utf8.encode(inputPin);
          var shaConvert = sha256.convert(utf8List);

          var generateKeyResult =
              await _eccusecase.generateKeyPair(shaConvert.toString());
          print('--> generateKeyResult : $generateKeyResult');

          // set mnemonic check flag..
          LocalStorageManager.saveData(MNEMONIC_CHECK, '1');
          context.pushReplacementNamed(RegistMnemonicScreen.routeName);
          // context.pushReplacementNamed(RegisterScreen.routeName);
        }

//지금 키체인에 저장되어있는 값
//퍼블릭키, UID, 그럼 여기서 이제 fcmToken 만 가져오면 된다.
        //입력받은 핀을 스크립트 키를 만드는 재료로 사용하여 퍼블릭, 프라이빗키를 암호화해서 저장하는 과정을 여기서 진행한다.

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responseProvider = ref.watch(registControllerProvider);

    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
            onPressed: context.pop
        ),
        centerTitle: true,
        title: Text(
          TR(context, isReset ? '비밀번호 변경' : '지갑 만들기'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          if (responseProvider.registStatus == RegistStatus.submitting) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    isReset ? SizedBox() : PageNumbers(select: 1),
                    isReset ? SizedBox() : SizedBox(height: 16.h),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TR(context, isChecked
                              ? '비밀번호를 한번 더\n등록해주세요'
                              : '비밀번호를 등록해주세요'),
                            style: isChecked ? typo24bold150 : typo24bold,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            TR(context, isChecked
                              ? '비밀번호 확인을 위해 필요합니다.'
                              : 'BYFFIN 지갑 사용을 위한 비밀번호\n숫자 6자리를 등록합니다.'),
                            style: typo16medium150.copyWith(color: GRAY_70),
                          ),
                          // SizedBox(height: 56.h),
                        ]),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 30.h),
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
                        ]
                      ),
                    )
                  ],
                ),
              ),
          );
        }),
      ),
    );
  }
}
