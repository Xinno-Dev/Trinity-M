import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trinity_m_00/common/const/widget/rounded_button.dart';
import '../../../domain/model/coin_model.dart';
import '../../../domain/model/network_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../common_package.dart';
import '../../provider/login_provider.dart';
import '../../style/buttonStyle.dart';
import '../../style/colors.dart';
import '../../style/textStyle.dart';
import '../constants.dart';
import '../widget/back_button.dart';
import '../widget/custom_text_form_field.dart';
import 'convertHelper.dart';
import 'languageHelper.dart';

class UiHelper {
  Future<dynamic> buildRoundBottomSheet({
      required BuildContext context,
      required String title,
      required Widget child,
    }) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 39.0),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Wrap(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: typo18semibold,
                            ),
                            GestureDetector(
                              child: SvgPicture.asset(
                                'assets/svg/button_close.svg',
                                height: 32.0,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 39.0,
                        ),
                        child,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

Route SlidePage(Widget target) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => target,
    transitionDuration: Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end   = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route SlideInOutPage(Widget target) {
  final duration = Duration(milliseconds: 200);
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => target,
    reverseTransitionDuration: duration,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: new SlideTransition(
          position: new Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(secondaryAnimation),
          child: child,
        ),
      );
    },
  );
}

class showHorizontalDivider extends StatelessWidget {
  showHorizontalDivider(this.size,
      {Key ? key, this.color, this.thickness = 1})
      : super (key: key);

  Size size;
  Color? color;
  double? thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width,
        height: size.height,
        child: Center(
            child: Divider(
              color: color ?? Colors.grey.withOpacity(0.35),
              thickness: thickness,
              height: size.height,
            )
        )
    );
  }
}

Route createAniRoute(Widget target, {var delay = 200}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => target,
    transitionDuration: Duration(milliseconds: delay),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end   = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget getNetworkIcon(NetworkModel networkModel, {var size = 30.0}) {
  if (networkModel.isRigo) {
    return SvgPicture.asset('assets/svg/logo_rigo.svg',
        width: size, height: size);
  }
  return Image.asset('assets/images/icon_mdl.png',
      width: size, height: size);
}

Widget getCoinIcon(CoinModel? coin, {var size = 30.0}) {
  if (coin == null) {
    return Image.asset('assets/images/icon_mdl.png',
      width: size, height: size);
  }
  if (coin.symbol.toLowerCase() == 'rigo') {
    return SvgPicture.asset('assets/svg/logo_rigo.svg',
      width: size, height: size);
  }
  if (coin.logo != null && coin.logo!.isNotEmpty) {
    // print('---> logo url : ${coin.logo}');
    try {
      return CachedNetworkImage(
        imageUrl: coin.logo!,
        width: size,
        height: size,
      );
    } catch (e) {
      print('--> getCoinIcon error : $e');
    }
  }
  return Container(
    padding: EdgeInsets.only(top: 1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size),
      border: Border.all(width: 1, color: GRAY_30),
      color: SECONDARY_20
      // color: Color(0xFF7299FF),
    ),
    child: Center(child: Text(
      coin.symbol[0].toUpperCase(),
      style: TextStyle(
        fontSize: size * 0.6,
        fontWeight: FontWeight.w600,
        color: GRAY_90,
      ),
    )),
    width: size, height: size
  );
}

Widget showLoadingItem([double itemHeight = 60.0]) {
  return Container(
    height: itemHeight,
    width: double.infinity,
    child: Center(
      child: SizedBox(
        width: itemHeight * 0.6,
        height: itemHeight * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: SECONDARY_90,
        ),
      ),
    )
  );
}

Widget showLoadingFull([double size = 60.0]) {
  var width = size / 15.0;
  if (width < 1) width = 1;
  if (width > 3) width = 3;
  return Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: SECONDARY_90,
        strokeWidth: width,
      ),
    ),
  );
}

