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
      this.minLength,
      this.scrollBottom,
      this.onTap,
      this.onChanged,
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
  final double? scrollBottom;
  final int? minLength;
  final Function()? onTap;
  final Function(String)? onChanged;

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
          maxLines: maxLines,
          keyboardType: textInputType ?? TextInputType.text,
          inputFormatters: inputFormatters,
          scrollPadding: EdgeInsets.only(bottom: scrollBottom ?? 200),
          style: isSmallScreen
              ? typo14semibold.copyWith(color: GRAY_90)
              : typo16regular.copyWith(color: GRAY_90),
          decoration: InputDecoration(
            hintText: focusNode.hasFocus ? '' : hintText,
            hintStyle: isSmallScreen
                ? typo12regular.copyWith(color: GRAY_30)
                : typo14regular.copyWith(color: GRAY_30),
            errorText: (minLength != null && controller.text.length < minLength!)
                ? '${minLength!}자 이상 입력해 주세요.'
                : null,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: isSmallScreen
                ? EdgeInsets.fromLTRB(20, 20, 20, 0)
                : null,
            // contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: ERROR_90,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
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
