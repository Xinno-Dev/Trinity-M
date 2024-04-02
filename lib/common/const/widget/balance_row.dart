import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common_package.dart';

class BalanceRow extends StatelessWidget {
  BalanceRow({
    super.key,
    required this.balance,
    this.tokenUnit,
    this.onTapRefreshButton,
    this.isShowRefresh = false,
    this.isShowUnit = true,
    this.isOnExplorer = false,
    this.fontSize = 18,
    this.height = 30,
    this.decimalMinSize = 2,
    this.decimalSize = DECIMAL_PLACES,
    this.textColor,
    this.onExplorer,
  });

  final String? balance;
  final String? tokenUnit;
  final bool isShowUnit;
  final bool isShowRefresh;
  final bool isOnExplorer;

  double fontSize;
  double height;
  Color? textColor;
  int decimalSize;
  int decimalMinSize;

  final void Function()? onTapRefreshButton;
  final void Function()? onExplorer;

  get integer {
    if (balance == null) return '0';
    if (balance!.contains('.')) {
      return balance!.split('.').first;
    }
    return balance;
  }

  get decimal {
    var result = '';
    if (balance == null) return result;
    if (balance!.contains('.')) {
      String value = balance!.split('.').last;
      for (var i=value.length-1; i>=0; i--) {
        if (result.isNotEmpty || value[i] != '0') {
          result = value[i] + result;
        }
      }
    }
    // var tmp = result;
    // return '0' * decimalMinSize;
    if (result.isEmpty) {
      result = '';
      for (var i=0; i<decimalMinSize; i++) {
        result += '0';
      }
    }
    // LOG('--> decimal : $balance => $result / $tmp');
    return result;
  }

  get decimal1 {
    var result = '';
    for(var i=0; i<decimal.length; i++) {
      var chr = decimal[i];
      if (chr == '0') {
        result += chr;
      } else {
        break;
      }
    }
    return result;
  }

  get decimal2 {
    return int.parse(decimal).toString();
  }

  @override
  Widget build(BuildContext context) {
    // print('---> BalanceRow : $balance => $integer / $decimal');
    if (balance != null) {
      if (fontSize >= 24 && balance!.length > 24) {
        fontSize *= 0.65;
      } else if (fontSize >= 24 && balance!.length > 18) {
        fontSize *= 0.85;
      }
    }
    return Container(
      height: height.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onExplorer,
            child: Container(
              decoration: (isOnExplorer && onExplorer != null) ? BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ) : null,
              child: Row(
                children: [
                  // if (decimalSize <= 8)
                  Text(
                    CommaIntText(integer) + (decimal.isNotEmpty ? '.' : ''),
                    // integer + (decimal.isNotEmpty ? '.' : ''),
                    style: typo18semibold.copyWith(
                        color: textColor ?? GRAY_90, fontSize: fontSize),
                  ),
                  Text(
                    decimal,
                    style: typo18regular.copyWith(
                        color: textColor ?? GRAY_60, fontSize: fontSize),
                  ),
                  if (isShowUnit)...[
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      tokenUnit ?? 'RIGO',
                      style: typo18semibold.copyWith(fontSize: fontSize),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isShowRefresh)...[
            SizedBox(
              width: 4.w,
            ),
            GestureDetector(
              child: SvgPicture.asset('assets/svg/icon_refresh.svg'),
              onTap: onTapRefreshButton,
            )
          ]
        ],
      ),
    );
  }
}
