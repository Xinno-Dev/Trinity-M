import '../../../../common/common_package.dart';
import '../../../../common/const/widget/line_button.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/const/widget/warning_icon.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/custom_toast.dart';

class ReceiveAssetScreen extends StatefulWidget {
  const ReceiveAssetScreen({Key? key, required this.walletAddress})
      : super(key: key);
  final String walletAddress;

  @override
  State<ReceiveAssetScreen> createState() => _ReceiveAssetScreenState();
}

class _ReceiveAssetScreenState extends State<ReceiveAssetScreen> {
  late FToast fToast;
  late final String walletAddress;

  _showToast(String msg) {
    fToast.showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    walletAddress = '0x' + widget.walletAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: GRAY_10,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WarningIcon(
                height: 24.0,
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Text(TR(
                  'RIGO 네트워크 자산만 받을 수 있습니다.\n'
                  '지원하지 않는 자산을 입금한 경우, 회사의 고의나\n'
                  '과실이 있지 않는 한 회사는 책임지지 않습니다.'),
                  style: typo14medium150.copyWith(
                    color: GRAY_70,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 32.0,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 10),
          ),
          child: QrImageView(
            data: walletAddress,
            size: 200,
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    TR('지갑주소'),
                    style: typo16semibold,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: SUB_20,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Text(
                      'RIGO',
                      style: typo14bold100.copyWith(color: SUB_90),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                walletAddress,
                style: typo16regular150,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32.0,
        ),
        Row(
          children: [
            Expanded(
              child: LineButton(
                text: TR('공유'),
                onTap: () {
                  try {
                    final Size size = MediaQuery
                        .of(context)
                        .size;
                    Share.share(
                      walletAddress,
                      sharePositionOrigin: Rect.fromLTWH(
                          0, 0, size.width, size.height / 2),
                    );
                  } catch (e) {
                    _showToast(TR('공유하기 실패'));
                  }
                  //Share.share(walletAddress);
                },
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: PrimaryButton(
                text: TR('복사'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: walletAddress));
                  final androidInfo = await DeviceInfoPlugin().androidInfo;
                  if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                  _showToast(TR('복사를 완료했습니다'));
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
