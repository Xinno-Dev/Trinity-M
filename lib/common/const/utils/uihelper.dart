import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../domain/model/coin_model.dart';
import '../../../domain/model/network_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../common_package.dart';
import '../../provider/login_provider.dart';
import '../../style/buttonStyle.dart';
import '../../style/colors.dart';
import '../../style/textStyle.dart';
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

Future<void> showResultDialog(
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
        contentPadding: EdgeInsets.only(top: 20.h),
        actionsPadding: EdgeInsets.fromLTRB(30.w, 10.h, 20.w, 30.h),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Container(
            width: 127.w,
            height: 40.h,
            child: OutlinedButton(
              onPressed: context.pop,
              child: Text(
                TR(context, '닫기'),
                style: typo12semibold100,
              ),
              style: darkBorderButtonStyle,
            )
            ,
          )
        ],
      ),
  );
}

showConfirmDialog(context, title, {String? cancelText, String? okText}) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) =>
      AlertDialog(
        content: Text(
          title,
          style: typo16dialog, textAlign: TextAlign.center),
        contentPadding: EdgeInsets.only(top: 40.h, bottom: 10.h),
        actionsPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          Container(
            child: Row(
              children: [
                Expanded(child:
                OutlinedButton(
                  onPressed: context.pop,
                  child: Text(
                    cancelText ?? TR(context, '취소'),
                    style: typo12semibold100,
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
                    okText ?? TR(context, '확인'),
                    style: typo12semibold100,
                  ),
                  style: primaryBorderButtonStyle,
                ))
              ],
            ),
          )
        ],
      ),
  );
}

defaultAppBar(String title) {
  return AppBar(
    title: Text(title),
    titleTextStyle: typo18bold,
    titleSpacing: 0,
    centerTitle: true,
    backgroundColor: WHITE,
    surfaceTintColor: WHITE,
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
  int maxLength = 30,
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
              backgroundColor: Colors.white,
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
                      constraints: constraints,
                      focusNode:  _focusNode,
                      controller: _textEditingController,
                      // inputFormatters: [
                      //   FilteringTextInputFormatter(RegExp('[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9| _-]'), allow: true)
                      // ],
                      maxLength: maxLength,
                      maxLines: maxLine,
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
                                cancelText ?? TR(context, '취소'),
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
                                okText ?? TR(context, '확인'),
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
  return await showLoginErrorDialog(context, LoginErrorType.none, text);
}

showLoginErrorDialog(BuildContext context, LoginErrorType type, [String? text]) async {
  var errorText1 = '';
  var errorText2 = '';
  if (type == LoginErrorType.code && STR(text).isNotEmpty) {
    var textList = getLoginErrorCodeText(text!);
    if (textList != null) {
      errorText1 = textList[0];
      errorText2 = textList[1];
    }
  }
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) =>
      AlertDialog(
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        content: Container(
          height: errorText1.isNotEmpty ? 150.h : 120.h,
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
              SizedBox(height: 5.h),
              if (type == LoginErrorType.code)...[
                Text(errorText1,
                    style: typo16bold,
                    textAlign: TextAlign.center),
                SizedBox(height: 10),
                Text(errorText2,
                    style: typo14normal.copyWith(color: SECONDARY_90),
                    textAlign: TextAlign.center),
              ],
              if (type != LoginErrorType.code)...[
                Text(type.errorText,
                  style: typo16bold,
                  textAlign: TextAlign.center),
                if (STR(text).isNotEmpty)...[
                  SizedBox(height: 10.h),
                  Text(STR(text),
                      style: typo14normal,
                      textAlign: TextAlign.center),
                ],
              ]
            ],
          ),
        ),
        contentPadding: EdgeInsets.only(top: 20.h),
        actionsPadding: EdgeInsets.fromLTRB(30.w, 10.h, 20.w, 30.h),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Container(
              width: 127.w,
              height: 40.h,
              child: OutlinedButton(
                onPressed: context.pop,
                child: Text(
                  TR(context, '닫기'),
                  style: typo12semibold100,
                ),
                style: darkBorderButtonStyle,
              )
          )
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
      return ['잘못된 서명입니다.', '복구한 계정일 경우,\n복구 파일 or 단어를 확인해 주세요.'];
    case '__invalid_token__':
      return ['잘못된 토큰입니다.', '로그아웃후 다시 로그인 해 주세요.'];
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