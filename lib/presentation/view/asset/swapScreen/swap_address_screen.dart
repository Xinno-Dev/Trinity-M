
import '../../../../domain/model/coin_model.dart';
import '../../../../domain/model/swap_model.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/disabled_button.dart';
import '../../../../common/const/widget/icon_border_button.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/network_provider.dart';
import '../../scan_qr_page.dart';
import 'swap_confirm_screen.dart';
import 'swap_utils.dart';

class SwapAddressScreen extends ConsumerStatefulWidget {
  SwapAddressScreen(this.swapModel, {Key? key}) : super(key: key);
  static String get routeName => 'SwapAddressScreen';
  SwapModel swapModel;

  @override
  ConsumerState createState() => _SwapAddressScreenState();
}

class _SwapAddressScreenState extends ConsumerState<SwapAddressScreen> {
  final _inputController = TextEditingController();

  get isEnableButton {
    return _inputController.text.isNotEmpty;
  }

  @override
  void initState() {
    _inputController.text = widget.swapModel.toAddress ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          title: Text(
            TR(context, '스왑'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
          elevation: 0,
        ),
        backgroundColor: WHITE,
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showStepNumber(1),
              _buildInputWidget(),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: isEnableButton ? PrimaryButton(
                  text: TR(context, '다음'),
                  onTap: () {
                    widget.swapModel.toAddress = _inputController.text;
                    Navigator.of(context).push(createAniRoute(SwapConfirmScreen(widget.swapModel)));
                  },
                ) : DisabledButton(text: TR(context, '다음')),
              ),
          ],
        ),
      )
    );
  }

  _buildInputWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TR(context, '받는 주소'), style: typo16medium),
          SizedBox(height: 20.h),
          Text(TR(context, '기본 입력 주소 - 내 주소로 설정'), style: typo14medium),
          Container(
            margin:  EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                TextField(
                  controller: _inputController,
                  style: typo14medium,
                  maxLines: 2,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(width: 1, color: GRAY_20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(width: 2, color: SECONDARY_50),
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {

                    });
                  },
                ),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  children: [
                    IconBorderButton(
                      imageAssetName: 'assets/svg/icon_scan.svg',
                      text: TR(context, 'QR코드 스캔'),
                      onPressed: () {
                        _pasteFromQRCode();
                      },
                    ),
                    SizedBox(
                      width: 8.h,
                    ),
                    IconBorderButton(
                      imageAssetName: 'assets/svg/icon_copy.svg',
                      text: TR(context, '붙여넣기'),
                      onPressed: _pasteFromClipboard,
                    ),
                    SizedBox(
                      width: 8.h,
                    ),
                    IconBorderButton(
                      imageAssetName: 'assets/svg/policy.svg',
                      text: TR(context, '즐겨찾기 주소'),
                      onPressed: _pasteFromClipboard,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }

  Future<void> _pasteFromQRCode() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ScanQRScreen()));
    setState(() {
      if (STR(result).isNotEmpty) {
        _inputController.text = STR(result);
      }
    });
  }

  void _pasteFromClipboard() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() {
      if (cdata?.text != null) {
        _inputController.text = STR(cdata!.text);
      }
    });
  }
}
