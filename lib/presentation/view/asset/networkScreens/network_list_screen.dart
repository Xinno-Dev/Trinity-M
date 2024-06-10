import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import '../../../../common/const/widget/disabled_button.dart';
import '../../../../common/provider/firebase_provider.dart';
import '../../../../presentation/view/asset/networkScreens/network_add_screen.dart';
import '../../../../presentation/view/asset/networkScreens/network_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:helpers/helpers.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/custom_radio_list_tile.dart';
import '../../../../common/const/widget/custom_toast.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../services/json_rpc_service.dart';

enum NetworkAddType {
  none,
  auto,
  manual,
}

class NetworkListScreen extends ConsumerStatefulWidget {
  NetworkListScreen({Key? key}) : super(key: key);
  static String get routeName => 'NetworkListScreen';

  @override
  ConsumerState<NetworkListScreen> createState() => _NetworkListScreenState();
}

class _NetworkListScreenState extends ConsumerState<NetworkListScreen> {
  late CoinProvider coinProv;
  NetworkModel? networkModel;
  final fToast = FToast();

  // change network..
  _setNetwork(BuildContext context, NetworkModel network) {
    final newNetwork = provider.Provider.of<NetworkProvider>
      (context, listen: false).setNetworkFromId(network.id ?? network.chainId);
    if (newNetwork != null) {
      coinProv.setNetworkFromId(newNetwork.id ?? newNetwork.chainId);
      Navigator.of(context).pop(1);
    }
  }

  // for search..
  setShowSearchList() {

  }

  @override
  Widget build(BuildContext context) {
    coinProv = ref.watch(coinProvider);
    var networkList =
        provider.Provider.of<NetworkProvider>(context).networkList;
    networkModel = provider.Provider.of<NetworkProvider>(context)
        .networkModel;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: () {
              context.pop(3);
            },
          ),
          leadingWidth: 40.w,
          titleSpacing: 0,
          centerTitle: true,
          title: Text(TR('네트워크'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: ListView(
                  children: [
                    SizedBox(height: 10.h),
                    ...networkList.map((e) =>
                      InkWell(
                        onTap: () {
                          _setNetwork(context, e);
                        },
                        child: CustomRadioListTile(
                          name:  e.name,
                          index: e.index,
                          image: e.isRigo ?
                          SvgPicture.asset('assets/svg/logo_rigo.svg', height: 40) :
                          Image.asset('assets/images/icon_mdl.png', height: 40),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          balance: 0,
                          backgroundColor: Colors.transparent,
                          isToken: false,
                          isSelected: networkModel!.chainId == e.chainId,
                          type: CustomRadioType.info,
                          onMenu: () {
                            Navigator.of(context).push(
                                createAniRoute(NetworkInfoScreen(e, isCanDelete: networkModel!.chainId != e.chainId))
                            ).then((result) {
                              setState(() {
                                if (BOL(result)) {
                                  _showToast('네트워크가 삭제되었습니다.');
                                }
                              });
                            });
                          },
                        ),
                      )).toList()
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: PrimaryButton(
                    text: '${TR('네트워크 추가')} +',
                    isSmallButton: false,
                    onTap: () {
                      // _buildNetworkAddSheet();
                      Navigator.of(context).push(
                        createAniRoute(NetworkAddScreen(NetworkAddType.auto))
                      ).then((result) {
                        if (BOL(result)) {
                          _showToast(TR('네트워크를 추가했습니다.'));
                        }
                      });
                    }
                  ),
                )
              )
            ],
          ),
        )
      )
    );
  }

  _buildNetworkAddSheet() {
    return UiHelper().buildRoundBottomSheet(
      context: context,
      title: TR('네트워크 추가'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              context.pop();
              Navigator.of(context).push(
                createAniRoute(NetworkAddScreen(NetworkAddType.manual))
              ).then((result) {
                if (BOL(result)) {
                  _showToast(TR('네트워크를 추가했습니다.'));
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              color: Colors.transparent,
              child: Text(
                TR('네트워크 수동 추가'),
                style: typo16semibold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              context.pop();
              Navigator.of(context).push(
                createAniRoute(NetworkAddScreen(NetworkAddType.auto))
              ).then((result) {
                if (BOL(result)) {
                  _showToast(TR('네트워크를 추가했습니다.'));
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              color: Colors.transparent,
              child: Text(
                TR('네트워크 조회'),
                style: typo16semibold,
              ),
            ),
          ),
        ],
      )
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
