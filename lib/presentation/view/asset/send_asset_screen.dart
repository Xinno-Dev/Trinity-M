import 'dart:developer';

import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/balance_row.dart';
import '../../../../domain/model/rpc/governance_rule.dart';
import '../../../../presentation/view/asset/send_confirm_screen.dart';
import '../../../../presentation/view/scan_qr_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/color_title_column.dart';
import '../../../common/const/widget/custom_radio_list_tile.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/icon_border_button.dart';
import '../../../common/const/widget/quantity_row.dart';
import '../../../common/const/widget/title_with_image.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/style/boxDecoration.dart';
import '../../../common/style/outlineInputBorder.dart';
import '../../../common/trxHelper.dart';
import '../../../domain/model/coin_model.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/account.dart';
import '../../../services/json_rpc_service.dart';

class SendAssetScreen extends ConsumerStatefulWidget {
  SendAssetScreen({Key? key, this.walletAddress}) : super(key: key);
  static String get routeName => 'sendAssetScreen';
  String? walletAddress;

  @override
  ConsumerState<SendAssetScreen> createState() => _SendAssetScreenState();
}

class _SendAssetScreenState extends ConsumerState<SendAssetScreen> {
  FocusNode addressTextFocus = FocusNode();
  FocusNode quantityTextFocus = FocusNode();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController();
  bool addressTextFieldIsEmpty = true;
  bool quantityTextFieldIsEmpty = true;
  bool isAddressValid = false;

  NetworkModel? networkModel;
  CoinModel? currentCoin;

  String receivedAddress = '';
  String addressTextFieldText = '';

  String fee = '0.00000000';
  String sendAmount = '0.00000000';
  String totalAmount = '0.00000000';

  String currentNetwork  = 'RIGO Main Net';
  // String currentCoinName = 'RIGO';
  // String currentCoinUnit = 'RIGO';
  String currentAmount = '';
  String hintText = '00.00';

  int networkValue = 1;
  int tokenValue = 1;

  late FToast fToast;

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

  void pasteFromClipboard() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    addressTextFocus.requestFocus();