Future<void> showSimpleDialog(
    BuildContext context,
    String text,
    [String? svgIcon, var height = 120.0]) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) =>
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
          constraints: BoxConstraints(
            minWidth: 400.w,
          ),
          alignment: Alignment.center,
          height: height - (svgIcon == null ? 30 : 0),
          color: WHITE,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (svgIcon != null)
              SvgPicture.asset(
                svgIcon,
                width: 30.r, height: 30.r),
              Text(text,
                style: typo16dialog,
                textAlign: TextAlign.center)
            ],
          ),
        ),
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
        contentPadding: EdgeInsets.only(top: 20.h),
        actionsPadding: EdgeInsets.fromLTRB(30.w, 10.h, 20.w, 20.h),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Container(
            width: 127.w,
            height: 40.h,
            child: OutlinedButton(
              onPressed: context.pop,
              child: Text(
                TR('확인'),
                style: typo12semibold100,
              ),
              style: darkBorderBoldButtonStyle,
            )
            ,
          )
        ],
      ),
  );
}

showConfirmDialog(context, desc,
  {
    String? title,
    String? alertText,
    String? cancelText,
    String? okText}) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) =>
      AlertDialog(
        title: title != null ?
          Text(STR(title), style: typo16bold, textAlign: TextAlign.center) : null,
        content: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 60.w,
            maxHeight: alertText != null ? 120.h : 60.h,
          ),
          alignment: Alignment.center,
          color: WHITE,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(desc,
              style: typo16medium, textAlign: TextAlign.center),
            if (alertText != null)
              Text(STR(alertText),
                style: typo14medium.copyWith(color: THEME_ALERT_COLOR),
                  textAlign: TextAlign.center)
          ],
          )
        ),
        contentPadding: EdgeInsets.only(
            top: title != null ? 15.h : 40.h, bottom: 10.h),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
        actions: <Widget>[
          Container(
            child: Row(
              children: [
                Expanded(child:
                OutlinedButton(
                  onPressed: context.pop,
                  child: Text(
                    cancelText ?? TR('취소'),
                    style: typo14semibold,
                  ),
                  style: grayBorderButtonStyle,
                )),
                SizedBox(width: 10.w),
                Expanded(child:
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    okText ?? TR('확인'),
                    style: typo14semibold,
                  ),
                  style: darkBorderButtonStyle,
                ))
              ],
            ),
          )
        ],
      ),
  );
}

defaultAppBar(String title, {Widget? leading, var isCanBack = true}) {
  return AppBar(
    title: Text(title),
    titleTextStyle: title.length > 16 ? typo14semibold : typo18semibold,
    titleSpacing: 0,
    centerTitle: true,
    leading: leading,
    automaticallyImplyLeading: isCanBack,
    backgroundColor: WHITE,
    surfaceTintColor: WHITE,
  );
}

logoWidget({EdgeInsets? padding}) {
  return Container(
    padding: padding ?? EdgeInsets.symmetric(horizontal: 40),
    child: SvgPicture.asset(
      // 'assets/svg/logo.svg',
      'assets/svg/logo_text_00.svg',
    ),
  );
}


lockScreen(BuildContext context) {
  return Scaffold(
      backgroundColor: WHITE,
      body: Container(
        color: WHITE,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logoWidget(),
              SizedBox(height: 20),
              Text(TR('${LOCK_SCREEN_DELAY}초 후 화면이 잠김니다.'),
                style: typo18semibold.copyWith(color: GRAY_50)),
            ],
          ),
        ),
      )
  );
}

clearFocus(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

keyboardHideAppBar(BuildContext context, String title, {var isCanBack = true}) {
  return defaultAppBar(title,
    leading: CustomBackButton(
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          context.pop();
        });
      },
    )
  );
}

grayDivider() {
  return Divider(color: GRAY_10);
}

getImageHeight(String? path) async {
  if (STR(path).isNotEmpty) {
    var data = await rootBundle.load(path!);
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var fi = await codec.getNextFrame();
    return Size(fi.image.width.toDouble(), fi.image.height.toDouble());
  }
  return Size.zero;
}

