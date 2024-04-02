import 'dart:convert';

import 'package:larba_00/common/common_package.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/custom_text_edit.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/primary_button.dart';

class ExportPassScreen extends StatefulWidget {
  ExportPassScreen(this.jsonText);

  static String get routeName => 'export_rwf';
  String jsonText;

  @override
  State createState() => _ScreenState();
}

class _ScreenState extends State<ExportPassScreen> {
  String showJsonText = '';
  final fToast = FToast();

  @override
  void initState() {
    super.initState();
  }

  static JsonDecoder decoder = JsonDecoder();
  static JsonEncoder encoder = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    // final input = '{"version":"1","address":"c509688ea34deee327a3bf8e47279d6f37e8b0f9","algo":"secp256k1","cp":{"ca":"aes-256-cbc","ct":"g/cqXyiDNjT3kNaB3HYLst3bjJdrneYihkFoa1qk+50OToGd6WqPEuRyOTArHm7WjivA3jvKhTzfNlHVXUz+/F+DUerKq/op44i+2Qxnl5s=","ci":"N9bXn5ObYSrSlpR4eDThCA=="},"dkp":{"ka":"pbkdf2","kh":"sha256","kc":"641430","ks":"9J7RoekN5yGHz7ZMo5ydmmIj24k=","kl":"32"}}';
    var object = decoder.convert(widget.jsonText);
    var jsonFormText = encoder.convert(object);
    // jsonFormText.split('\n').forEach((element) => print(element));

    return Scaffold(
      backgroundColor: GRAY_5,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
            TR(context, '개인키 보기'), style: typo18semibold
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TR(context, 'RWF 파일로 변환되었습니다.'), style: typo14bold),
              SizedBox(height: 10.h),
              showTextEdit(
                jsonFormText,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 120,
                  child: PrimaryButton(
                    text: TR(context, '복사하기'),
                    color: Colors.transparent,
                    textStyle: typo14medium,
                    icon: Icon(Icons.copy),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    isSmallButton: true,
                    isBorderShow: true,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: jsonFormText,
                        ),
                      );
                      final androidInfo = await DeviceInfoPlugin().androidInfo;
                      if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                      _showToast(TR(context, '개인키가 복사되었습니다'));
                    }
                  )
                ),
              ),
            ],
          ),
        )
      )
    );
  }

  showTextEdit(String desc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: TextEditingController(text: desc),
        maxLines: null,
        enabled: false,
        style: typo12regular.copyWith(height: 1.5),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
    );
  }

  _showToast(String msg) {
    fToast.init(context);
    fToast.showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