    setState(() {
      _addressController.text = cdata?.text ?? '';
      validateAddressTextField();
    });
  }

  Future<void> _navigateAndInsertAddress(BuildContext context) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ScanQRScreen()));
    setState(() {
      _addressController.text = result.toString();
      validateAddressTextField();
    });
  }

  // Future<String> getBalance() async {
  //   String walletAddress = await UserHelper().get_address();
  //   NetworkModel networkModel =
  //       provider.Provider.of<NetworkProvider>(context, listen: false)
  //           .networkModel;
  //   Account account =
  //       await JsonRpcService().getAccount(networkModel, walletAddress);
  //   String amount =
  //       await TrxHelper().getAmount(account.balance!, scale: DECIMAL_PLACES);
  //   currentAmount = amount;
  //   return getFormattedText(
  //       value: double.parse(amount), decimalPlaces: DECIMAL_PLACES);
  // }

  Future<String> getFee() async {
    // NetworkModel networkModel =
    //     provider.Provider.of<NetworkProvider>(context, listen: false)
    //         .networkModel;
    GovernanceRule governanceRule =
        await JsonRpcService().getGovernanceRule(networkModel!);
    BigInt gasPrice = BigInt.parse(governanceRule.gasPrice ?? '0');
    BigInt minTrxGas = BigInt.parse(governanceRule.minTrxGas ?? '0');
    fee = await TrxHelper()
        .getAmount((gasPrice * minTrxGas).toString(), scale: 8);
    return fee;
  }

  bool validateAddress(String address) {
    // 0x로 시작하고 이어지는 40자의 문자열이 16진수로만 구성되어 있는지 확인
    RegExp regex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return regex.hasMatch(address);
  }

  void validateAddressTextField() {
    addressTextFieldIsEmpty = _addressController.text.isEmpty;
    isAddressValid = validateAddress(_addressController.text);
  }

  void refreshHintText() {
    hintText = '0.${currentCoin!.decimalEmptyStr}';
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    // for Dev..
    if (IS_DEV_MODE) {
      receivedAddress = '0x41c7c853cd4d6e035672a4f2653e918499b8e71f';
      _addressController.text = receivedAddress;
      addressTextFieldIsEmpty = false;
      isAddressValid = true;
    }

    networkModel =
        provider.Provider.of<NetworkProvider>(context, listen: false)
            .networkModel;
    currentNetwork = networkModel!.name;
    currentCoin = ref.read(coinProvider).currentCoin;
    refreshHintText();

    quantityTextFocus.addListener(() {
      setState(() {
        if (quantityTextFocus.hasFocus) {
          hintText = '';
        } else {
          refreshHintText();
        }
      });
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('--> SendAssetScreen build : $currentNetwork / ${currentCoin!.code}');
    // refreshHintText();

    return GestureDetector(
      onTap: () {
        addressTextFocus.unfocus();
        quantityTextFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          title: Text(
            TR(context, '보내기'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
          elevation: 0,
        ),
        backgroundColor: WHITE,
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 16.h,
                    ),
                    buildSelectCoinColumn(context),
                    SizedBox(
                      height: 20.h,
                    ),
                    ColumnTitle(titleText: TR(context, '받는 사람')),
                    SizedBox(
                      height: 16.h,
                    ),
                    Container(
                      decoration: textFieldBoxDecoration,
                      child: buildAddressTextField(),
                    ),
                    if (!addressTextFieldIsEmpty && !isAddressValid)
                      Column(
                        children: [
                          SizedBox(
                            height: 8.h,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              TR(context, '확인할 수 없는 지갑 주소입니다'),
                              style: typo16regular.copyWith(color: ERROR_90),
                            ),
                          ),
                        ],
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
                            _navigateAndInsertAddress(context);
                          },
                        ),
                        SizedBox(
                          width: 8.h,
                        ),
                        IconBorderButton(
                          imageAssetName: 'assets/svg/icon_copy.svg',
                          text: TR(context, '붙여넣기'),
                          onPressed: pasteFromClipboard,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32.h,
                    ),
                  ],
                ),
              ),
              Container(
                height: 8.h,
                color: GRAY_10,
              ),
              Container(
                height: 8.h,
                color: GRAY_10,
              ),
              Container(
                color: GRAY_5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      QuantityRow(
                        leftWidget: Text(
                          TR(context, '수수료(예상)'),
                          style: typo16medium,
                        ),
                        rightWidgetList: [
                          FutureBuilder<String>(
                              future: getFee(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return BalanceRow(
                                    balance: snapshot.data ?? '0.0',
                                    tokenUnit: 'RIGO',
                                  );
                                  // return Row(
                                  //   children: [
                                  //     Text(
                                  //       snapshot.data!,
                                  //       style: typo16medium,
                                  //     ),
                                  //     SizedBox(
                                  //       width: 4,
                                  //     ),
                                  //     Text(
                                  //       'RIGO',
                                  //       style: typo16regular.copyWith(
                                  //           color: GRAY_70),
                                  //     ),
                                  //   ],
                                  // );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    TR(context, '-'),
                                    style: typo16regular,
                                  );
                                } else {
                                  return Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: PRIMARY_90,
                                      ),
                                    ),
                                  );
                                }
                              }),
                          SizedBox(
                            height: 16.h,
                          )
                        ],
                      ),
                      QuantityRow(
                        leftWidget: Text(
                          TR(context, '총 수량'),
                          style: typo16semibold,
                        ),
                        rightWidgetList: [
                          Row(
                            children: [
                              BalanceRow(
                                balance: totalAmount,
                                tokenUnit: currentCoin!.symbol,
                                decimalSize: currentCoin!.decimalNum,
                              ),
                              // Text(
                              //   CommaText(totalAmount, currentCoin!.decimalNum),
                              //   style: typo18semibold.copyWith(
                              //     color: PRIMARY_90,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 4,
                              // ),
                              // Text(
                              //   currentCoin!.symbol,
                              //   style: typo16regular.copyWith(
                              //     color: GRAY_70,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: SendAssetButton(
                    addressTextFieldIsEmpty: addressTextFieldIsEmpty,
                    quantityTextFieldIsEmpty: quantityTextFieldIsEmpty,
                    isAddressValid: isAddressValid,
                    receivedAddress: _addressController.text,
                    currentAmount: currentAmount,
                    sendAmount: sendAmount,
                    totalAmount: totalAmount,
                    fee: fee,
                    coinName: currentCoin!.symbol,
                    onPressed: () {
                      if (!addressTextFieldIsEmpty &&
                          !quantityTextFieldIsEmpty) {
                        if (double.parse(currentAmount) <
                            double.parse(totalAmount)) {
                          _showToast(TR(context, '보유한 수량이 부족합니다'));
                          return;
                        }

                        if (!isAddressValid) return;
                        getSendAmount(sendAmount);

                        showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return SendConfirmScreen(
                                receivedAddress: _addressController.text,
                                sendAmount: sendAmount,
                                totalAmount: totalAmount,
                                fee: fee,
                                coin: currentCoin!.symbol,
                                networkName: currentNetwork,
                                decimal: currentCoin!.decimalNum,
                              );
                            });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 300.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildSelectCoinColumn(BuildContext context) {
    return Column(
      children: [
        ColumnTitle(
          titleText: TR(context, '보내는 자산'),
        ),
        SizedBox(
          height: 16,
        ),
        ColorTitleColumn(
          titleColor: BG,
          titleWidget: Row(
            children: [
              TitleWithImage(
                title: currentNetwork,
                titleStyle: typo14semibold,
              ),
            ],
          ),
          bodyWidget: InkWell(
            onTap: () {
              // 추후 토큰 추가 시 보이도록
              // buildTokenBottomSheet(context);
            },
            child: Row(
              children: [
                FutureBuilder(
                  future: ref.read(coinProvider).
                    getBalance(networkModel!),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      currentAmount = (snapshot.data ?? '0.00000000').replaceAll(',', '');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              getCoinIcon(currentCoin!, size: 20.r),
                              SizedBox(width: 5.w),
                              Text(
                                currentCoin!.symbol,
                                style: typo16semibold,
                              ),
                            ]
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                TR(context, '잔고'),
                                style: typo14regular.copyWith(color: GRAY_50),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              BalanceRow(
                                balance: snapshot.data ?? '',
                                tokenUnit: currentCoin!.symbol,
                                decimalSize: currentCoin!.decimalNum,
                              ),
                              // Text(
                              //   snapshot.data ?? '',
                              //   style: typo14medium,
                              // ),
                              // SizedBox(
                              //   width: 4,
                              // ),
                              // Text(
                              //   currentCoin!.symbol,
                              //   style: typo14regular,
                              // ),
                            ],
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: PRIMARY_90,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ColumnTitle(titleText: TR(context, '보낼 수량')),
        SizedBox(
          height: 16,
        ),
        Container(
          decoration: textFieldBoxDecoration,
          child: buildQuantityTextField(),
        ),
      ],
    );
  }

  TextField buildAddressTextField() {
    return TextField(
      controller: _addressController,
      focusNode: addressTextFocus,
      decoration: InputDecoration(
        focusedBorder: grayBorder,
        border: addressTextFieldIsEmpty ? InputBorder.none : grayBorder,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        hintText: TR(context, '0x로 시작하는 주소를 입력해주세요.'),
        hintStyle: typo16regular150.copyWith(color: GRAY_40),
      ),
      minLines: 2,
      maxLines: 2,
      style: typo16regular150,
      scrollPadding: EdgeInsets.only(bottom: 300.h),
      onChanged: (String text) {
        setState(() {
          addressTextFieldIsEmpty = _addressController.text.isEmpty;
          isAddressValid = validateAddress(text);
          print('address : $text');
          if (isAddressValid) print('올바른 주소!!');
        });
      },
      textInputAction: TextInputAction.next,
      onSubmitted: (String text) {
        quantityTextFocus.requestFocus();
      },
    );
  }

  TextButton buildChangeNetworkButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        UiHelper().buildRoundBottomSheet(
          context: context,
          title: TR(context, '네트워크 변경'),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              children: [
                CustomRadioListTile(
                  name: 'Rigo Main Net',
                  index: 1,
                  image: SvgPicture.asset(
                    'assets/svg/logo_rigo.svg',
                    width: 40,
                  ),
                  balance: 38358.83,
                  isSelected: networkValue == 1,
                  onTap: () {
                    setModalState(() {
                      networkValue = 1;
                    });
                  },
                ),
                CustomRadioListTile(
                  name: 'Rigo Tester Net',
                  index: 2,
                  image: SvgPicture.asset(
                    'assets/svg/logo_rigo.svg',
                    width: 40,
                  ),
                  balance: 2284.50,
                  isSelected: networkValue == 2,
                  onTap: () {
                    setModalState(() {
                      networkValue = 2;
                    });
                  },
                ),
                SizedBox(
                  height: 32.0,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (networkValue == 1) {
                          currentNetwork = 'Rigo Main Net';
                        } else {
                          currentNetwork = 'Rigo Test Net';
                        }
                      });
                      Navigator.pop(context);
                      _showToast(TR(context, '네트워크를 변경했습니다'));
                    },
                    child: Text(
                      TR(context, '네트워크 변경'),
                      style: typo16bold.copyWith(
                        color: WHITE,
                      ),
                    ),
                    style: primaryButtonStyle,
                  ),
                )
              ],
            );
          }),
        );
      },
      child: Text(
        TR(context, '변경'),
        style: typo14semibold.copyWith(color: SECONDARY_90),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Future<dynamic> buildTokenBottomSheet(BuildContext context) {
    return UiHelper().buildRoundBottomSheet(
      context: context,
      title: TR(context, '전송할 토큰 변경'),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
        return Column(
          children: [
            CustomRadioListTile(
              isToken: true,
              name: 'Bitcoin',
              index: 1,
              image: Image.asset(
                'assets/images/logo_btc.png',
                width: 40,
              ),
              balance: 24297.00,
              tokenBalance: 1.00245080,
              tokenUnit: 'BIT',
              isSelected: networkValue == 1,
              onTap: () {
                setModalState(() {
                  tokenValue = 1;
                });
              },
            ),
            CustomRadioListTile(
              isToken: true,
              name: 'BNBcoin',
              index: 2,
              image: Image.asset(
                'assets/images/logo_bnb.png',
                width: 40,
              ),
              balance: 2284.50,
              tokenBalance: 45.00,
              tokenUnit: 'BNB',
              isSelected: networkValue == 2,
              onTap: () {
                setModalState(() {
                  tokenValue = 2;
                });
              },
            ),
            SizedBox(
              height: 32.0,
            ),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // if (tokenValue == 1) {
                    //   currentCoinName = 'Bitcoin';
                    //   currentCoinUnit = 'BIT';
                    // } else {
                    //   currentCoinName = 'BNBcoin';
                    //   currentCoinUnit = 'BNB';
                    // }
                  });
                  Navigator.pop(context);
                  // _showToast('네트워크를 변경했습니다');
                },
                child: Text(
                  TR(context, '토큰 변경'),
                  style: typo16bold.copyWith(
                    color: WHITE,
                  ),
                ),
                style: primaryButtonStyle,
              ),
            )
          ],
        );
      }),
    );
  }

  TextField buildQuantityTextField() {
    return TextField(
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: _quantityController,
      focusNode: quantityTextFocus,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        border: quantityTextFieldIsEmpty ? InputBorder.none : grayBorder,
        focusedBorder: grayBorder,
        hintText: hintText,
        hintStyle: typo18semibold.copyWith(color: GRAY_40),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Text(
            currentCoin!.symbol,
            style: typo16regular,
          ),
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      //maxLines: 2,
      style: typo18semibold,
      textAlign: TextAlign.end,
      onChanged: (String text) {
        setState(() {
          if (text == '0.00000000' || text == '0') {
            text = '';
          }
          quantityTextFieldIsEmpty = text.isEmpty;
        });
      },
      textInputAction: TextInputAction.done,
      onSubmitted: (String text) {
        quantityTextFocus.unfocus();
      },
      inputFormatters: [
        CurrencyInputFormatter(
          trailingSymbol: '',
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: currentCoin!.decimalNum,
          onValueChange: (num value) {
            setState(() {
              sendAmount = value.toStringAsFixed(currentCoin!.decimalNum);
              if (!currentCoin!.isToken) {
                double sum = value + double.parse(fee);
                totalAmount = sum.toStringAsFixed(currentCoin!.decimalNum);
              } else {
                totalAmount = value.toStringAsFixed(currentCoin!.decimalNum);
              }
              log('--> amount value : ${value.toString()} => $totalAmount / ${currentCoin!.decimalNum}');
            });
          })
      ],
    );
  }
}