Future<String?> showInputDialog(BuildContext context, String title, {
  String? defaultText,
  String? hintText,
  String? okText,
  String? cancelText,
  int maxLine = 1,
  int? minLength,
  int? maxLength,
  TextInputAction? textInputAction,
  TextInputType? textInputType,
  TextAlign? textAlign,
}) async {
  var _focusNode = FocusNode();
  var _textEditingController = TextEditingController(text: defaultText);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter stateSetter) {
          return LayoutBuilder(builder: (context, constraints) {
            return Dialog(
              backgroundColor: WHITE,
              surfaceTintColor: WHITE,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(title, style: typo14bold),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    child: CustomTextFormField(
                      hintText: hintText ?? '',
                      focusNode:  _focusNode,
                      controller: _textEditingController,
                      minLength: minLength,
                      maxLength: maxLength,
                      maxLines:  maxLine,
                      textInputAction: textInputAction,
                      textInputType: textInputType,
                      textAlign: textAlign,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: InkWell(
                            onTap: () {
                              context.pop();
                            },
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                cancelText ?? TR('취소'),
                                style: typo14normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: InkWell(
                            onTap: () async {
                              context.pop(_textEditingController.text);
                            },
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                okText ?? TR('확인'),
                                style: typo14bold,
                              )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
      });
}


showLoginErrorTextDialog(BuildContext context, String text) async {
  return await showLoginErrorDialog(context, LoginErrorType.none, text: text);
}

showLoginErrorDialog(BuildContext context, LoginErrorType type,
  {String? text, String? okText, String? cancelText}) async {
  var errorText1 = '';
  var errorText2 = '';
  if (type == LoginErrorType.code && STR(text).isNotEmpty) {
    var textList = getLoginErrorCodeText(text!);
    if (textList != null) {
      errorText1 = textList[0];
      errorText2 = textList[1];
    }
  }
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) =>
      AlertDialog(
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
          height: 150,
          constraints: BoxConstraints(
            minWidth: 400.w,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                  'assets/svg/icon_warning.svg',
                  width: 40.r, height: 40.r),
              if (type == LoginErrorType.code)...[
                SizedBox(height: 10),
                Text(errorText1,
                  style: typo16bold,
                  textAlign: TextAlign.center),
                if (STR(errorText2).isNotEmpty)...[
                  SizedBox(height: 10),
                  Text(STR(errorText2),
                    style: typo14normal.copyWith(color: SECONDARY_90),
                    textAlign: TextAlign.center),
                ]
              ],
              if (type != LoginErrorType.code)...[
                SizedBox(height: 10),
                Text(type.errorText,
                  style: typo16bold,
                  textAlign: TextAlign.center),
                if (STR(text).isNotEmpty)...[
                  if (type.errorText.isNotEmpty)
                    SizedBox(height: 10.h),
                  Text(STR(text),
                    style: type.errorText.isEmpty ? typo14bold : typo14normal,
                    textAlign: TextAlign.center),
                ],
              ]
            ],
          ),
        ),
        contentPadding: EdgeInsets.only(top: 20.h),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: <Widget>[
          if (STR(cancelText).isNotEmpty)
            Container(
              height: 40,
              width: 120,
              child: OutlinedButton(
                onPressed: context.pop,
                child: Text(
                  TR(cancelText!),
                  style: typo14normal,
                ),
                style: grayBorderButtonStyle,
              )
            ),
          Container(
            height: 40,
              width: 120,
            child: OutlinedButton(
              onPressed: () {
                context.pop(true);
              },
              child: Text(
                TR(okText ?? '닫기'),
                style: typo14bold,
              ),
              style: darkBorderButtonStyle,
            )
          ),
        ],
      ),
  );
}

showCheckBoxImg(bool isSelect) {
  return SvgPicture.asset(
    'assets/svg/check_box_0${isSelect ? '1' : '0'}.svg',
    width: 20.r, height: 20.r, fit: BoxFit.fill,
    colorFilter: !isSelect ?
    ColorFilter.mode(WHITE, BlendMode.srcIn) : null,
  );
}

getLoginErrorCodeText(String codeText) {
  switch(codeText) {
    case '__invalid_signature__':
      return ['잘못된 서명입니다.', '복구한 계정일 경우,\n복구 파일이나 단어를 확인해 주세요.'];
    case '__invalid_token__':
      return ['잘못된 토큰입니다.', '다시 로그인 해 주세요.'];
    case '__not_found__':
      return ['대상을 찾을 수 없거나,\n탈퇴 처리된 회원입니다.', '다시 로그인 해 주세요.'];
    case '__unauthorized__':
      return ['계정을 찾을 수 없습니다.', '다시 로그인 해 주세요.'];
  }
  return codeText;
}

showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.black.withOpacity(0.7),
  );
}