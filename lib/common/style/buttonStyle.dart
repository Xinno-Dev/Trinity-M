import 'package:flutter/material.dart';
import '../../../../common/style/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

var primaryButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => PRIMARY_90,
  ),
  overlayColor: MaterialStateProperty.all(Colors.transparent),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
  ),
);

var whiteButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => WHITE,
  ),
  overlayColor: MaterialStateProperty.all(WHITE),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: PRIMARY_90, width: 1)),
  ),
);
var disableButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => GRAY_10,
  ),
  overlayColor: MaterialStateProperty.all(GRAY_10),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: GRAY_10, width: 1)),
  ),
);

var grayButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => GRAY_20,
  ),
  overlayColor: MaterialStateProperty.all(GRAY_20),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: GRAY_20, width: 1)),
  ),
);

var mainButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => WHITE,
  ),
  overlayColor: MaterialStateProperty.all(WHITE),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
      side: BorderSide(color: WHITE, width: 1),
    ),
  ),
);

var mainsubButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) => PRIMARY_90,
  ),
  overlayColor: MaterialStateProperty.all(PRIMARY_90),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: BorderSide(color: PRIMARY_90, width: 1),
    ),
  ),
);

var popupGrayButtonStyle = ElevatedButton.styleFrom(backgroundColor: GRAY_5);

var popupSecondaryButtonStyle =
    ElevatedButton.styleFrom(backgroundColor: SECONDARY_90);

var grayBorderButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: GRAY_20, width: 1),
);

var grayBorderBoldButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: GRAY_20, width: 2),
);

var darkBorderButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: GRAY_70, width: 1),
);

var darkBorderBoldButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: GRAY_70, width: 2),
);

var primaryBorderButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: PRIMARY_50,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: PRIMARY_90, width: 1),
);

var whiteImageButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.r),
  ),
  side: BorderSide(color: GRAY_20, width: 1),
);

var whiteImageButtonDisableStyle = OutlinedButton.styleFrom(
  backgroundColor: GRAY_5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.r),
  ),
  side: BorderSide(color: GRAY_30, width: 1),
);

var primaryImageButtonStyle = TextButton.styleFrom(
  backgroundColor: Color.fromRGBO(254, 243, 245, 1),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);

var primary10ButtonStyle = TextButton.styleFrom(
  backgroundColor: PRIMARY_10,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);
