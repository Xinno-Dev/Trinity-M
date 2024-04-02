
import '../../../../common/common_package.dart';

showStepNumber(int selectIndex) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(3,
         (index) => _buildStepItem(index, selectIndex == index)),
    ),
  );
}

_buildStepItem(int index, bool isSelect) {
  final size = 24.r;
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    padding: EdgeInsets.only(bottom: 3.5.h),
    margin: EdgeInsets.only(right: 5.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size),
      color: isSelect ? SECONDARY_50 : GRAY_10,
    ),
    child: Text('${index + 1}', style: typo14bold.copyWith(
        color: isSelect ? Colors.white : GRAY_30)),
  );
}
