import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trinity_m_00/common/const/constants.dart';

import '../../common_package.dart';
import '../utils/convertHelper.dart';
import '../utils/languageHelper.dart';
import 'image_widget.dart';


CustomPassFormField({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    String? errorText,
    bool? autoFocus,
    TextInputAction? textInputAction,
    Function(String?)? onChanged,
    Function()? onTap,
    ValueChanged<String>? onFieldSubmitted,
  }) {
  return CustomTextFormField(
    controller: controller,
    focusNode: focusNode,
    hintText: hintText,
    errorText: errorText,
    textInputType: TextInputType.visiblePassword,
    textInputAction: textInputAction,
    obscureText: true,
    isBorderSide: false,
    isVisibleIconShow: true,
    isShowCount: false,
    scrollBottom: 100,
    autoFocus: autoFocus,
    minLength: PASS_LENGTH_MIN,
    maxLength: PASS_LENGTH_MAX,
    onChanged: onChanged,
    onTap: onTap,
    onFieldSubmitted: onFieldSubmitted,
  );
}

CustomEmailFormField({
  required TextEditingController controller,
  FocusNode? focusNode,
  String? hintText,
  bool? autoFocus,
  TextInputAction? textInputAction,
  Function(String)? onChanged,
  Function()? onTap
}) {
  return CustomTextFormField(
    controller: controller,
    focusNode: focusNode,
    hintText: hintText,
    textInputType: TextInputType.emailAddress,
    textInputAction: textInputAction,
    isBorderSide: false,
    isShowCount: false,
    scrollBottom: 100,
    autoFocus: autoFocus,
    minLength: MAIL_LENGTH_MIN,
    maxLength: MAIL_LENGTH_MAX,
    onChanged: onChanged,
    onTap: onTap,
  );
}

var _isShowOn = false;

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
    {super.key,
      this.autoFocus,
      this.maxLength,
      this.maxLines,
      this.inputFormatters,
      this.borderColor,
      this.textInputAction,
      this.textInputType,
      this.textAlign,
      this.minLength,
      this.scrollBottom,
      this.onTap,
      this.onChanged,
      this.hintText,
      this.errorText,
      this.focusNode,
      this.isSuffixShow = true,
      this.obscureText = false,
      this.isBorderSide = true,
      this.isVisibleIconShow = false,
      this.isClearIconShow = false,
      this.isShowCount = true,
      this.onFieldSubmitted,
      required this.controller});
  final bool? autoFocus;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final Color? borderColor;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final TextAlign? textAlign;
  final double? scrollBottom;
  final int? minLength;
  final bool obscureText;
  final bool isSuffixShow;
  final bool isVisibleIconShow;
  final bool isClearIconShow;
  final bool isBorderSide;
  final bool isShowCount;
  final Function()? onTap;
  final Function(String)? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  _checkError(context) {
    var text = controller.text;
    return (minLength != null && text.length < minLength!)
        ? '${minLength!}${TR('자 이상 입력해 주세요.')}'
        : (textInputType == TextInputType.emailAddress &&
          !EmailValidator.validate(text)) ?
        TR('이메일 형식을 확인해 주세요') : null;
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = INT(maxLines) <= 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          autofocus: autoFocus ?? true,
          focusNode: focusNode,
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          keyboardType: textInputType ?? TextInputType.text,
          inputFormatters: inputFormatters,
          obscureText: obscureText && !_isShowOn,
          scrollPadding: EdgeInsets.only(bottom: scrollBottom ?? 200),
          style: typo16regular.copyWith(color: GRAY_90),
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            counterText: isShowCount ? null : '',
            hintText: hintText,
            hintStyle: isSmallScreen
                ? typo12regular.copyWith(color: GRAY_30)
                : typo14regular.copyWith(color: GRAY_30),
            errorText: errorText ?? _checkError(context),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: isSmallScreen ? EdgeInsets.fromLTRB(10, 12, 10, 0)
                : null,
            // contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            border: isBorderSide ? OutlineInputBorder(
              borderSide: BorderSide(
                color: ERROR_90,
              ),
              borderRadius: BorderRadius.circular(8),
            ) : null,
            enabledBorder: isBorderSide ? OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor ?? GRAY_50,
              ),
              borderRadius: BorderRadius.circular(8),
            ) : null,
            focusedBorder: isBorderSide ? OutlineInputBorder(
              borderSide: BorderSide(
                color: SECONDARY_90,
              ),
              borderRadius: BorderRadius.circular(8),
            ) : null,
            suffixIcon: (isSuffixShow && controller.text.isNotEmpty) ? SizedBox(
              width: isVisibleIconShow ? 70 : 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isVisibleIconShow)...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isShowOn = !_isShowOn;
                        });
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: SvgPicture.asset(
                        'assets/svg/icon_visible_0${_isShowOn ? '1' : '0'}.svg',
                        height: 30,
                        width: 30,
                        colorFilter: ColorFilter.mode(GRAY_50, BlendMode.srcIn),
                      ),
                    ),
                    Spacer(),
                  ],
                  InkWell(
                    onTap: () {
                      controller.clear();
                      if (onTap != null) onTap!();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: SvgPicture.asset(
                      'assets/svg/icon_clear.svg',
                      height: 30,
                      width: 30,
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ) : null,
          ),
          cursorColor: GRAY_90,
          textInputAction: textInputAction ??
            (isSmallScreen ? TextInputAction.next : TextInputAction.newline),
          textAlign: textAlign ?? TextAlign.start,
          onTap: onTap,
          onChanged: (text) {
            setState(() {
              if (onChanged != null) onChanged!(text);
            });
          },
        );
      }
    );
  }
}


