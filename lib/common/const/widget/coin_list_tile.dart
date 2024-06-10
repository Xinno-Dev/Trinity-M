import 'dart:developer';

import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../domain/model/coin_model.dart';
import '../../../presentation/view/asset/coin_detail_screen.dart';

import '../../common_package.dart';
import '../../style/colors.dart';
import '../../style/textStyle.dart';
import '../utils/convertHelper.dart';
import '../utils/languageHelper.dart';
import 'balance_row.dart';
import 'line_button.dart';

class CoinListItem extends StatelessWidget {
  const CoinListItem(
    this.coin,
    {
      super.key,
      this.networkName,
      this.isSelected = false,
      this.isEditMode = false,
      this.isCanHide  = true,
      this.isShowBalance = true,
      this.height = 80.0,
      this.onSelected,
      this.onDelete,
    }
  );

  final CoinModel coin;
  final String? networkName;
  final bool isSelected;
  final bool isEditMode;
  final bool isCanHide;
  final bool isShowBalance;
  final double height;
  final Function(String)? onSelected;
  final Function(String)? onDelete;

  get isHideReady {
    return isCanHide && isEditMode && coin.isToken;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (!isEditMode) {
          if (onSelected != null) onSelected!(coin.code);
        } else {
          if (isHideReady && onDelete != null) onDelete!(coin.code);
        }
      },
      tileColor: isSelected ? SELECT_90 : Colors.transparent,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      horizontalTitleGap: 0,
      // shape: Border(
      //     bottom: BorderSide(width: 1, color: GRAY_20)
      // ),
      leading: Opacity(
        opacity: coin.isHide ? 0.35 : 1,
        child: getCoinIcon(coin, size: 40.r),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Opacity(
              opacity: coin.isHide ? 0.35 : 1,
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.symbol,
                        style: typo16bold.copyWith(color: GRAY_80),
                      ),
                      if (STR(networkName).isNotEmpty)...[
                        SizedBox(height: 5.h),
                        Text(networkName ?? '', style: typo12regular),
                      ]
                    ],
                  ),
                  if (isShowBalance)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: SizedBox(height: 1)),
                        BalanceRow(
                          balance: coin.formattedBalance,
                          isShowUnit: false,
                          isShowRefresh: false,
                          decimalSize: coin.decimalNum,
                        ),
                        // SizedBox(width: 5.w),
                        // Text(
                        //   coin.symbol,
                        //   style: typo14bold,
                        // )
                      ],
                    )
                  ),
                ]
              ),
            ) ,
          ),

          // Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       Text(
          //         coin.name,
          //         style: typo14bold.copyWith(color: GRAY_50),
          //       ),
          //       Row(
          //         children: [
          //           Expanded(child: SizedBox(height: 1)),
          //           BalanceRow(
          //             balance: coin.formattedBalance,
          //             isShowUnit: true,
          //             isShowRefresh: false,
          //             decimalSize: coin.decimalNum,
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         coin.name,
          //         style: typo18semibold,
          //       ),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             coin.symbol,
          //             style: typo14regular.copyWith(color: GRAY_50),
          //           ),
          //           BalanceRow(
          //             balance: coin.formattedBalance,
          //             isShowUnit: false,
          //             isShowRefresh: false,
          //             decimalSize: coin.decimalNum,
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
          if (isHideReady)...[
            SizedBox(width: 5.w),
            // SvgPicture.asset(
            //   'assets/svg/icon_hide_${coin.isHide ? '01' : '00'}.svg',
            //   height: 20.r, fit: BoxFit.fitHeight
            // ),
            LineButton(
              text: TR(coin.isHide ? '보이기' : '감추기'),
              color: GRAY_80,
              textColor: GRAY_80,
              isSmallButton: true,
              padding: 10.w,
              onTap: () async {
                if (onDelete == null) return;
                onDelete!(coin.code);
              }
            )
          ]
        ],
      ),
    );
  }
}

class CoinListTile extends StatelessWidget {
  const CoinListTile({
    super.key,
    required this.imageAssetName,
    required this.coinName,
    required this.coinUnit,
    required this.balance,
    this.isSelected = false,
    this.onSelected,
  });

  final String imageAssetName, coinUnit;
  final String coinName, balance;
  final bool isSelected;
  final Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
    log('---> isSelected [$coinName]: $isSelected');
    return ListTile(
      onTap: () {
        if (onSelected != null) onSelected!(coinName);
        // context.pushNamed(CoinDetailScreen.routeName,
        //     queryParams: {'coinName': coinName});
      },
      tileColor: isSelected ? SECONDARY_20 : Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      horizontalTitleGap: 0,
      shape: Border(
          bottom: BorderSide(width: 0.5, color: GRAY_10)
      ),
      leading: imageAssetName.contains('.svg') ?
      SvgPicture.asset(
        imageAssetName,
        height: 28.r,
      ) :
      Image.asset(
        imageAssetName,
        height: 28.r,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            coinName,
            style: typo18semibold,
          ),
          BalanceRow(
            balance: balance,
            isShowUnit: false,
            isShowRefresh: false,
          ),
          // Row(
          //   children: [
          //     Text(
          //       stringQuantity,
          //       style: typo18semibold,
          //     ),
          //     SizedBox(
          //       width: 4.w,
          //     ),
          //     Text(
          //       coinUnit,
          //       style: typo16regular,
          //     ),
          //   ],
          // ),
        ],
      ),
      // subtitle: Text(
      //   '\$$dollar',
      //   style: typo14medium.copyWith(
      //     color: GRAY_50,
      //     fontWeight: FontWeight.w400,
      //   ),
      // ),
      // trailing: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     SvgPicture.asset('assets/svg/arrow.svg'),
      //   ],
      // ),
    );
  }
}
