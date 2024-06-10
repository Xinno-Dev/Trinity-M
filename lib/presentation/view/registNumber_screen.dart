import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/PageNumbers.dart';
import '../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../data/repository/storage_repository_impl.dart';
import '../../../domain/repository/storage_repository.dart';
import '../../../domain/usecase/storage_usecase.dart';
import '../../../domain/usecase/storage_usecase_impl.dart';
import '../../../presentation/view/registPassword_screen.dart';
import '../../../services/storage_api_services.dart';
import 'package:email_validator/email_validator.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';

class RegistNumberScreen extends ConsumerStatefulWidget {
  const RegistNumberScreen({super.key});
  static String get routeName => 'registNumber';

  @override
  ConsumerState<RegistNumberScreen> createState() => _RegistNumberScreenState();
}

class _RegistNumberScreenState extends ConsumerState<RegistNumberScreen> {
  final TextEditingController _numberController = TextEditingController();
  FocusNode textFocus = FocusNode();
  String _userEmail = '';
  bool _ready = false;

  void _nextPress() async {
    textFocus.unfocus();

    final StorageRepository _repository =
        StorageRepositoryImpl(StorageAPIServices());

    final StorageUseCase _usecase = StorageUseCaseImpl(_repository);

    var utf8List = utf8.encode(_userEmail);
    var shaConvert = sha256.convert(utf8List);

    UserHelper().setUser(uid: shaConvert.toString());
    print(shaConvert.toString());
    await _usecase.read(shaConvert.toString()).then((value) {
      if (value.code == 2000) {
        setState(() {
          _numberController.text = '';
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleCheckDialog(
              hasTitle: true,
              titleString: TR('이미 등록되어 있는 이메일 입니다'),
              infoString: TR('사용가능한 이메일을 입력해 주세요.'),
              defaultButtonText: TR('돌아가기'),
            );
          },
        );
      } else {
        print('존재하지않음');
        _ready = true;
        print('_ready : $_ready');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleCheckDialog(
              infoString: TR('사용 가능한 이메일 입니다'),
              defaultButtonText: TR('돌아가기'),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        textFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(
            TR('회원가입'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 80.h),
                      PageNumbers(select: 1),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                        child: Text(
                          TR('이메일을 입력해 주세요'),
                          style: typo24bold150,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                        child: Text(
                          TR('BYFFIN 지갑을 이용하기 위해 필요합니다'),
                          style: typo16medium150,
                        ),
                      ),

                      // Spacer(),
                      SizedBox(height: 112.h),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                        child: Text(
                          TR('이메일'),
                          style: typo14semibold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 48.h,
                        width: 335.w,
                        margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                        child: TextField(
                          scrollPadding: EdgeInsets.only(bottom: 500),
                          controller: _numberController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: GRAY_90),
                          focusNode: textFocus,
                          cursorColor: PRIMARY_90,
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            helperStyle: typo16regular.copyWith(
                              color: GRAY_40,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: GRAY_20, width: 1.0)),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: GRAY_20),
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              _ready = false;
                              _userEmail = text;
                            });
                          },
                        ),
                      ),
                      Spacer(),
                      SizedBox(height: 162.h),
                      Container(
                        width: 335.w,
                        height: 56,
                        margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                        child: ElevatedButton(
                          onPressed: _ready
                              ? () {
                                  //사용자 이메일 추가 2023.04.06 - Liam
                                  print(_userEmail);
                                  UserHelper().setUser(userID: _userEmail);
                                  context.pushNamed(
                                      RegistPasswordScreen.routeName);
                                }
                              : EmailValidator.validate(_userEmail)
                                  ? _nextPress
                                  : null,
                          child: Text(
                            TR('다음'),
                            style: typo16bold.copyWith(
                              color: EmailValidator.validate(_userEmail)
                                  ? WHITE
                                  : GRAY_40,
                            ),
                          ),
                          style: EmailValidator.validate(_userEmail)
                              ? primaryButtonStyle
                              : disableButtonStyle,
                        ),
                      ),
                      SizedBox(
                        height: 40.h,
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
