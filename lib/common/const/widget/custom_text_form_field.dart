import 'package:flutter/services.dart';

import '../../common_package.dart';
import '../utils/convertHelper.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
    {super.key,
      this.autoFocus,
      this.maxLength,
      this.maxLines,
      this.inputFormatters,
      this.borderColor,
      this.textInputAction,
      this.textInputType,
      this.textAlign,
      required this.hintText,
      required this.constraints,
      required this.focusNode,
      required this.controller});
  final bool? autoFocus;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final BoxConstraints constraints;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color? borderColor;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = INT(maxLines) <= 1;
    return TextFormField(
      autofocus: autoFocus ?? true,
      focusNode: focusNode,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: textInputType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      scrollPadding: EdgeInsets.only(bottom: 200.h),
      style: isSmallScreen
          ? typo14regular.copyWith(color: GRAY_90)
          : typo16regular.copyWith(color: GRAY_90),
      decoration: InputDecoration(
        hintText: focusNode.hasFocus ? '' : hintText,
        hintStyle: isSmallScreen
            ? typo12regular.copyWith(color: GRAY_30)
            : typo14regular.copyWith(color: GRAY_30),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: isSmallScreen ? EdgeInsets.fromLTRB(20, 20, 20, 0) : null,
        // contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? GRAY_50,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: SECONDARY_90,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cursorColor: GRAY_90,
      textInputAction: textInputAction ??
          (isSmallScreen ? TextInputAction.next : TextInputAction.newline),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
