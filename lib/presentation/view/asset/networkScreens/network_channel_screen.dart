
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/custom_toast.dart';

class NetworkChannelScreen extends StatefulWidget {
  NetworkChannelScreen(this.channelList, this.selected, {Key? key}) : super(key: key);
  static String get routeName => 'NetworkChannelScreen';
  List channelList;
  String selected;

  @override
  State<NetworkChannelScreen> createState() => _NetworkChannelScreenState();
}

class _NetworkChannelScreenState extends State<NetworkChannelScreen> {
  final fToast = FToast();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          leadingWidth: 40.w,
          titleSpacing: 0,
          centerTitle: true,
          title: Text(TR('네트워크 채널 선택'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            children: [
              Text(TR('채널을 선택해 주세요.'),
                style: typo16medium,
              ),
              SizedBox(height: 10.h),
              ...widget.channelList.map((e) => _buildChannelItem(e['channel'],
                widget.selected == e['channel'], (status) {
                  if (status) {
                    setState(() {
                      widget.selected = e['channel'];
                      Future.delayed(Duration(milliseconds: 200)).then((_) {
                        context.pop(e);
                      });
                    });
                  }
                }
              )).toList()
            ],
          )
        )
      )
    );
  }

  _buildChannelItem(String title, bool selected, Function(bool)? onChanged) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) onChanged(!selected);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: selected ? 2 : 1, color: selected ? PRIMARY_90 : GRAY_30),
        ),
        child: Row(
          children: [
            // Checkbox(value: selected, onChanged: onChanged),
            SvgPicture.asset('assets/svg/${selected ? 'address_check2' : 'address_uncheck'}.svg'),
            SizedBox(width: 15.w),
            Text(title,
              style: typo18semibold.copyWith(color: selected ? GRAY_80 : GRAY_30)),
          ],
        ),
      ),
    );
  }

  _showToast(String msg) {
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      fToast.init(context);
      fToast.showToast(
        child: CustomToast(
          msg: msg,
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
    });
  }
}
