
import 'package:larba_00/common/common_package.dart';
import 'package:flutter/material.dart';

import '../widget/rounded_button.dart';
import 'languageHelper.dart';

const APP_LOGO_XL = 'assets/images/app_icon_1024.png';
const APP_NOTICE_SIZE = 50;

Future<int> showAppUpdateDialog(
    BuildContext context, String desc, String? msg,
    {bool isForceUpdate = false }) async {
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
            child: Text(TR(context, '앱 업데이트')),
          ),
          insetPadding: EdgeInsets.all(30.r),
          contentPadding: EdgeInsets.all(20.r),
          actionsPadding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 10.h),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.r))),
          content: Container(
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
                borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
              ),
              constraints: BoxConstraints(
                maxWidth: 800.w,
                minHeight: 150.h,
              ),
              child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Image(image: AssetImage(APP_LOGO_XL), height: 80, fit: BoxFit.fitHeight),
                    SvgPicture.asset('assets/svg/icon_info.svg',
                      height: APP_NOTICE_SIZE.r, fit: BoxFit.fitHeight),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        desc,
                        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w500, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    if (msg!.isNotEmpty)...[
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          msg,
                          style: TextStyle(
                              fontSize: UI_FONT_SIZE_M,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                              height: 1.5
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 30.h),
                    RoundedButton.active(TR(context, '마켓으로 이동'),
                      backgroundColor: SECONDARY_90,
                      onPressed: () {
                        Navigator.of(context).pop(1);
                      },
                    )
                  ]
              )
          ),
          actions: <Widget>[
            if (!isForceUpdate)...[
              TextButton(
                child: Text(TR(context, '다시 보지 않기'), style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
              TextButton(
                // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
                child: Text(TR(context, '닫기')),
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
              child: Text(TR(context, '다시 보지 않기'), style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(2);
              },
            ),
            TextButton(
              // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
              child: Text(TR(context, '닫기')),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
          ],
        );
      });
}