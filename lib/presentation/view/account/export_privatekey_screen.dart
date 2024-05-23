import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../domain/model/address_model.dart';
import '../../../domain/model/ecckeypair.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/icon_border_button.dart';
import '../../../common/const/widget/warning_icon.dart';

class ExportPrivateKeyScreen extends StatefulWidget {
  const ExportPrivateKeyScreen({super.key, this.info});
  static String get routeName => 'export_privateKey';
  final String? info;
  @override
  State<ExportPrivateKeyScreen> createState() => _ExportPrivateKeyScreenState();
}

class _ExportPrivateKeyScreenState extends State<ExportPrivateKeyScreen> {
  late FToast fToast;
  String address = '';
  String accountName = '';
  late EccKeyPair keyPair;
  bool showPrivateKey = false;
  String buttonText = '보기';

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _getUserInfo();
    print('widget.info');
    print(widget.info);
    if (widget.info != null) {
      keyPair = EccKeyPair.fromJson(json.decode(widget.info!));
    }
  }

  @override
  void dispose() {
    // keyPair = EccKeyPair(publicKey: 'publicKey', d: 'd');
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    List<AddressModel> addressList = [];
    var userHelper = UserHelper();
    var get_address = await userHelper.get_address();
    var jsonString = await userHelper.get_addressList();
    List<dynamic> decodeJson = json.decode(jsonString);
    for (var jsonObject in decodeJson) {
      AddressModel model = AddressModel.fromJson(jsonObject);
      if (model.address == get_address) {
        accountName = model.accountName ?? '';
      }
      addressList.add(model);
    }
    setState(() {
      address = get_address;
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GRAY_5,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '개인키 보기'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 19.0),
                        decoration: BoxDecoration(
                            color: WHITE,
                            borderRadius: BorderRadius.circular(16.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WarningIcon(height: 24.0),
                              SizedBox(width: 8),
                              Text(
                                TR(context, '개인키가 타인에게 노출되지 않도록 주의하세요.\n개인키가 있으면 누구든 귀하의 자산에 접근 할 수\n있습니다.'),
                                style: typo14medium150.copyWith(color: GRAY_70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Container(
                        // height: 168,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 20.r, right: 20.r),
                        decoration: BoxDecoration(
                            color: WHITE,
                            borderRadius: BorderRadius.circular(16.r)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 16, top: 20, right: 16, bottom: 20),
                          // EdgeInsets.only(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    accountName + ' ${TR(context, '개인키')}',
                                    style:
                                        typo18semibold.copyWith(color: GRAY_90),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      showPrivateKey = !showPrivateKey;
                                      setState(() {
                                        buttonText =
                                            showPrivateKey ? '숨기기' : '보기';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 9.0, horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        color: GRAY_5,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        TR(context, buttonText),
                                        style: typo14bold100,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                showPrivateKey
                                    ? keyPair.d
                                    : '****************************************************************',
                                style: typo16regular150,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              showPrivateKey
                                  ? IconBorderButton(
                                      imageAssetName:
                                          'assets/svg/icon_copy.svg',
                                      text: TR(context, '복사하기'),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: keyPair.d));
                                        final androidInfo = await DeviceInfoPlugin().androidInfo;
                                        if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                                          _showToast(TR(context, '개인키가 복사되었습니다'));
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
