import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/settingsMenu.dart';
import 'package:larba_00/domain/model/address_model.dart';
import 'package:larba_00/common/dartapi/lib/trx_pb.pb.dart';
import 'package:larba_00/presentation/view/authpassword_screen.dart';
import 'package:larba_00/services/json_rpc_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:crypto/crypto.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/walletHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/custom_badge.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

import 'package:pointycastle/export.dart' as export1;

import '../../../common/const/widget/custom_text_form_field.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/const/widget/warning_icon.dart';
import '../user_edit_screen.dart';
import 'export_rwf_pass_screen.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});
  static String get routeName => 'userinfo';

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final fToast = FToast();
  String address = '';
  String accountName = '';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    TrxProto();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    UserHelper userHelper = UserHelper();
    String get_address = await userHelper.get_address();
    List<AddressModel> addressList = [];

    String jsonString = await userHelper.get_addressList();
    List<dynamic> decodeJson = json.decode(jsonString);
    for (var jsonObject in decodeJson) {
      // print('--> account list : ${jsonObject.toString()}');
      AddressModel model = AddressModel.fromJson(jsonObject);
      if (model.address == get_address) {
        accountName = model.accountName ?? '';
        break;
      }
      addressList.add(model);
    }
    setState(() {
      address = get_address;
    });
  }

  Future<void> _setUserInfo(newName) async {
    UserHelper userHelper = UserHelper();
    String jsonString = await userHelper.get_addressList();
    List<dynamic> decodeJson = json.decode(jsonString);
    for (var jsonObject in decodeJson) {
      AddressModel model = AddressModel.fromJson(jsonObject);
      if (model.address == address) {
        jsonObject['accountName'] = newName;
        accountName = newName;
        break;
      }
    }
    setState(() {
      final addressJsonString = json.encode(decodeJson);
      print('--> account update : ${decodeJson.length}');
      userHelper.setUser(addressList: addressJsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '계정 정보'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spacer(),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(createAniRoute(
                            UserEditScreen(address, accountName))).then((newName) {
                            if (STR(newName).isNotEmpty) {
                              setState(() {
                                _setUserInfo(newName);
                              });
                            }
                          });
                          // var orgName = accountName;
                          // _showInputDialog(accountName).then((newName) {
                          //   if (STR(newName).isNotEmpty && orgName != newName) {
                              // _setUserInfo(newName);
                            // }
                          // });
                      },
                      child: Row(
                        children: [
                          Text(
                            accountName,
                            style: typo18semibold.copyWith(color: GRAY_90),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.edit, size: 18.r, color: GRAY_50)
                        ],
                      )
                    ),
                    // UserInfoItem(title: '이름', itemString: userName),
                    // UserInfoItem(title: '이메일', itemString: userID),
                    // UserInfoItem(title: '가입일', itemString: registDate),
                    SizedBox(
                      height: 30.h,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF2F9),
                        borderRadius: BorderRadius.circular(16.r)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  TR(context, '지갑주소'),
                                  style:
                                      typo16semibold.copyWith(color: GRAY_70),
                                ),
                                SizedBox(width: 8),
                                CustomBadge(
                                  text: 'RIGO',
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              '0x' + address,
                              style: typo16regular150.copyWith(
                                  decoration: TextDecoration.underline),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: 150,
                          child: PrimaryButton(
                            text: TR(context, '주소 복사'),
                            color: Colors.transparent,
                            textStyle: typo14medium,
                            icon: Icon(Icons.copy),
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            isSmallButton: true,
                            isBorderShow: true,
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: '0x' + address,
                                ),
                              );
                              final androidInfo = await DeviceInfoPlugin().androidInfo;
                              if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                              _showToast(TR(context, '지갑주소가 복사되었습니다'));
                            }
                          )
                        ),
                      ),
                      SizedBox(
                        height: 64.h,
                      ),
                      PrimaryButton(
                        text: TR(context, '개인키 보기'),
                        color: Colors.transparent,
                        textStyle: typo16medium,
                        isSmallButton: true,
                        isBorderShow: true,
                        onTap: () async {
                          context.pushNamed(AuthPasswordScreen.routeName,
                            queryParams: {'export_privateKey': 'true'});
                        }
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      PrimaryButton(
                        text: TR(context, 'RWF 로 내보내기'),
                        afterIcon: Icon(Icons.exit_to_app_rounded),
                        color: Colors.transparent,
                        textStyle: typo16medium,
                        isSmallButton: true,
                        isBorderShow: true,
                        onTap: () async {
                          context.pushNamed(AuthPasswordScreen.routeName,
                            queryParams: {'export_rwf': 'true'});
                        }
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      InkWell(
                        onTap: () {

                        },
                        child: Row(
                          children: [
                            Text('RWF', style: typo16medium),
                            SizedBox(width: 5.w),
                            SvgPicture.asset('assets/svg/icon_question.svg'),
                          ],
                        )
                      )
                      // SettingsMenu(
                      //   leftImage: false,
                      //   title: TR(context, '개인키 보기'),
                      //   touchupinside: () {
                      //     context.pushNamed(AuthPasswordScreen.routeName,
                      //       queryParams: {'export_privateKey': 'true'});
                      //   },
                      // ),
                      // Spacer(),
                      // SettingsMenu(
                      //   leftImage: false,
                      //   title: TR(context, 'RWF 내보내기'),
                      //   touchupinside: () {
                      //     context.pushNamed(AuthPasswordScreen.routeName,
                      //         queryParams: {'export_privateKeyRwf': 'true'});
                      //   },
                      // ),
                      // SizedBox(height: 40.h),
                      // Container(
                      //   height: 8,
                      //   color: GRAY_10,
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                      //   child: TextButton(
                      //     onPressed: () async {
                      //       return;
                      //     },
                      //     child: Text(
                      //       '키확인',
                      //       style: typo14semibold.copyWith(color: GRAY_50),
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(
                      //   height: 34,
                      // )
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<String?> _showInputDialog(String defaultText) async {
    FocusNode _focusNode = FocusNode();
    TextEditingController _textEditingController = TextEditingController(text: defaultText);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return LayoutBuilder(builder: (context, constraints) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      TR(context, '계정 이름 변경'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19.0),
                      child: CustomTextFormField(
                        hintText: TR(context, '계정 이름을 입력해주세요'),
                        constraints: constraints,
                        focusNode: _focusNode,
                        controller: _textEditingController,
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp('[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9| _-]'), allow: true)
                        ],
                        maxLength: 20,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pop('');
                                _textEditingController.clear();
                              },
                              child: Text(
                                TR(context, '취소'),
                                style: typo14bold100.copyWith(
                                    color: SECONDARY_90),
                              ),
                              style: popupGrayButtonStyle.copyWith(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    // side: BorderSide(),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.zero,
                                      bottomLeft: Radius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                context.pop(_textEditingController.text);
                              },
                              child: Text(
                                TR(context, '확인'),
                                style: typo14bold100.copyWith(color: WHITE),
                              ),
                              style: popupSecondaryButtonStyle.copyWith(
                                backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) => SECONDARY_90,
                                ),
                                overlayColor:
                                MaterialStateProperty.all(SECONDARY_90),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    // side: BorderSide(),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8.r),
                                      bottomLeft: Radius.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
          });
      });
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

