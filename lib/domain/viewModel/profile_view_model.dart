import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trinity_m_00/presentation/view/settings/settings_language_screen.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/provider/login_provider.dart';
import '../../../domain/model/account_model.dart';
import '../../../domain/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as IMG;

import '../../common/common_package.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/appVersionHelper.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/rwfExportHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/const/widget/image_widget.dart';
import '../../common/const/widget/primary_button.dart';
import '../../common/provider/firebase_provider.dart';
import '../../common/provider/market_provider.dart';
import '../../presentation/view/main_screen.dart';
import '../../presentation/view/market/payment_list_screen.dart';
import '../../presentation/view/profile/profile_my_info_screen.dart';
import '../../presentation/view/profile/profile_Identity_screen.dart';
import '../../presentation/view/profile/user_item_list_screen.dart';
import '../../presentation/view/profile/webview_screen.dart';
import '../../presentation/view/signup/login_pass_screen.dart';
import '../../presentation/view/signup/login_screen.dart';
import '../../services/google_service.dart';
import '../../services/iamport_service.dart';
import '../../services/icloud_service.dart';
import '../model/address_model.dart';

class ProfileViewModel {
  ProfileViewModel(BuildContext context) {
    this.context = context;
  }
  final loginProv   = LoginProvider();
  final marketProv  = MarketProvider();
  final fireProv    = FirebaseProvider();
  late BuildContext context;

  AddressModel? accountOrg;

  get accountPic {
    return getAccountPic(loginProv.account);
  }

  getAccountPic(AddressModel? account) {
    if (STR(account?.image).isNotEmpty) {
      return showImage(account!.image!, Size(PROFILE_RADIUS.r, PROFILE_RADIUS.r));
    }
    return SvgPicture.asset('assets/svg/icon_profile_00.svg',
        width: PROFILE_RADIUS.r, height: PROFILE_RADIUS.r.r,
        colorFilter: ColorFilter.mode(GRAY_20, BlendMode.srcIn));
  }

