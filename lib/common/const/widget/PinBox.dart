import 'package:larba_00/common/common_package.dart';

class PinBox extends StatelessWidget {
  PinBox({super.key, required this.pinLength});
  final int pinLength;
  static const List<int> exampleList = [1, 2, 3, 4, 5, 6];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            exampleList.length,
            (index) {
                return Row(
                  children: [
                    Container(
                      height: 40.w,
                      width: 32.w,
                      decoration: BoxDecoration(
                        color: pinLength > index ? null : GRAY_20,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: pinLength > index
                          ? Icon(
                              Icons.circle,
                              color: PRIMARY_90,
                              size: 26.w,
                            )
                          : null,
                    ),
                    SizedBox(width: index != exampleList.length - 1 ? 16.w : null)
                  ],
                );
              },
            )
          )
    );
  }
}