class UserInfoItem extends StatelessWidget {
  const UserInfoItem(
      {super.key, required this.title, required this.itemString});
  final String title;
  final String itemString;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Text(
          title,
          style: typo16medium,
        ),
        trailing: Text(
          itemString,
          style: typo16regular,
        ),
      ),
    );
  }
}

gen_keys(String mnemonic) {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final rootKey = bip32.BIP32.fromSeed(seed);
  rootKey.toBase58();
  print('rootKey.toBase58()');
  print(rootKey.toBase58());
// bip32.BIP32.fromBase58(string)
  // BIP44
  // Rigo HD path "m/44'/1021'/1'/0" + 순번

  // first key pair
  final child0 = rootKey.derivePath("m/44'/1021'/0'/0/0");
  final prvHex0 = toHex(child0.privateKey!.buffer);
  final pubHex0 = toHex(child0.publicKey.buffer);

  print("index[0] - prv0:" + prvHex0 + ", pub0:" + pubHex0);

  //
  // second key pair
  final child1 = rootKey.derivePath("m/44'/1021'/0'/0/1");
  final prvHex1 = toHex(child1.privateKey!.buffer);
  final pubHex1 = toHex(child1.publicKey.buffer);

  print("index[1] - prv1:" +
      '${prvHex1.length}' +
      ", pub1:" +
      '${pubHex1.length}');
  print("index[1] - prv1:" + prvHex1 + ", pub1:" + pubHex1);
}

String toHex(ByteBuffer bz) {
  return bz
      .asUint8List()
      .map((e) => e.toRadixString(16).padLeft(2, '0'))
      .join();
}

getPubKey(String compressedPublicKeyHex2) {
  final compressedPublicKeyHex = compressedPublicKeyHex2; // 압축된 공개 키 (16진수)

  final compressedPublicKeyBytes = hexToBytes(compressedPublicKeyHex);
  final domainParams = ECCurve_secp256k1();
  final pointQ = domainParams.curve.decodePoint(compressedPublicKeyBytes);

  final publicKey = export1.ECPublicKey(pointQ, domainParams);
  print(publicKey.Q);
  // final publicKeyBytes = publicKey.Q.getEncoded(false);

  // print('Uncompressed Public Key: ${bytesToHex(publicKeyBytes)}');
}
