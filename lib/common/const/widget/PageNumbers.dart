import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:larba_00/common/common_package.dart';

class PageNumbers extends StatelessWidget {
  PageNumbers({super.key, required this.select});
  final int select;
  //TODO: - 아직 핸드폰 본인인증과 신분증 인증은 추가되지 않아 3단계까지만 구현
  // final List<int> exampleList = [1, 2, 3, 4, 5];
  final List<int> exampleList = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      width: 335.w,
      margin: EdgeInsets.only(left: 20.w),
      child: Row(
        children: List.generate(
          exampleList.length,
          (index) {
            return Row(children: [
              Container(
                height: 30.h,
                width: 30.h,
                child: Center(
                  child: Text(
                    exampleList[index].toString(),
                    style: typo14semibold.copyWith(
                        fontSize : 24.r,
                        color: index == select ? SECONDARY_90 : GRAY_30),
                  ),
                ),
                decoration: BoxDecoration(
                  color: index == select ? SECONDARY_20 : GRAY_10,
                  borderRadius: BorderRadius.circular(
                    30.r,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              )
            ]);
          },
        ),
      ),
    );
  }
}
