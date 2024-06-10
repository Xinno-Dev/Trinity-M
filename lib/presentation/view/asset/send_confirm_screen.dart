import 'package:auto_size_text_plus/auto_size_text.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../domain/model/rpc/staking_type.dart';
import '../../../../presentation/view/sign_password_screen.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/balance_row.dart';
import '../../../common/const/widget/color_title_column.dart';
import '../../../common/const/widget/quantity_row.dart';
import '../../../common/const/widget/title_with_image.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../domain/model/rpc/delegateInfo.dart';

class SendConfirmScreen extends StatelessWidget {
  const SendConfirmScreen({
    super.key,
    required this.receivedAddress,
    required this.sendAmount,
    required this.coin,
    required this.fee,
    required this.totalAmount,
    required this.networkName,
    required this.decimal,
  });

  final String receivedAddress;
  final String sendAmount;
  final String totalAmount;
  final String fee;
  final String coin;
  final String networkName;
  final int decimal;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              Column(
                children: [
                  Center(
                    child: Text(
                      TR('아래 정보로 전송할까요?'),
                      style: typo18semibold,
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TR('보내는 주소'),
                        style: typo16semibold,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        receivedAddress,
                        style: typo16regular150,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ColorTitleColumn(
                    titleColor: GRAY_10,
                    titleWidget: Row(
                      children: [
                        TitleWithImage(
                            title: networkName,
                            titleStyle: typo14medium),
                        Spacer(),
                        Text(
                          coin,
                          style: typo16semibold,
                        ),
                      ],
                    ),
                    bodyWidgetPadding: EdgeInsets.symmetric(horizontal: 16),
                    bodyWidget: Column(
                      children: [
                        QuantityRow(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          leftWidget: Text(
                            TR('총 수량'),
                            style: typo16semibold,
                          ),
                          rightWidgetList: [
                            // SizedBox(
                            //   height: 8,
                            // ),
                            // Text(
                            //   '\$0.00',
                            //   style: typo14regular.copyWith(color: GRAY_50),
                            // ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              TR('총 수량'),
                              style: typo16semibold.copyWith(
                                color: Color.fromRGBO(119, 121, 134, 1),
                              ),
                            ),
                            Spacer(),
                            BalanceRow(
                              balance: totalAmount,
                              tokenUnit: coin,
                              decimalSize: 18,
                              isShowRefresh: false,
                              fontSize: 24,
                              textColor: PRIMARY_90,
                            )
                            // Expanded(
                            //   child: AutoSizeText(
                            //     CommaText(totalAmount, decimal),
                            //     maxLines: 1,
                            //     textAlign: TextAlign.end,
                            //     style: typo18semibold.copyWith(
                            //       color: PRIMARY_90,
                            //     ),
                            //   ),
                            // ),
                            // Row(
                            //   children: [
                            //     SizedBox(
                            //       width: 4,
                            //     ),
                            //     Text(
                            //       coin,
                            //       style: typo16regular,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        Divider(),
                        QuantityRow(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          leftWidget: Text(
                            TR('예상 수수료'),
                            style: typo14medium.copyWith(color: GRAY_50),
                          ),
                          rightWidgetList: [
                            BalanceRow(
                              balance: fee,
                              tokenUnit: coin,
                              decimalSize: 18,
                              isShowRefresh: false,
                              fontSize: 16,
                            )
                            // Row(
                            //   children: [
                            //     Text(
                            //       fee,
                            //       style: typo14medium.copyWith(color: GRAY_70),
                            //     ),
                            //     SizedBox(
                            //       width: 4,
                            //     ),
                            //     Text(
                            //       'RIGO',
                            //       style: typo16regular.copyWith(color: GRAY_70),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 8,
                            // ),
                            // Text(
                            //   '\$0.00',
                            //   style: typo14regular.copyWith(color: GRAY_50),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56.0,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              TR('취소'),
                              style: typo16semibold.copyWith(color: PRIMARY_90),
                            ),
                            style: whiteButtonStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 56.0,
                          child: TextButton(
                            onPressed: () {
                              //TODO: - 패스워드 입력 후 비밀키 복호화 한 다음 전자서명 해서 과정 필요.
                              //사용자가 입력한 주소에서 0x 가 있을경우 제외 추후 어느과정에선가 변경 필요.
                              var toAddress = '';
                              if (receivedAddress.substring(0, 2) == '0x') {
                                toAddress = receivedAddress.substring(
                                    2, receivedAddress.length);
                                print('toAddress:$toAddress');
                              } else {
                                toAddress = receivedAddress;
                              }

                              provider.Provider.of<StakesData>(context,
                                      listen: false)
                                  .updateStakingType(
                                  coin.toLowerCase() == 'rigo' ?
                                  StakingType.transfer : StakingType.contract);

                              provider.Provider.of<StakesData>(context,
                                      listen: false)
                                  .updateStakes(
                                      Stakes(to: toAddress, power: sendAmount));

                              context.pushNamed(SignPasswordScreen.routeName,
                                  queryParams: {
                                    'receivedAddress': toAddress,
                                    'sendAmount': sendAmount
                                  });
                              //보낼 주소와 amount 전달받았고.
                              // context.goNamed(SendCompletedScreen.routeName);
                            },
                            child: Text(
                              TR('전송'),
                              style: typo16bold.copyWith(color: WHITE),
                            ),
                            style: primaryButtonStyle,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
