
import 'package:trinity_m_00/common/const/widget/primary_button.dart';

import '../../../common/common_package.dart';
import 'package:flutter/material.dart';

import '../../style/colors.dart';
import '../widget/image_widget.dart';
import '../widget/rounded_button.dart';
import 'convertHelper.dart';
import 'languageHelper.dart';

const APP_LOGO_XL = 'assets/images/app_icon_1024.png';
const APP_NOTICE_SIZE = 50;

Future<int> showAppUpdateDialog(
    BuildContext context, String desc, String? msg,
    {
      String? title,
      String? buildNumber,
      bool isForceUpdate = false,
      bool isForceCheck = false
    }
  ) async {
  // print('--> showAppUpdateDialog : $desc / $msg');
  msg ??= '';
  desc = desc.replaceAll('\\n' , '\n').replaceAll('<br>', '\n');
  msg = msg.replaceAll('\\n' , '\n').replaceAll('<br>', '\n');
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(TR(title ?? '앱 업데이트'), style: typo16bold),
        ),
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
        insetPadding: EdgeInsets.all(30.r),
        contentPadding: EdgeInsets.all(20.r),
        actionsPadding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 5.h),
        actionsAlignment: isForceCheck ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.r))),
        content: Container(
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(16.0)),
          ),
          constraints: BoxConstraints(
            maxWidth: 800.w,
            minHeight: 150.h,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              // Image(image: AssetImage(APP_LOGO_XL), height: 80, fit: BoxFit.fitHeight),
              Image.asset('assets/images/app_icon.png',
                height: APP_NOTICE_SIZE.r, fit: BoxFit.fitHeight),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  desc,
                  style: typo16medium,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20.h),
              if (msg!.isNotEmpty)...[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: typo16medium.copyWith(color: SECONDARY_90),
                  ),
                ),
              ],
              if (STR(buildNumber).isNotEmpty)...[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'build ${STR(buildNumber)}',
                    textAlign: TextAlign.center,
                    style: typo12normal.copyWith(color: GRAY_50),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              PrimaryButton(
                text: TR('마켓으로 이동'),
                textStyle: typo14bold,
                isBorderShow: true,
                color: WHITE,
                onTap: () {
                  Navigator.of(context).pop(1);
                },
              )
            ]
          )
        ),
        actions: <Widget>[
          if (!isForceUpdate)...[
            if (!isForceCheck)
              TextButton(
                child: Text(TR('다시 보지 않기'),
                  style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
            TextButton(
              // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
              child: Text(TR('닫기')),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
          ],
          if (isForceUpdate)
            Container(),
        ],
      );
    });
}

Future<int> showAppNoticeDialog(
    BuildContext context, String desc,
    {String? buttonText, Widget? imageWidget}) async {
  // print('--> showAppUpdateDialog : $desc / $msg');
  desc = desc.replaceAll('\\n' , '\n').replaceAll('<br>', '\n');
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(20.r),
          contentPadding: EdgeInsets.fromLTRB(
            imageWidget != null ? 0 : 20.r,
            imageWidget != null ? 0 : 20.r,
            imageWidget != null ? 0 : 20.r,
            20.r,
          ),
          actionsPadding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 10.h),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.r))),
          content: ClipRRect(
            borderRadius : BorderRadius.circular(20.r),
            child: Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                maxWidth: 800.w,
                minHeight: 150.h,
              ),
              child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Image(image: AssetImage(APP_LOGO_XL), height: 80, fit: BoxFit.fitHeight),
                    if (imageWidget != null)
                      imageWidget,
                    if (imageWidget == null)
                      SvgPicture.asset('assets/svg/icon_info.svg',
                        height: APP_NOTICE_SIZE.r, fit: BoxFit.fitHeight),
                    SizedBox(height: 30.h),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        desc,
                        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w500, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (buttonText != null)...[
                      SizedBox(height: 30.h),
                      RoundedButton.active(buttonText,
                        backgroundColor: SECONDARY_90,
                        onPressed: () {
                          Navigator.of(context).pop(1);
                        },
                      )
                    ]
                  ]
              )
            )
          ),
          actions: <Widget>[
            TextButton(
              child: Text(TR('다시 보지 않기'), style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(2);
              },
            ),
            TextButton(
              // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
              child: Text(TR('닫기')),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
          ],
        );
      });
}

Future showImageDialog(BuildContext context, String imagePath) async {
  var _menuText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  return await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      var _imageSize = MediaQuery.of(context).size.width - 60;
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: SimpleDialog(
          contentPadding: EdgeInsets.all(16),
          insetPadding: EdgeInsets.zero,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: showImage(imagePath, Size.square(_imageSize)),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Exit', style: _menuText)
            )
          ],
        ),
      );
    }
  ) ?? '';
}
