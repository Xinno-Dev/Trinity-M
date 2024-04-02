import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:larba_00/common/common_package.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final double buttonSizeW;
  final double buttonSizeH;
  final Color buttonColor;
  final Color iconColor;
  final Function delete;
  final Function refresh;
  final Function(String)? onChanged;
  final List<int> initialPin;
  final bool hasAuth;
  final bool isEnable;

  const NumPad({
    Key? key,
    this.buttonSizeW = 112,
    this.buttonSizeH = 72,
    this.buttonColor = WHITE,
    this.iconColor = Colors.amber,
    this.hasAuth = false,
    required this.delete,
    required this.refresh,
    this.onChanged,
    this.isEnable = true,
    required this.initialPin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.w, right: 15.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // implement the number keys (from 0 to 9) with the NumberButton widget
            // the NumberButton widget is defined in the bottom of this file
            children: [
              NumberButton(
                number: initialPin[0],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[1],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[2],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: initialPin[3],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[4],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[5],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: initialPin[6],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[7],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              NumberButton(
                number: initialPin[8],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // this button is used to delete the last number
              IconButton(
                onPressed: () {
                  if (isEnable) {
                    refresh();
                  }
                },
                // icon: hasAuth
                //     ? SvgPicture.asset(
                //         'assets/svg/face_id.svg',
                //         width: 80.w,
                //         height: 80.h,
                //       )
                //     : Icon(
                //         Icons.refresh,
                //         color: GRAY_90,
                //       ),
                icon: Icon(
                  Icons.refresh,
                  color: GRAY_90,
                ),
                iconSize: 32.h,
              ),
              NumberButton(
                number: initialPin[9],
                sizeW: buttonSizeW.w,
                sizeH: buttonSizeH.h,
                color: buttonColor,
                // controller: controller,
                isEnable: isEnable,
                onChanged: (number) {
                  onChanged?.call(number);
                },
              ),
              // this button is used to submit the entered value
              IconButton(
                onPressed: () {
                  if (isEnable) delete();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: GRAY_90,
                ),
                iconSize: 32.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double sizeW;
  final double sizeH;
  final Color color;
  final bool isEnable;
  final Function(String)? onChanged;

  const NumberButton({
    Key? key,
    required this.number,
    required this.sizeW,
    required this.sizeH,
    required this.color,
    this.onChanged,
    this.isEnable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sizeW,
      height: sizeH,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          // shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(size / 2),
          // ),
        ),
        onPressed: () {
          if (isEnable) {
            // controller.text += number.toString();
            onChanged?.call(number.toString());
          }
        },
        child: Center(
          child: Text(number.toString(), style: typo28bold),
        ),
      ),
    );
  }
}
