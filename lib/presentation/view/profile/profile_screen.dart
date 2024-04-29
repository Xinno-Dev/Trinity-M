import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/model/address_model.dart';
import '../signup/login_pass_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key});
  static String get routeName => 'profileScreen';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = ref.read(loginProvider);
      if (!prov.isLogin) {
        Fluttertoast.showToast(msg: TR(context, '로그인이 필요한 서비스입니다.'));
        Navigator.of(context).push(
          createAniRoute(LoginScreen(isAppStart: false))).then((result) {
            if (result == null) {
              prov.setMainPageIndex(0);
            }
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    final marketProv = ref.watch(marketProvider);
    prov.context = context;
    marketProv.context = context;
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: prov.hideProfileSelectBox,
        child: Scaffold(
          appBar: AppBar(
            title: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                    },
                    icon: SvgPicture.asset('assets/svg/icon_ham.svg'),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: InkWell(
                      onTap: () {
                        prov.showProfileSelectBox(
                          context,
                          onSelect: _selectAccount,
                          onAdd: _startAccountAdd);
                      },
                      child: Container(
                        height: kToolbarHeight,
                        color: Colors.transparent,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(TR(context, prov.accountName)),
                            Icon(Icons.arrow_drop_down_sharp),
                          ],
                        )
                      )
                    ),
                  )
                ),
              ]
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            titleSpacing: 0,
            titleTextStyle: typo16bold,
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
               ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 20.h),
                  if (prov.isLogin)...[
                    prov.showProfile(),
                    marketProv.showStoreProductList(
                        isShowSeller: false, isCanBuy: false),
                  ]
                ]
              ),
              if (prov.isShowMask)
                Container(
                  color: Colors.black38,
                )
            ]
          )
        ),
      )
    );
  }

  _selectAccount(AddressModel select) {
    final prov = ref.read(loginProvider);
    LOG('---> _selectAccount : ${select.toJson()}');
    prov.changeAccount(select);
  }

  _startAccountAdd() {
    final prov = ref.read(loginProvider);
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    showInputDialog(context,
        TR(context, '계정 추가'),
        defaultText: 'jubal2001',
        hintText: TR(context, '계정명을 입력해 주세요.')).then((text) {
      LOG('---> account add name : $text');
      if (STR(text).isNotEmpty) {
        prov.inputNick = text!;
        Navigator.of(context).push(
            createAniRoute(LoginPassScreen())).then((passOrg) {
          if (STR(passOrg).isNotEmpty) {
            prov.addNewAccount(passOrg).then((result) {
              LOG('---> account add result : $result');
              Fluttertoast.showToast(
                  msg: result ? "계정추가 성공" : "계정추가 실패",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: result ? Colors.white : Colors.orange,
                  fontSize: 16.0
              );
            });
          }
        });
      }
    });
  }
}