  getPageTitle() {
    final pageIndex = loginProv.mainPageIndex;
    return Center(
      child: pageIndex == 0 ?
      Text(TR('Market')) :
      FittedBox(
        fit: BoxFit.fitWidth,
        child: InkWell(
          onTap: () {
            if (loginProv.isShowMask) {
              hideProfileSelectBox();
            } else {
              showProfileSelectBox(
                context,
                onSelect: _selectAccount,
                onAdd: _accountAdd);
            }
          },
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            height: 35.h,
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loginProv.isShowMask)...[
                  Text(TR('계정 선택')),
                ],
                if (!loginProv.isShowMask)...[
                  Text(loginProv.accountName),
                  Icon(Icons.arrow_drop_down_sharp),
                ]
              ],
            )
          )
        ),
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////

  mainDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: WHITE,
      surfaceTintColor: WHITE,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: context.pop,
                    child: Icon(Icons.close, size: 30,
                        color: GRAY_30, weight: 1),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10.r, 30.r, 0, 10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loginProv.isLogin)...[
                    Text(loginProv.accountName, style: typo18bold),
                    if (loginProv.accountSubtitle.isNotEmpty)...[
                      SizedBox(height: 5.h),
                      Text(loginProv.accountSubtitle,
                          style: typo14normal, maxLines: 1,
                          overflow: TextOverflow.fade),
                    ],
                    SizedBox(height: 5.h),
                    Text(loginProv.accountMail, style: typo14semibold),
                  ],
                  if (!loginProv.isLogin)...[
                    InkWell(
                      onTap: () {
                        context.pop();
                        Navigator.of(context).push(
                            createAniRoute(LoginScreen(isAppStart: false)));
                      },
                      child: Container(
                        height: 35,
                        margin: EdgeInsets.only(top: 40),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: GRAY_50),
                        ),
                        child: Text(TR('로그인하기'), style: typo12bold),
                      ),
                    )
                  ]
                ],
              ),
            ),
            Divider(),
            ...DrawerActionType.values.map((e) =>
              _mainDrawerItem(context, e)).toList(),
            Spacer(),
            ListTile(
              title: Text(
                TR('사업자명: 주식회사 엑시노\n'
                    '대표이사: 이지민\n'
                    '등록번호: 644-86-03081\n'
                    '대표번호: 070-4304-5778\n'
                    '서울시 서초구 서운로 13 126-나94호'),
                style: typo12semibold100.copyWith(color: GRAY_40),
              ),
              onTap: context.pop,
            ),
          ],
        ),
      )
    );
  }

  _mainDrawerItem(BuildContext context, DrawerActionType type) {
    if (type.title == '-') {
      return Divider();
    }
    if ((type == DrawerActionType.language && !IS_LANGUAGE_ON) ||
        (type == DrawerActionType.identity && !IS_IDENTITY_ON)) {
      return Container();
    }
    var showTitle = TR(type.title);
    if (type == DrawerActionType.version) {
      showTitle += ' ${loginProv.appVersion}';
    }
    var isTest = type.title.contains('(test)');
    var isEnable = (type == DrawerActionType.terms ||
        type == DrawerActionType.privacy ||
        type == DrawerActionType.version ||
        type == DrawerActionType.language
        ) || loginProv.isLogin;
    return InkWell(
      onTap: () {
        LOG('--> _mainDrawerItem: $type / $isEnable');
        if (!isEnable) return;
        context.pop();
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          switch (type) {
            case DrawerActionType.my:
              if (loginProv.isLogin) {
                Navigator.of(context).push(
                  createAniRoute(ProfileMyInfoScreen()));
              } else {
                Navigator.of(context).push(
                  createAniRoute(LoginScreen(isAppStart: false)));
              }
              break;
            case DrawerActionType.history:
              if (loginProv.isLogin) {
                Navigator.of(context).push(
                  createAniRoute(PaymentListScreen()));
              } else {
                Navigator.of(context).push(
                  createAniRoute(LoginScreen(isAppStart: false)));
              }
              break;
            case DrawerActionType.terms:
              Navigator.of(context).push(
                createAniRoute(WebviewScreen(
                  title: TR('이용약관'),
                  url: '$API_HOST/terms/1')));
              break;
            case DrawerActionType.privacy:
              Navigator.of(context).push(
                createAniRoute(WebviewScreen(
                  title: TR('개인정보처리 방침'),
                  url: '$API_HOST/terms/2')));
              break;
            case DrawerActionType.version:
              isUpdateCheckDone = false;
              checkAppUpdate(context, isForceCheck: true);
              break;
            case DrawerActionType.language:
              Navigator.of(context).push(
                createAniRoute(SettingsLanguageScreen()));
              break;
            case DrawerActionType.identity:
              Navigator.of(context).push(
                createAniRoute(ProfileIdentityScreen()));
              break;
            case DrawerActionType.logout:
              if (loginProv.isLogin) {
                loginProv.logout().then((_) {
                  marketProv.initRepo();
                  loginProv.setMainPageIndex(0);
                  showToast(TR('로그아웃 완료'));
                });
              }
              break;
            // case DrawerActionType.iCloudUp:
            //   showSelectDialog(context, TR('Cloud를 선택해 주세요.'),
            //       ['Google Drive','Apple iCloud']).then((result) {
            //     switch (result) {
            //       case 0:
            //         GoogleService.uploadKeyToDrive(
            //           context, loginProv.userEmail, 'exportText test').then((_) {
            //           loginProv.enableLockScreen();
            //         });
            //         break;
            //       case 1:
            //         ICloudService.uploadKeyToDrive(
            //           context, loginProv.userEmail, 'exportText test', () {
            //           LOG('----> up complete');
            //         }, (err) {
            //           LOG('----> up error : $err');
            //         });
            //         break;
            //     }
            //   });
            //   break;
            // case DrawerActionType.iCloudDown:
            //   ICloudService.downloadKeyFromDrive(
            //     context, loginProv.userEmail, (result) {
            //     LOG('----> down complete : $result');
            //   }, (err) {
            //     LOG('----> down error : $err');
            //   });
            //   break;
          // case DrawerActionType.withdrawal:
          //   if (loginProv.isLogin) {
          //     loginProv.logout().then((_) {
          //       loginProv.setMainPageIndex(0);
          //       showToast(TR('회원탈퇴 완료'));
          //     });
          //   }
          //   break;
          // case DrawerActionType.test_delete:
          //   UserHelper().clearAllUser().then((_) {
          //     loginProv.logout().then((_) {
          //       loginProv.setMainPageIndex(0);
          //       showToast(TR('로컬정보 삭제 완료'));
          //     });
          //   });
          //   break;
            default:
              break;
          }
        });
      },
      child: Container(
        height: 40.h,
        color: WHITE,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 15),
        child: Text(showTitle,
          style: typo16bold.copyWith(
            color: isTest ? Colors.blueAccent : isEnable ? GRAY_80 : GRAY_20)),
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////

  showProfile() {
    if (loginProv.userInfo != null) {
      return Column(
        children: [
          _profileImage(padding: EdgeInsets.only(bottom: 20)),
          _profileDescription(padding: EdgeInsets.only(bottom: 30)),
          _profileButtonBox(),
        ],
      );
    } else {
      return Center(
        child: Text(TR('프로필 정보가없습니다.')),
      );
    }
  }

  hideProfileSelectBox() {
    loginProv.setMaskStatus(false);
      ScaffoldMessenger.of(context!).hideCurrentMaterialBanner();
  }

  showProfileSelectBox(BuildContext profileContext,
    {Function(AddressModel)? onSelect, Function()? onAdd}) {
    if (loginProv.isShowMask || loginProv.userInfo == null) return false;
    loginProv.setMaskStatus(true);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 10,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        content: Container(
          constraints: BoxConstraints(
            maxHeight: 500,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
            children: [
              ...loginProv.userInfo!.addressList!.map((e) =>
                  _profileItem(e, onSelect)).toList(),
              SizedBox(height: 10),
              Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GRAY_50, width: 1),
                  color: Colors.white
                ),
                child: InkWell(
                  onTap: () {
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
                        Text(TR('계정 추가'), style: typo14bold),
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

  ////////////////////////////////////////////////////////////////////////

  myInfoEditItem(String title, List<List> items,
    {Function(int)? onEdit, Function(bool)? onToggle}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TR(title), style: typo16bold),
          ...items.map((e) => _myInfoItem(e, () {
            if (onEdit != null) onEdit(items.indexOf(e));
          }, onToggle)),
        ],
      ),
    );
  }

  _myInfoItem(List item, Function()? onEdit, Function(bool)? onToggle) {
    var _isChecked = STR(item[1]) == 'on';
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(STR(item[0]),
                      style: typo16regular, maxLines: 2),
                  if (item.length > 2 && STR(item[2]).isNotEmpty)...[
                    Text(STR(item[2]), style: typo12normal.copyWith(color: SECONDARY_90)),
                  ],
                ],
              )
            ),
            if (STR(item[1]).isNotEmpty)...[
              if (STR(item[1]) != 'on' && STR(item[1]) != 'off')
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: darkBorderButtonStyle,
                    child: Text(TR(STR(item[1])),
                        style: typo14semibold),
                  ),
                ),
              if (STR(item[1]) == 'on' || STR(item[1]) == 'off')
                CupertinoSwitch(
                  value: _isChecked,
                  activeColor: CupertinoColors.activeBlue,
                  onChanged: (bool? value) {
                    _isChecked = value ?? false;
                    if (onToggle != null) onToggle(_isChecked);
                  },
                ),
            ],
          ],
        ),
      );
    });
  }

  ////////////////////////////////////////////////////////////////////////

  _profileItem(AddressModel account, Function(AddressModel)? onSelect) {
    final iconSize = 32.0.r;
    final color = account.address ==
        loginProv.selectAccount?.address ? PRIMARY_100 : GRAY_50;
    return InkWell(
      onTap: () {
        if (onSelect != null) onSelect(account);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize),
                child: getAccountPic(account),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(STR(account.accountName),
                    style: typo16semibold.copyWith(color: color)),
                  if (IS_DEV_MODE)...[
                    Text(ADDR(account.address),
                      style: typo11normal.copyWith(color: GRAY_40))
                  ],
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  _profileImage({EdgeInsets? padding, var isShowButton = true}) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width:  PROFILE_RADIUS.r + 35,
            height: PROFILE_RADIUS.r,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width:  PROFILE_RADIUS.r,
                    height: PROFILE_RADIUS.r,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(PROFILE_RADIUS.r),
                        child: accountPic,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      if (!isShowButton) return;
                      loginProv.disableLockScreen();
                      showImagePicker().then((data) {
                        if (data != null) {
                          JSON imageInfo = {
                            'id': loginProv.walletAddress,
                            'data': data,
                          };
                          showLoadingDialog(context,
                            TR('이미지 업로드 중입니다...'));
                          fireProv.uploadProfileImage(imageInfo).then((picUrl) async {
                            LOG('---> uploadProfileImage result : $picUrl');
                            if (STR(picUrl).isNotEmpty) {
                              _backupAccount();
                              loginProv.selectAccount!.image = picUrl;
                              await _setAccountInfo();
                            }
                            loginProv.enableLockScreen();
                            hideLoadingDialog();
                          });
                        } else {
                          loginProv.enableLockScreen();
                        }
                      });
                    },
                    child: isShowButton ? Container(
                      child: Icon(Icons.photo_camera, color: GRAY_30),
                    ) : null,
                  )
                )
              ],
            ),
          )
          // SizedBox(width: 20),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _profileFollowBox(TR('팔로워'), STR(account?.follower ?? '0')),
          //       _profileFollowBox(TR('팔로잉'), STR(account?.following ?? '0')),
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
    if (STR(loginProv.account?.description).isNotEmpty) {
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
    return Container(
      height: 20.h,
    );
  }

  _profileButtonBox({EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              color: GRAY_20,
              textStyle: typo14semibold,
              isSmallButton: true,
              onTap: () {
                showEditDescription();
              },
              text: TR('프로필 편집'),
            )
          ),
          SizedBox(width: 10),
          Expanded(
            child: PrimaryButton(
              color: GRAY_20,
              textStyle: typo14semibold,
              isSmallButton: true,
              onTap: () {
                Navigator.of(context).push(
                  createAniRoute(UserItemListScreen()));
              },
              text: TR('보유 상품'),
            )
          ),
        ],
      ),
    );
  }

  _selectAccount(AddressModel select) {
    if (loginProv.accountAddress == select.address) return false;
    LOG('---> _selectAccount : ${select.toJson()}');
    loginProv.disableLockScreen();
    hideProfileSelectBox();
    if (loginProv.userPassReady) {
      _changeAccount(select);
    } else {
      Navigator.of(context).push(
          createAniRoute(OpenPassScreen())).then((passOrg) {
        if (STR(passOrg).isNotEmpty) {
          loginProv.setUserPass(passOrg);
          _changeAccount(select);
        }
      });
    }
    return true;
  }

  _changeAccount(AddressModel select) {
    loginProv.changeAccount(select).then((result) {
      loginProv.enableLockScreen();
      if (result) {
        showToast(TR('계정 변경 성공'));
      } else {
        showToast(TR('계정 변경 실패'));
      }
    });
    return true;
  }

  _accountAdd() {
    hideProfileSelectBox();
    showInputDialog(context,
      TR('계정 추가'),
      defaultText: IS_DEV_MODE ? EX_TEST_ACCCOUNT_00_1 : '',
      hintText: TR('계정명을 입력해 주세요.')).then((newNickId) {
      LOG('---> account add name : $newNickId');
      if (STR(newNickId).isNotEmpty) {
        // nickId duplicate check..
        loginProv.checkNickId(nickId: newNickId!,
          onError: (type) => showToast(TR(type.errorText))).
          then((check) {
            if (check == true) {
              // pass check..
              if (loginProv.userPassReady) {
                _startAccountAdd(newNickId);
              } else {
                Navigator.of(context).push(
                    createAniRoute(OpenPassScreen())).then((passOrg) {
                  if (STR(passOrg).isNotEmpty) {
                    loginProv.setUserPass(passOrg);
                    _startAccountAdd(newNickId);
                  }
                });
              }
            }
        });
      }
    });
  }

  _startAccountAdd(String newNickId) {
    loginProv.addNewAccount(loginProv.userPass, newNickId).then((result) {
      LOG('---> account add result : $result');
      showToast(result ? "계정추가 성공" : "계정추가 실패");
    });
  }

  showEditAccountName() {
    showInputDialog(context,
        TR('ID(닉네임) 변경'),
        defaultText: STR(loginProv.selectAccount?.accountName),
        hintText: TR('변경할 닉네임 입력해 주세요.'),
        minLength: NICK_LENGTH_MIN,
        maxLength: NICK_LENGTH_MAX,
    ).then((text) {
      if (STR(text).isNotEmpty) {
        _backupAccount();
        var org = loginProv.selectAccount!.accountName;
        loginProv.selectAccount!.accountName = text;
        _setAccountName().then((result) {
          LOG('--> _setAccountName : $result');
          if (result == false) {
            loginProv.selectAccount!.accountName = org;
          }
        });
      }
    });
  }

  showEditSubTitle() {
    showInputDialog(context,
        TR('사용자 이름 변경'),
        defaultText: _getEditSubTitle,
        hintText: TR('변경할 이름을 입력해 주세요.'),
        textInputType: TextInputType.multiline,
        textAlign: TextAlign.start,
        maxLine: 1,
        maxLength: SUBTITLE_LENGTH_MAX,
    ).then((text) {
      if (STR(text).isNotEmpty) {
        _backupAccount();
        loginProv.selectAccount!.subTitle = text;
        _setAccountInfo();
      }
    });
  }

  showEditDescription() {
    showInputDialog(context,
        TR('프로필 변경'),
        defaultText: STR(loginProv.selectAccount?.description),
        hintText: TR('변경할 프로필 내용을 입력해 주세요.'),
        textInputType: TextInputType.multiline,
        textAlign: TextAlign.start,
        maxLine: 5,
        maxLength: PROFILE_LENGTH_MAX,
    ).then((text) {
      if (STR(text).isNotEmpty) {
        _backupAccount();
        loginProv.selectAccount!.description = text;
        _setAccountInfo();
      }
    });
  }

  Future<Uint8List?> showImagePicker() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    LOG('---> showImagePicker : $pickImage');
    if (pickImage != null) {
      var imageUrl  = await showProfileImageCropper(pickImage.path);
      LOG('--> showImagePicker imageUrl : $imageUrl');
      if (imageUrl != null) {
        var dataOrg = await _readFileByte(imageUrl);
        if (dataOrg != null) {
          return await resizeImage(
              dataOrg.buffer.asUint8List(), 256) as Uint8List;
        }
      }
    }
    return null;
  }

  Future resizeImage(Uint8List data, double maxSize) async {
    Uint8List? resizedData = data;
    try {
      var img = IMG.decodeImage(data);
      bool isResized = false;
      if (img != null) {
        var nWidth  = img.width.toDouble();
        var nHeight = img.height.toDouble();
        if (nWidth > nHeight) {
          if (nWidth > maxSize) {
            nWidth = maxSize;
            nHeight *= nWidth / img.width;
            isResized = true;
          }
        } else {
          if (nHeight > maxSize) {
            nHeight = maxSize;
            nWidth *= nHeight / img.height;
            isResized = true;
          }
        }
        if (isResized) {
          LOG('--> resizeImage : ${img.width} x ${img.height} => $nWidth x $nHeight');
          img = IMG.copyResize(img, width: nWidth.toInt(), height: nHeight.toInt());
        }
        resizedData = IMG.encodeJpg(img, quality: 100) as Uint8List?;
        return resizedData;
      }
    } catch (e) {
      LOG('--> resizeImage error : $e');
      return resizedData;
    }
  }

  showProfileImageCropper(String imageFilePath) async {
    var preset = [
      CropAspectRatioPreset.square,
    ];
    return await startImageCropper(
      imageFilePath,
      CropStyle.circle,
      preset,
      CropAspectRatioPreset.square,
      false
    );
  }

  Future<Uint8List?> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = File.fromUri(myUri);
    Uint8List? bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      LOG('--> _readFileByte completed');
    }).catchError((onError) {
      LOG('--> _readFileByte Error : ${onError.toString()}');
    });
    return bytes;
  }

  startImageCropper(
      String imageFilePath,
      CropStyle cropStyle,
      List<CropAspectRatioPreset> preset,
      CropAspectRatioPreset initPreset,
      bool lockAspectRatio) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        cropStyle: cropStyle,
        sourcePath: imageFilePath,
        aspectRatioPresets: preset,
        maxWidth: 1024,
        maxHeight: 1024,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 편집',
            toolbarColor: Colors.white,
            initAspectRatio: initPreset,
            lockAspectRatio: lockAspectRatio),
          IOSUiSettings(
            title: '이미지 편집',
          ),
        ],
      );
      return croppedFile?.path;
    } catch (e) {
      LOG('---> startImageCropper error : $e');
    }
  }

  get _getEditSubTitle {
    var org = STR(loginProv.selectAccount?.subTitle);
    return org.isNotEmpty ? org : IS_DEV_MODE ? EX_TEST_NAME_00 : '';
  }

  _backupAccount() {
    accountOrg = null;
    if (loginProv.selectAccount != null) {
      accountOrg = AddressModel.fromJson(loginProv.selectAccount!.toJson());
    }
  }

  _restoreAccount() {
    if (accountOrg != null) {
      loginProv.setLocalAccountInfo(accountOrg!);
    }
    accountOrg = null;
  }

  _setAccountName() async {
    // 닉네임 중복 체크..
    var result = await loginProv.checkNickDup(loginProv.selectAccount?.accountName);
    if (!result) {
      showToast(TR('중복된 닉네임입니다'));
      showEditAccountName();
      return false;
    }
    // 비번 입력 내역이 없을경우 비번체크..
    var passOrg = loginProv.userPass;
    if (passOrg.isEmpty) {
      passOrg = await Navigator.of(context).push(
        createAniRoute(OpenPassScreen()));
    }
    if (STR(passOrg).isNotEmpty) {
      loginProv.setUserPass(passOrg);
      var result = await loginProv.setAccountName(loginProv.selectAccount!);
      showToast(result == true ? "닉네임 변경 성공" : "닉네임 변경 실패");
      if (result != true) {
        // 변경에 실패했을 경우 원복..
        _restoreAccount();
      }
      return result;
    }
    return false;
  }

  _setAccountInfo() async {
    // 비번 입력 내역이 없을경우 비번체크..
    var passOrg = loginProv.userPass;
    if (passOrg.isEmpty) {
      passOrg = await Navigator.of(context).push(
        createAniRoute(OpenPassScreen()));
    }
    if (STR(passOrg).isNotEmpty) {
      loginProv.setUserPass(passOrg);
      var result = await loginProv.setAccountInfo(loginProv.selectAccount!);
      showToast(result == true ? "내 정보 변경 성공" : "내 정보 변경 실패");
      if (result != true) {
        // 변경에 실패했을 경우 원복..
        _restoreAccount();
      }
      return result;
    }
    return false;
  }
}