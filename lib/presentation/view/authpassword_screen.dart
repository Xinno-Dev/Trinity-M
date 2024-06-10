import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import '../../common/const/utils/aesManager.dart';
import '../../common/common_package.dart';
import '../../common/const/utils/userHelper.dart';
import '../../common/const/widget/PinBox.dart';
import '../../common/const/widget/num_pad.dart';
import '../../common/provider/temp_provider.dart';
import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/repository/ecc_repository.dart';
import '../../domain/usecase/ecc_usecase.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../main.dart';
import '../../presentation/view/account/export_privatekey_screen.dart';
import '../../presentation/view/account/export_rwf_pass_screen.dart';
import '../../presentation/view/registComplete_screen.dart';
import '../../presentation/view/registMnemonic_screen.dart';
import '../../presentation/view/registPassword_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:web3dart/web3dart.dart';

import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/walletHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/const/widget/wrong_password_dialog.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AuthPasswordScreen extends StatefulWidget {
  static String get routeName => 'authpassword';
  final String? auth;
  final String? reset;
  final String? mnemonic;
  final String? export_privateKey;
  final String? export_rwf;
  final String? addKeyPair;
  final String? import_privateKey;

  const AuthPasswordScreen({
    super.key,
    this.auth = 'false',
    this.reset = 'false',
    this.mnemonic = 'false',
    this.export_privateKey = 'false',
    this.export_rwf = 'false',
    this.addKeyPair = 'false',
    this.import_privateKey = 'false',
  });
  @override
  State<AuthPasswordScreen> createState() => _AuthPasswordScreenState();
}

class _AuthPasswordScreenState extends State<AuthPasswordScreen> {
  int failCount = 0;
  List<int> pin = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  String inputPin = '';

  bool hasAuth = false; //로그인
  bool hasReset = false; //패스워드 리셋
  bool hasMnemonic = false; //니모닉확인
  bool hasExport_PrivateKey = false; // 개인키 확인
  bool hasExport_Rwf = false; // 개인키 확인
  bool hasAddKeyPair = false; //계정추가
  bool hasImport_PrivateKey = false; // 개인키 불러오기
  String info = '';

  String titleString = '';
  bool hasCenter = false;

  final LocalAuthentication auth = LocalAuthentication();
  // ignore: unused_field
  _SupportState _supportState = _SupportState.unknown;
  // ignore: unused_field
  bool? _canCheckBiometrics;
  // ignore: unused_field
  List<BiometricType>? _availableBiometrics;
  // ignore: unused_field
  String _authorized = 'Not Authorized';
  // ignore: unused_field
  bool _isAuthenticating = false;
  bool useLacontext = false;
  bool isAuthEnable = true;

  @override
  void initState() {
    LOG('--> --> hasImport_PrivateKey : ${widget.import_privateKey}');
    if (STR(widget.auth) == 'true') {
      hasAuth = true;
      titleString = '본인확인';
    }
    if (STR(widget.reset) == 'true') {
      hasReset = true;
      titleString = '비밀번호 변경';
    }
    if (STR(widget.mnemonic) == 'true') {
      hasMnemonic = true;
      titleString = '지갑 복구용 문구 보기';
    }
    if (STR(widget.export_privateKey) == 'true') {
      hasExport_PrivateKey = true;
      titleString = '개인키 보기';
    }
    if (STR(widget.export_rwf) == 'true') {
      hasExport_Rwf = true;
      titleString = 'RWF 로 내보내기';
    }
    if (STR(widget.addKeyPair) == 'true') {
      hasAddKeyPair = true;
      titleString = '계정 추가하기';
    }
    if (STR(widget.import_privateKey).isNotEmpty &&
        STR(widget.import_privateKey) != 'false') {
      hasImport_PrivateKey = true;
      titleString = '계정 불러오기';
    }

    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );

