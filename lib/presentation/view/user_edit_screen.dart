
import '../../../common/common_package.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/dartapi/lib/trx_pb.pb.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/const/constants.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/const/widget/custom_text_edit.dart';
import '../../common/provider/stakes_data.dart';
import '../../domain/model/rpc/delegateInfo.dart';
import '../../domain/model/rpc/staking_type.dart';
import 'sign_password_screen.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  UserEditScreen(this.walletAddress, this.accountName);
  static String get routeName => 'user_edit';

  String walletAddress;
  String accountName;

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  late String newAccountName = widget.accountName;

  get isButtonEnable {
    return newAccountName.isNotEmpty && newAccountName != widget.accountName;
  }

  @override
  void initState() {
    super.initState();
    TrxProto();
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
          TR('계정 이름 변경'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextEdit(context, '계정 이름', desc: widget.accountName,
                onChanged: (value) {
                  if (widget.accountName != value) {
                    newAccountName = value;
                  }
                }),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: TR('취소'),
                      color: GRAY_10,
                      textStyle: typo16medium,
                      isBorderShow: true,
                      isSmallButton: true,
                    )
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: PrimaryButton(
                      text: TR('변경'),
                      textStyle: typo16medium.copyWith(color: WHITE),
                      isSmallButton: true,
                      onTap: () {
                        if (IS_ACCOUNT_NAME_SETDOC) {
                          provider.Provider.of<StakesData>(
                              context, listen: false)
                              .updateStakingType(StakingType.setDoc);
                          provider.Provider.of<StakesData>(
                              context, listen: false)
                              .updateStakes(Stakes(
                              payloadName: newAccountName,
                              payloadUrl: ''
                          ));
                          Navigator.of(context).push(
                              createAniRoute(SignPasswordScreen(
                                receivedAddress: widget.walletAddress,
                                sendAmount: '0',
                              ))).then((result) {
                            LOG('--> SignPasswordScreen result : $result');
                            if (BOL(result)) {
                              Navigator.of(context).pop(newAccountName);
                            }
                          });
                        } else {
                          Navigator.of(context).pop(newAccountName);
                        }
                      },
                    )
                  )
                ],
              )
            ]
          )
        )
      )
    );
  }
}
