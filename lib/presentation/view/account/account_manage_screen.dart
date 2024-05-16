import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:auto_size_text_plus/auto_size_text.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/custom_badge.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../domain/model/address_model.dart';
import '../../../presentation/view/authpassword_screen.dart';
import '../../../presentation/view/account/import_privatekey_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/provider/network_provider.dart';

class AccountManageScreen extends ConsumerStatefulWidget {
  const AccountManageScreen({super.key});
  static String get routeName => 'account_manage';
  @override
  ConsumerState<AccountManageScreen> createState() =>
      _AccountManageScreenState();
}

class _AccountManageScreenState extends ConsumerState<AccountManageScreen> {
  String select_Address = '';
  String accountName = '';
  List<AddressModel> addressList = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _refreshIndex() {
    for (var item in addressList) {
      final index = addressList.indexOf(item);
      item.orderIndex = index;
      LOG('---> _refreshIndex : [$index] : ${item.toJson()}');
    }
  }

  Future<void> _getUserInfo() async {
    addressList = [];
    UserHelper userHelper = UserHelper();
    String get_address = await userHelper.get_address();
    String jsonString = await userHelper.get_addressList();
    List<dynamic> decodeJson = json.decode(jsonString);
    for (var jsonObject in decodeJson) {
      AddressModel model = AddressModel.fromJson(jsonObject);
      addressList.add(model);
    }
    setState(() {
      select_Address = get_address;
      _refreshIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    var networkModel = provider.Provider.of<NetworkProvider>(context)
        .networkModel;
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '계정 관리'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            DottedBorder(
              radius: Radius.circular(4),
              dashPattern: [5, 5],
              color: GRAY_20,
              child: Container(
                width: 335.w,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    print('계정 불러오기');
                    context.pushNamed(ImportPrivateKeyScreen.routeName);
                  },
                  child: Text(
                    TR(context, '계정 불러오기'),
                    style: typo16semibold.copyWith(color: GRAY_40),
                  ),
                  style: whiteButtonStyle.copyWith(
                    side: MaterialStateProperty.all(
                      BorderSide(
                        style: BorderStyle.none, // 점선 스타일
                      ),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  )),
              ),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: ReorderableListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      final double animValue = Curves.easeInOut.transform(animation.value);
                      final double elevation = lerpDouble(0, 6, animValue)!;
                      return Material(
                        elevation: elevation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: SECONDARY_20,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          alignment: Alignment.center,
                          child: child,
                        )
                      );
                    },
                    child: child,
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    var item = addressList.removeAt(oldIndex);
                    addressList.insert(newIndex, item);
                    _refreshIndex();
                    final addressListJson = addressList.map((address) => address.toJson()).toList();
                    final addressJsonString = json.encode(addressListJson);
                    UserHelper().setUser(addressList: addressJsonString);
                  });
                },
                children: List<Widget>.from(addressList.map((e) =>
                    _buildListItem(addressList.indexOf(e))).toList()),
              )
            ),
            SizedBox(height: 15.h),
            Container(
              width: 335.w,
              height: 56,
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleCheckDialog(
                          hasTitle: true,
                          titleString: TR(context, '새 계정을 추가하시겠어요?'),
                          infoString: TR(context, '새 계정이 목록에 추가됩니다.'),
                          defaultButtonText: '취소',
                          defaultTapOption: () {
                            context.pop();
                          },
                          hasOptions: true,
                          optionButtonText: '추가하기',
                          onTapOption: () {
                            context.pop();
                            context.pushReplacementNamed(AuthPasswordScreen.routeName,
                                queryParams: {'addKeyPair': 'true'});
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                      TR(context, '계정 추가하기'),
                    style: typo16semibold.copyWith(color: GRAY_70),
                  ),
                  style: popupGrayButtonStyle.copyWith(
                    elevation: MaterialStateProperty.all(0),
                  )),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  _buildListItem(index) {
    return ListTile(
      key: Key('$index'),
      dense: true,
      selected: select_Address == addressList[index].address!,
      selectedColor: GRAY_50,
      selectedTileColor: GRAY_10,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      trailing: ReorderableDragStartListener(index:index,
          child: Icon(Icons.drag_handle, color: GRAY_50,)),   //Wrap it inside drag start event listener
      horizontalTitleGap: 0,
      title: Row(
        children: [
          Text(
            addressList[index].accountName ?? '',
            style: typo16bold.copyWith(color: GRAY_90, height: 1),
          ),
          SizedBox(width: 4.0),
          if (!addressList[index].hasMnemonic!)
            CustomBadge(
              text: TR(context, '불러옴'),
              isSmall: true,
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: AutoSizeText(
          '0x${addressList[index].address}',
          style: typo14regular.copyWith(color: GRAY_50),
          maxLines: 1,
        ),
      ),
      onTap: () {
        log('----> onTap : $index');
        // showLoadingDialog(context, TR(context, '계정 정보를 가져오는 중입니다'));
        UserHelper().setUser(
          publickey: addressList[index].publicKey!,
          key: addressList[index].keyPair!,
          address: addressList[index].address!,
        ).then((value) {
          select_Address = addressList[index].address!;
          ref.read(coinProvider).setWalletAddress(select_Address);
          log('----> select_Address : $select_Address');
          Navigator.of(context).pop();
        });
      },
    );
  }
}