    _getAvailableBiometrics();
  }

  Future<bool> _initLocalAuthInfo(context) async {
    String usingLocalAuth = await UserHelper().get_useLocalAuth();
    if (usingLocalAuth == 'true') {
      useLacontext = true;
      return await _authenticateWithBiometrics(context);
    } else {
      useLacontext = false;
    }
    return false;
  }

  void _deletePress() {
    setState(() {
      if (inputPin.length > 0) {
        inputPin = inputPin.substring(0, inputPin.length - 1);
      }
    });
  }

  void _refreshPress() {
    setState(() {
      inputPin = '';
      pin.shuffle();
    });
  }

  Future<bool> _getResult() async {
    String getData;
    if (hasExport_PrivateKey) {
      getData = await UserHelper().get_key();
    } else {
      getData = await UserHelper().get_trash();
    }

    try {
      AesManager aesManager = AesManager();
      var utf8List = utf8.encode(inputPin);
      var shaConvert = sha256.convert(utf8List);
      String dataResult =
      await aesManager.decrypt(shaConvert.toString(), getData);

      if (dataResult == 'fail') {
        dataResult = '';
        return false;
      } else {
        info = dataResult;
        dataResult = '0x00';
        return true;
      }
    } catch (e) {
      LOG('---> _getResult error : $e');
    }
    return false;
  }

  void _inputPin(BuildContext context, String pinNum) async {
    setState(() {
      inputPin += pinNum;
      if (inputPin.length == 6) {
        pin.shuffle();
      }
    });

    // LOG('---> pinNum : $inputPin / $hasAddKeyPair');

    if (inputPin.length >= 6) {
      inputPin = inputPin.substring(0, 6);
      bool result = await _getResult();

      var utf8List = utf8.encode(inputPin);
      var shaConvert = sha256.convert(utf8List);

      if (result) {
        if (hasAuth) {
          //로그인
          isGlobalLogin = true;
          context.go('/firebaseSetup');
        }
        if (hasReset) {
          //비밀번호 변경
          context.pushReplacementNamed(RegistPasswordScreen.routeName,
              queryParams: {
                'reset': 'true',
                'prevPassword': shaConvert.toString()
              });
        }
        if (hasMnemonic) {
          //니모닉 확인
          context.pushReplacementNamed(RegistMnemonicScreen.routeName,
              queryParams: {'hasCheck': 'true'});
        }
        if (hasExport_PrivateKey) {
          //PrivateKey 확인
          context.pushReplacementNamed(ExportPrivateKeyScreen.routeName,
              queryParams: {'info': info});
          // info = '0x00';
        }
        if (hasExport_Rwf) {
          final privateKey = await getPrivateKey(inputPin);
          LOG('--> hasExportRwf_PrivateKey : $privateKey');
          // final wallet = Wallet.createNew(
          //     EthPrivateKey.fromHex(privateKey), inputPin, Random());
          // LOG('--> hasExportRwf_PrivateKey json : ${wallet.toJson()}');
          context.pushNamed(ExportRWFPassScreen.routeName,
              queryParams: {'privateKey': privateKey});
        }
        if (hasAddKeyPair) {
          final EccRepository _repository = EccRepositoryImpl();
          final EccUseCase _usecase = EccUseCaseImpl(_repository);

          bool isSuccess = await _usecase.addKeyPair(shaConvert.toString());

          if (isSuccess) {
            context.pushReplacementNamed(RegistCompleteScreen.routeName,
                queryParams: {'addAccount': 'true'});
          } else {
            //패스워드 검사는 선행중이어서 else 과정 필요없을듯.
          }
        }
        if (hasImport_PrivateKey) {
          final EccRepository _repository = EccRepositoryImpl();
          final EccUseCase _usecase = EccUseCaseImpl(_repository);

          // juan : null 오류 수정
          bool isSuccess = await _usecase.addKeyPair(shaConvert.toString(),
              privateKeyHex: widget.import_privateKey);

          if (isSuccess) {
            context.pushReplacementNamed(RegistCompleteScreen.routeName,
                queryParams: {'loadAccount': 'true'});
          } else {
            //패스워드 검사는 선행중이어서 else 과정 필요없을듯.
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleCheckDialog(
                  infoString: TR('계정 불러오기에 실패했습니다.'),
                  defaultTapOption: () {
                    context.go('/firebaseSetup');
                  },
                );
              },
            );
          }
        }
        setState(() {
          inputPin = '';
        });
      } else {
        if (failCount == 2) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleCheckDialog(
                infoString: TR('본인인증에 실패하였습니다.'),
                defaultTapOption: () {
                  context.go('/firebaseSetup');
                },
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WrongPasswordDialog();
            },
          );
          setState(() {
            inputPin = '';
            failCount++;
          });
        }
      }
    }
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      print(availableBiometrics);
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<bool> _authenticateWithBiometrics(context) async {
    bool authenticated = false;
    try {
      // setState(() {
      //   _isAuthenticating = true;
      //   _authorized = 'Authenticating';
      // });

      var iosStrings = IOSAuthMessages(
          // cancelButton: '취소',
          // goToSettingsButton: '설정',
          // goToSettingsDescription: '생체인증 설정을 해주세요.',
          // lockOut: 'Please reenable your Touch ID',
          // localizedFallbackTitle: '암호입력',
          );

      var androidStrings = AndroidAuthMessages(
          // signInTitle: 'Oops! Biometric authentication required!',
          // cancelButton: 'No thanks',
          );

      authenticated = await auth.authenticate(
        localizedReason: TR('본인 확인을 위해 생체인증을 사용합니다.'),
        authMessages: <AuthMessages>[
          androidStrings,
          iosStrings,
        ],
        options: AuthenticationOptions(
          stickyAuth: true,
          // biometricOnly: true,
          useErrorDialogs: false,
        ),
      );

      // setState(() {
      //   _isAuthenticating = false;
      //   _authorized = 'Authenticating';
      // });
    } on PlatformException catch (e) {
      // setState(() {
      //   _isAuthenticating = false;
      //   _authorized = 'Error - ${e.message}';
      // });
      return false;
    }
    if (!mounted) {
      return false;
    }
    return authenticated;
  }

  @override
  Widget build(BuildContext context) {
    if (hasAuth && isAuthEnable) {
      isAuthEnable = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        var authenticated = await _initLocalAuthInfo(context);
        if (authenticated) {
          UserHelper().setUser(loginDate: DateTime.now().toString());
          isGlobalLogin = true;
          context.goNamed(FirebaseSetup.routeName);
          return;
        } else {
          print('패스워드 입력');
        }
      });
    }
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(FirebaseSetup.routeName);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          TR(titleString),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR('비밀번호를 입력해주세요'),
                        style: typo24bold150,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR('사용중인 비밀번호를 입력합니다.'),
                        style: typo16medium.copyWith(color: GRAY_70),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    PinBox(pinLength: inputPin.length),
                    Spacer(),
                    NumPad(
                      initialPin: pin,
                      delete: _deletePress,
                      refresh: useLacontext
                          ? _authenticateWithBiometrics
                          : _refreshPress,
                      hasAuth: useLacontext ? true : false,
                      onChanged: ((pinNum) => _inputPin(context, pinNum)),
                    ),
                    SizedBox(height: 40.h)
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
