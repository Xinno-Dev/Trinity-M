import '../../../common/common_package.dart';
import '../utils/languageHelper.dart';

class SimpleCheckDialog extends StatelessWidget {
  SimpleCheckDialog(
      {Key? key,
      required this.infoString,
      this.titleString = 'Title',
      this.hasOptions = false,
      this.hasTitle = false,
      this.hasIcon = false,
      this.defaultButtonText = '확인',
      this.optionButtonText = '옵션 텍스트',
      this.defaultTapOption = null,
      this.onTapOption = null,
      this.icon = null})
      : super(key: key);
  final String infoString, titleString;
  final String defaultButtonText, optionButtonText;
  final bool hasOptions, hasTitle, hasIcon;
  final Widget? icon;
  final Function()? defaultTapOption;
  final Function()? onTapOption;

  closePopup() {}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            hasIcon
                ? Padding(padding: EdgeInsets.only(top: 32.h), child: icon!)
                : SizedBox(),
            hasTitle
                ? Container(
                    padding: EdgeInsets.fromLTRB(
                        16.r, hasIcon ? 16.r : 32.r, 16.r, 0),
                    // margin: EdgeInsets.all(0),
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          titleString,
                          style: typo16semibold150,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            Container(
              padding:
                  EdgeInsets.fromLTRB(16.r, hasTitle ? 20.r : 32.r, 16.r, 32.r),
              // margin: EdgeInsets.all(0),
              child: Center(
                child: Text(
                  infoString,
                  style: typo14medium150.copyWith(color: GRAY_70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: defaultTapOption == null
                          ? () {
                              context.pop();
                            }
                          : defaultTapOption,
                      // onPressed: () => dismiss,
                      child: Text(
                        TR(context, defaultButtonText),
                        style: typo14bold100.copyWith(color: SECONDARY_90),
                      ),
                      style: popupGrayButtonStyle.copyWith(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            // side: BorderSide(),
                            borderRadius: BorderRadius.only(
                              bottomRight: hasOptions
                                  ? Radius.zero
                                  : Radius.circular(8.r),
                              bottomLeft: Radius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasOptions)
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: onTapOption,
                        // onPressed: () => dismiss,
                        child: Text(
                          TR(context, optionButtonText),
                          style: typo14bold100.copyWith(color: WHITE),
                        ),
                        style: popupSecondaryButtonStyle.copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => SECONDARY_90,
                          ),
                          overlayColor: MaterialStateProperty.all(SECONDARY_90),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              // side: BorderSide(),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8.r),
                                bottomLeft: hasOptions
                                    ? Radius.zero
                                    : Radius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