class SendAssetButton extends StatelessWidget {
  const SendAssetButton({
    super.key,
    required this.addressTextFieldIsEmpty,
    required this.quantityTextFieldIsEmpty,
    required this.isAddressValid,
    required this.receivedAddress,
    required this.sendAmount,
    required this.totalAmount,
    required this.coinName,
    required this.fee,
    required this.currentAmount,
    this.onPressed,
  });

  final bool addressTextFieldIsEmpty;
  final bool quantityTextFieldIsEmpty;
  final bool isAddressValid;
  final Function()? onPressed;
  final String receivedAddress;
  final String fee;
  final String sendAmount;
  final String totalAmount;
  final String coinName;
  final String currentAmount;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        TR(context, '보내기'),
        style: typo16bold.copyWith(
            color: (!addressTextFieldIsEmpty &&
                    !quantityTextFieldIsEmpty &&
                    isAddressValid)
                ? WHITE
                : GRAY_40),
      ),
      style: (!addressTextFieldIsEmpty &&
              !quantityTextFieldIsEmpty &&
              isAddressValid)
          ? primaryButtonStyle.copyWith(
              padding: MaterialStateProperty.all(
                EdgeInsets.all(20),
              ),
            )
          : disableButtonStyle.copyWith(
              padding: MaterialStateProperty.all(
                EdgeInsets.all(20),
              ),
            ),
    );
  }
}

class ColumnTitle extends StatelessWidget {
  ColumnTitle({
    super.key,
    required this.titleText,
  });

  final String titleText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        titleText,
        style: typo16semibold,
      ),
    );
  }
}
