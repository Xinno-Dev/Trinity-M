import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/provider/login_provider.dart';

import '../../common/common_package.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/const/widget/primary_button.dart';
import '../../presentation/view/main_screen.dart';
import '../../presentation/view/signup/login_pass_screen.dart';
import '../model/address_model.dart';

class ProfileViewModel {
  factory ProfileViewModel([LoginProvider? provider]) {
    if (provider != null) {
      _singleton.loginProv = provider;
    }
    return _singleton;
  }
  static final _singleton = ProfileViewModel._internal();
  ProfileViewModel._internal();

  late LoginProvider loginProv;
  late BuildContext context;

  final drawerTitleN = ['내 정보','구매 내역','-','이용약관','개인정보처리방침', '버전 정보', '로그아웃'];
  final profileSize = 100.0;

  get accountPic {
    final account  = loginProv.account;
    final userInfo = loginProv.userInfo;
    if (account?.pic != null) {
      LOG('---> account?.pic : ${account?.pic}');
      if (account!.pic!.contains('https:')) {
        return CachedNetworkImage(imageUrl: account.pic!, width: profileSize.r, height: profileSize.r);
      }
      return Image.asset(account.pic!, width: profileSize.r, height: profileSize.r);
    }
    if (userInfo?.pic != null) {
      LOG('---> userInfo?.pic : ${userInfo?.pic}');
      if (userInfo!.pic!.contains('https:')) {
        return CachedNetworkImage(imageUrl: userInfo.pic!, width: profileSize.r, height: profileSize.r);
      }
      return Image.asset(userInfo.pic!, width: profileSize.r, height: profileSize.r);
    }
    if (userInfo?.picThumb != null) {
      LOG('---> userInfo?.picThumb : ${userInfo?.picThumb}');
      if (userInfo!.picThumb!.contains('https:')) {
        return CachedNetworkImage(imageUrl: userInfo.picThumb!, width: profileSize.r, height: profileSize.r);
      }
      return userInfo.picThumb;
    }
    return Icon(Icons.account_circle, size: profileSize.r, color: GRAY_30);
  }

