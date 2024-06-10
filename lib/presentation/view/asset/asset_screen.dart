import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text_plus/auto_size_text.dart';
import '../../../../common/const/widget/balance_row.dart';
import '../../../../common/const/widget/custom_badge.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../domain/model/coin_model.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../presentation/view/account/account_manage_screen.dart';
import '../../../../presentation/view/asset/receive_asset_screen.dart';
import '../../../../presentation/view/asset/send_asset_screen.dart';
import '../../../../presentation/view/asset/tabBarViewScreens/coin_list_screen.dart';
import '../../../../presentation/view/asset/tabBarViewScreens/trx_history_list_screen.dart';
import '../../../../services/json_rpc_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as provider;
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/button_with_image.dart';
import '../../../common/const/widget/custom_radio_list_tile.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/network_error_screen.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/const/widget/show_explorer.dart';
import '../../../domain/model/address_model.dart';
import '../signup/login_screen.dart';
import '../account/user_info_screen.dart';
import 'networkScreens/network_list_screen.dart';
import 'swapScreen/swap_asset_screen.dart';

class AccountInfo {
  final String accountName;
  final String address;
  final String balance;
  final bool hasMnemonic;

  AccountInfo(
      {required this.hasMnemonic,
      required this.accountName,
      required this.address,
      required this.balance});
}

class AssetScreen extends ConsumerStatefulWidget {
  static String get routeName => 'AssetScreen';
  const AssetScreen({
    super.key,
  });

