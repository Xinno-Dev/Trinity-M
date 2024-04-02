import 'package:flutter/services.dart';

import '../../common_package.dart';
import '../utils/convertHelper.dart';
import '../utils/languageHelper.dart';

CustomTextEdit(
  BuildContext context,
  title, {
    String? desc,
    String? error,
    TextEditingController? controller, String? hint,
    bool isEnabled = true,
    bool isShowOutline = true,
    bool isShowPass = false,
    bool showPassStatus = false,
    bool showPaste = false,
    int  maxLines = 1,
    EdgeInsets? contentPadding = const EdgeInsets.symmetric(horizontal: 10),
    Function(String)? onChanged,
    Function()? onTap,
  }) {
  controller ??= TextEditingController(text: desc ?? '');
  return GestureDetector(
    onTap: () {
      if (onTap != null) onTap();
    },
    child: Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(TR(context, title), style: typo14medium),
          if (isShowOutline)
            SizedBox(height: 8.h),
          StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: controller,
                style: isEnabled ? typo14medium : typo14disable,
                enabled: isEnabled,
                obscureText: showPassStatus && !isShowPass,
                decoration: InputDecoration(
                  border: isShowOutline ? OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(width: 1, color: GRAY_90),
                  ) : InputBorder.none,
                  hintText: hint,
                  contentPadding: contentPadding,
                  suffixIcon: showPassStatus || showPaste ? InkWell(
                    onTap: () {
                      setState(() {
                        if (showPassStatus) {
                          isShowPass = !isShowPass;
                        }
                        if (showPaste) {
                          Clipboard.getData(Clipboard.kTextPlain).then((cdata) {
                            LOG('--> controller.text : $cdata');
                            if (cdata != null && STR(cdata.text).isNotEmpty) {
                              if (controller != null) controller.text = STR(cdata.text);
                            }
                          });
                        }
                      });
                    },
                    child: Icon(showPassStatus ? (isShowPass ? Icons.visibility_off : Icons.visibility) : showPaste ? Icons.paste : null),
                  ) : null,
                ),
                maxLines: maxLines,
                scrollPadding: EdgeInsets.only(bottom: 2000.h),
                onChanged: onChanged,
              );
            }
          ),
          if (error != null)...[
            SizedBox(height: 5.h),
            Text(error, style: typo12semibold100.copyWith(color: Colors.red)),
          ]
        ]
      )
    )
  );
}