  getPageTitle(BuildContext context) {
    this.context = context;
    final pageIndex = loginProv.mainPageIndex;
    return Center(
      child: pageIndex == 0 ?
      Text(TR(context, 'Market')) :
      FittedBox(
        fit: BoxFit.fitWidth,
        child: InkWell(
          onTap: () {
            showProfileSelectBox(
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
                Text(TR(context, loginProv.accountName)),
                Icon(Icons.arrow_drop_down_sharp),
              ],
            )
          )
        ),
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////

  mainDrawer(BuildContext context) {
    this.context = context;
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: SizedBox.expand(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: context.pop,
                          child: Icon(Icons.close, size: 30, color: GRAY_30, weight: 1),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(loginProv.accountName, style: typo18bold),
                    if (loginProv.accountSubtitle.isNotEmpty)
                      Text(loginProv.accountSubtitle, style: typo14semibold),
                    SizedBox(height: 5),
                    Text(loginProv.accountMail, style: typo14regular),
                  ],
                ),
              ),
            ),
            ...drawerTitleN.map((e) => _mainDrawerItem(e, drawerTitleN.indexOf(e))).toList(),
            Spacer(),
            ListTile(
              title: Text(
                  '사업자명: 주식회사 엑시노\n'
                      '대표이사: 이지민\n'
                      '등록번호: 644-86-03081\n'
                      '대표번호: 070-4304-5778\n'
                      '서울시 서초구 서운로 13 126-나94호',
                  style: typo12semibold100),
              onTap: () {
                context!.pop();
              },
            ),
          ],
        ),
      )
    );
  }

  _mainDrawerItem(String e, index) {
    if (e == '-') {
      return Divider();
    }
    return ListTile(
        title: Text(e, style: typo16bold),
        onTap: () {
          switch (DrawerActionType.values[index]) {
            case DrawerActionType.logout:
              loginProv.logout().then((_) {
                loginProv.setMainPageIndex(0);
              });
              break;
            default:
              break;
          }
          context.pop();
        });
  }

  ////////////////////////////////////////////////////////////////////////

  showProfile(BuildContext context) {
    this.context = context;
    if (loginProv.userInfo != null) {
      return Column(
        children: [
          _profileTopBar(),
          _profileDescription(padding: EdgeInsets.symmetric(vertical: 25)),
          _profileButtonBox(),
        ],
      );
    } else {
      return Center(
        child: Text('No profile info..'),
      );
    }
  }

  BuildContext? _accountContext;

  setProfileContext(BuildContext context) {
    _accountContext = context;
  }

  hideProfileSelectBox() {
    loginProv.setMaskStatus(false);
    if (_accountContext != null && _accountContext!.mounted) {
      ScaffoldMessenger.of(_accountContext!).hideCurrentMaterialBanner();
    }
  }

  showProfileSelectBox({Function(AddressModel)? onSelect, Function()? onAdd}) {
    if (loginProv.isShowMask || loginProv.userInfo == null) return false;
    _accountContext = context;
    loginProv.setMaskStatus(true);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        content: Container(
          constraints: BoxConstraints(
            maxHeight: 500,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: [
              ...loginProv.userInfo!.addressList!.map((e) => _profileItem(e, () {
                if (onSelect != null) onSelect(e);
              })).toList(),
              SizedBox(height: 10),
              Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GRAY_50, width: 1),
                    color: Colors.white
                ),
                child: InkWell(
                  onTap: () {
                    LOG('---> account add');
                    if (onAdd != null) onAdd();
                  },
                  borderRadius: BorderRadius.circular(10),
                  // splashColor: PRIMARY_100,
                  child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GRAY_20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 30, weight: 1, color: GRAY_30),
                        SizedBox(width: 10),
                        Text(TR(_accountContext!, '계정 추가'), style: typo14bold),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        actions: [
          Container()
          // SnackBarAction(
          //   label: 'Close',
          //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          // ),
        ]
      ),
    );
    return true;
  }

  Widget _profileItem(AddressModel item, Function() onSelect) {
    final iconSize = 40.0.r;
    final color = item.address == loginProv.selectAccount?.address ? PRIMARY_100 : GRAY_50;
    return InkWell(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize),
                child: item.pic != null ? Image.asset(item.pic!) :
                Icon(Icons.account_circle, size: iconSize, color: GRAY_40),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(STR(item.accountName),
                      style: typo16semibold.copyWith(color: color)),
                  Text(ADDR(item.address),
                      style: typo11normal.copyWith(color: GRAY_40))
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  _profileTopBar({EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(profileSize.r),
            child: accountPic,
          ),
          // SizedBox(width: 20),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _profileFollowBox(TR(context, '팔로워'), STR(account?.follower ?? '0')),
          //       _profileFollowBox(TR(context, '팔로잉'), STR(account?.following ?? '0')),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  _profileFollowBox(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title, style: typo14normal),
        Text(value, style: typo14bold),
      ],
    );
  }

  _profileDescription({EdgeInsets? padding}) {
    return Container(
      padding: padding,
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: Text(STR(loginProv.account?.description ??
          '이국적 풍치의 이탈리아 투스카니 스타일 클럽하우스와 '
          '대저택 컨셉의 최고급 호텔 시설로 휴양과 메이저급 골프코스의 다이나믹을 함께 즐길 수'
          ' 있는 태안반도에 위치한 휴양형 고급 골프 리조트입니다.'),
          style: typo14medium, textAlign: TextAlign.center),
    );
  }

  _profileButtonBox() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            color: GRAY_20,
            textStyle: typo14semibold,
            isSmallButton: true,
            onTap: () {

            },
            text: TR(context, '프로필 편집'),
          )
        ),
        SizedBox(width: 10),
        Expanded(
          child: PrimaryButton(
            color: GRAY_20,
            textStyle: typo14semibold,
            isSmallButton: true,
            onTap: () {

            },
            text: TR(context, '보유 상품'),
          )
        ),
      ],
    );
  }

  _selectAccount(AddressModel select) {
    LOG('---> _selectAccount : ${select.toJson()}');
    loginProv.changeAccount(select);
    hideProfileSelectBox();
  }

  _startAccountAdd() {
    showInputDialog(context,
      TR(context, '계정 추가'),
      defaultText: IS_DEV_MODE ? EX_TEST_ACCCOUNT_00_1 : '',
      hintText: TR(context, '계정명을 입력해 주세요.')).then((text) {
      LOG('---> account add name : $text');
      if (STR(text).isNotEmpty) {
        // nickId duplicate check..
        loginProv.checkNickId(nickId: text!,
          onError: (type) => Fluttertoast.showToast(msg: type.errorText)).
          then((check) {
            if (check == true) {
              // pass check..
              hideProfileSelectBox();
              Navigator.of(context).push(
                  createAniRoute(LoginPassScreen())).then((passOrg) {
                if (STR(passOrg).isNotEmpty) {
                  // add wallet..
                  loginProv.addNewAccount(passOrg).then((result) {
                    LOG('---> account add result : $result');
                    Fluttertoast.showToast(
                      msg: result ? "계정추가 성공" : "계정추가 실패",
                    );
                  });
                }
              });
            } else {
              _startAccountAdd();
            }
        });
      }
    });
  }
}