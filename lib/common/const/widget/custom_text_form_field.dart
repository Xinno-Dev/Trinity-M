import 'package:flutter/services.dart';

import '../../common_package.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.maxLength,
      this.maxLines,
      this.inputFormatters,
      required this.hintText,
      required this.constraints,
      required this.focusNode,
      required this.controller});
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final BoxConstraints constraints;
  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = constraints.maxWidth < 106;
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
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
        contentPadding: EdgeInsets.only(top: 20.h),
        // contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GRAY_20,
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
      cursorHeight: isSmallScreen ? 14.r : 18.r,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
    );
  }
}