  @override
  ConsumerState<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends ConsumerState<AssetScreen> with WidgetsBindingObserver {
  String currentNetwork = 'RIGO Mainnet';
  String walletAddress = '';
  String addressText = '';
  String accountName = '';
  CoinModel? currentCoin;
  bool isError = false;
  bool isFirst = true;
  int currentNetworkValue = 1;
  NetworkModel? networkModel;
  
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

  get showCoinList {
    var showList = [];
    if (networkModel != null) {
      for (CoinModel item in ref
          .read(coinProvider)
          .coinList) {
        if ((item.walletAddress.isEmpty ||
             item.walletAddress == walletAddress) &&
             networkModel!.chainId == item.mainNetChainId) {
          showList.add(item);
        }
      }
    }
    return showList.length;
  }

  Future<AddressModel> _getAddressModel() async {
    String jsonString = await UserHelper().get_addressList();
    List<dynamic> decodedList = json.decode(jsonString);
    walletAddress = await UserHelper().get_address();
    AddressModel select_Address = AddressModel();
    for (var jsonObject in decodedList) {
      AddressModel model = AddressModel.fromJson(jsonObject);
      if (model.address == walletAddress) {
        select_Address = model;
        ref.read(coinProvider).walletAddress = walletAddress;
        break;
      }
    }
    // return AddressModel.fromJson(decodedList.first);
    return select_Address;
  }

  Future<AccountInfo> getAccountInfo(
    NetworkModel? networkModel,
    String address) async {
    AddressModel addressModel = await _getAddressModel();
    if (IS_ACCOUNT_NAME_SETDOC && networkModel != null && networkModel.isRigo) {
      if (address.substring(0, 2) != '0x') {
        address = '0x' + address;
      }
      var accountInfo = await JsonRpcService()
          .getAccountInfo(networkModel, address);
      if (STR(accountInfo.name).isNotEmpty) {
        addressModel.accountName = accountInfo.name;
        LOG('---> update account info : ${addressModel.accountName}');
      }
    }
    // String balance = await getBalance();
    return AccountInfo(
      hasMnemonic: addressModel.hasMnemonic ?? false,
      accountName: addressModel.accountName ?? '',
      address: addressModel.address ?? '',
      balance: '0',
    );
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('---> didChangeAppLifecycleState : $state');
    if (IS_AUTO_LOCK_MODE && state == AppLifecycleState.inactive) {
      setState(() {
        context.goNamed(LoginScreen.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    networkModel = provider.Provider.of<NetworkProvider>(context)
        .networkModel;
    currentNetwork = networkModel!.name;
    currentNetworkValue = networkModel!.index;

    // get coin and address..
    var coinPv = ref.watch(coinProvider);
    currentCoin   = coinPv.currentCoin;
    walletAddress = coinPv.walletAddress;
    coinPv.networkChainId = networkModel!.chainId;
    final isSwapEnable = currentCoin != null ? (currentCoin!.isRigoCoin || currentCoin!.isMDL) : false;
    LOG('--> change network : ${isSwapEnable} / ${walletAddress} => ${currentCoin?.isRigoCoin} / ${currentCoin?.isMDL}');

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: BG,
          elevation: 0,
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    createAniRoute(NetworkListScreen())
                  ).then((result) {
                    LOG('--> result : $result');
                    if (INT(result) > 0) {
                      Future.delayed(Duration(milliseconds: 200)).then((_) {
                        if (result == 1) {
                          _showToast(TR('네트워크를 변경했습니다'));
                        } else if (result == 2) {
                          _showToast(TR('네트워크를 추가했습니다'));
                        } else if (result == 3) {
                          setState(() {});
                        }
                      });
                    }
                  });
                },
                child: Row(
                  children: [
                    getNetworkIcon(networkModel!),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      currentNetwork,
                      style: typo14bold,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    SvgPicture.asset('assets/svg/arrow_down.svg'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: isError
          ? NetworkErrorScreen()
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: BG,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAccountInfoFutureBuilder(
                              constraints.maxWidth <= 360.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 24.0),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 89.w,
                                  child: ButtonWithImage(
                                    style: whiteImageButtonStyle,
                                    buttonText: TR('보내기'),
                                    imageAssetName:
                                        'assets/svg/filled_round_arrow_up.svg',
                                    onPressed: () {
                                      context.pushNamed(
                                        SendAssetScreen.routeName,
                                        queryParams: {
                                          'walletAddress': walletAddress,
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                SizedBox(
                                  width: 89.w,
                                  child: ButtonWithImage(
                                    style: whiteImageButtonStyle,
                                    buttonText: TR('받기'),
                                    imageAssetName:
                                        'assets/svg/filled_round_arrow_down.svg',
                                    onPressed: () {
                                      UiHelper().buildRoundBottomSheet(
                                        context: context,
                                        title: TR('내 주소로 받기'),
                                        child: ReceiveAssetScreen(
                                          walletAddress: walletAddress,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (IS_SWAP_ON)...[
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  SizedBox(
                                    width: 89.w,
                                    child: ButtonWithImage(
                                      style: whiteImageButtonStyle,
                                      buttonText: TR('스왑 '),
                                      imageAssetName: isSwapEnable ? 'assets/svg/icon_swap.svg' : 'assets/svg/icon_swap_off.svg',
                                      isEnable: isSwapEnable,
                                      onPressed: () {
                                        Navigator.of(context).push(createAniRoute(SwapAssetScreen(
                                          walletAddress: walletAddress
                                        )));
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child:
                    TabBar(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      labelColor: GRAY_90,
                      labelStyle: typo16semibold,
                      unselectedLabelColor: GRAY_40,
                      indicatorColor: GRAY_90,
                      indicatorPadding: EdgeInsets.zero,
                      tabs: <Widget> [
                        Tab(
                          text: TR('전송 내역'),
                        ),
                        Tab(
                          text: TR('_자산'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        TrxHistoryListScreen(
                          isEmpty: currentCoin == null || showCoinList <= 0
                        ),
                        CoinListScreen(
                          networkModel:  networkModel!,
                          walletAddress: walletAddress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      );
    });
  }

  FutureBuilder<AccountInfo> _buildAccountInfoFutureBuilder(bool isSmallScreen) {
    var coinPv = ref.read(coinProvider);
    // currentCoin = coinPv.currentCoin;
    return FutureBuilder(
      future: getAccountInfo(networkModel, walletAddress),
      builder: (BuildContext context, AsyncSnapshot<AccountInfo> snapshot) {
        if (snapshot.hasData) {
          AccountInfo? accountInfo = snapshot.data;
          bool select_hasMnemonic = accountInfo?.hasMnemonic ?? false;
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserInfoScreen())).then((_) {
                              setState(() {});
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          color: Colors.transparent,
                          child: Row(
                              children: [
                                AutoSizeText(
                                  accountInfo?.accountName ?? TR('계정 정보 없음'),
                                  style: typo18semibold,
                                  maxLines: 1,
                                  maxFontSize: 18,
                                ),
                                SizedBox(width: 4),
                                if (!select_hasMnemonic)
                                  CustomBadge(
                                    text: TR('불러옴'),
                                    isSmall: true,
                                  ),
                                SvgPicture.asset(
                                    'assets/svg/arrow.svg',
                                    colorFilter: ColorFilter.mode(GRAY_90, BlendMode.srcIn),
                                  ),
                              ],
                          )
                        )
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AccountManageScreen(),
                            maintainState: false,
                          ),
                        ).then((value) => setState(() {
                          LOG('----------> Account changed !!');
                        }));
                      },
                      child: SvgPicture.asset('assets/svg/main_profile.svg', 
                          width: 48.r, height: 48.r),
                    ),
                  ],
                ),
                getCoinIcon(currentCoin, size: 58.r),
                SizedBox(
                  height: 14.h,
                ),
                FutureBuilder(
                  future: coinPv.getBalance(networkModel!),
                  builder: (context, snapshot) {
                    // log('---> snapshot : ${snapshot.hasData}');
                    if (snapshot.hasData) {
                      // var newBalance = snapshot.data ?? '0.0';
                      if (currentCoin != null && showCoinList > 0) {
                        // LOG('---> update main balance : ${currentCoin!.code} / ${currentCoin!.formattedBalance}');
                        return BalanceRow(
                          balance: currentCoin!.formattedBalance,
                          decimalSize: currentCoin!.decimalNum,
                          tokenUnit: currentCoin!.symbol,
                          fontSize: 24.r,
                          isShowRefresh: true,
                          isOnExplorer: networkModel!.isRigo && STR(networkModel!.exploreUrl).isNotEmpty,
                          onTapRefreshButton: () {
                            setState(() {});
                          },
                          onExplorer: () {
                            showExplorer(STR(networkModel!.exploreUrl),
                              walletAddress, 'address', isRigo: networkModel!.isRigo);
                          }
                        );
                      } else {
                        return Container();
                        // return BalanceRow(
                        //   balance: '0.0',
                        //   decimalSize: 2,
                        //   tokenUnit: networkModel!.currencySymbol.toUpperCase(),
                        //   fontSize: 24,
                        //   onTapRefreshButton: () {
                        //     setState(() {});
                        //   },
                        // );
                      }
                    } else {
                      return showLoadingItem();
                    }
                  }
                ),
                SizedBox(
                  height: 10.h,
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: BorderRadius.circular(53.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText('0x' + walletAddress,
                            style: isSmallScreen
                                ? typo10regular100
                                : typo12regular100),
                          SizedBox(
                            width: 5.h,
                          ),
                          SvgPicture.asset(
                            'assets/svg/icon_copy.svg',
                            height: isSmallScreen ? 10.0 : 12.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: '0x$walletAddress'),
                    );
                    final androidInfo = await DeviceInfoPlugin().androidInfo;
                    LOG('----> androidInfo.version.sdkInt : ${androidInfo.version.sdkInt}');
                    if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                      _showToast(TR('복사를 완료했습니다'));
                  },
                ),
              ],
            )
          );
        } else {
          return Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: SECONDARY_90,
              ),
            ),
          );
        }
      });
  }

  // buildNetworkBottomSheet(networkList) {
  //   return UiHelper().buildRoundBottomSheet(
  //     context: context,
  //     title: TR('네트워크 변경'),
  //     child: StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //       return Column(
  //         children: [
  //           ...networkList.map((e) =>
  //           InkWell(
  //             onTap: () {
  //               setModalState(() {
  //                 setNetwork(context, e.index);
  //               });
  //             },
  //             child: CustomRadioListTile(
  //               name:  e.name,
  //               index: e.index,
  //               image: e.isRigo ?
  //                 SvgPicture.asset('assets/svg/logo_rigo.svg', height: 40) :
  //                 Image.asset('assets/images/icon_mdl.png', height: 40),
  //               padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //               balance: 0,
  //               isToken: false,
  //               isSelected: currentNetworkValue == e.index,
  //             ),
  //           )).toList(),
  //           SizedBox(height: 20),
  //           PrimaryButton(
  //             text: TR('네트워크 추가'),
  //             isSmallButton: true,
  //             onTap: () async {
  //               Navigator.of(context).pop(true);
  //             }
  //           )
  //         ],
  //       );
  //     }),
  //   );
  // }
}
