import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';

import '../../common_package.dart';
import '../../style/outlineInputBorder.dart';
import '../utils/languageHelper.dart';

enum ColumnType { staking, unstaking, delegate, undelegate }

class QuantityColumn extends StatelessWidget {
  const QuantityColumn({
    super.key,
    required this.stakingType,
  });

  final stakingType;

  get helpText {
    if (stakingType == ColumnType.staking) return '코인 보유량';
    if (stakingType == ColumnType.unstaking) return '스테이킹 보유량';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수량',
          style: typo14semibold,
        ),
        SizedBox(
          height: 8,
        ),
        QuantityTextField(),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Text(
              TR(helpText),
              style: typo14medium.copyWith(color: GRAY_50),
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              '24,000,500',
              style: typo14medium,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              'RIGO',
              style: typo14regular,
            ),
          ],
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }
}

class QuantityTextField extends StatefulWidget {
  const QuantityTextField({Key? key}) : super(key: key);

  @override
  State<QuantityTextField> createState() => _QuantityTextFieldState();
}

class _QuantityTextFieldState extends State<QuantityTextField> {
  FocusNode quantityTextFocus = FocusNode();
  final _quantityController = TextEditingController();
  bool quantityTextFieldIsEmpty = true;
  bool agree_1 = false;
  bool agree_2 = false;
  String hintText = '00.00';
  String sendAmount = '0.00000000';
  String currentCoinUnit = 'RIGO';

  @override
  void initState() {
    super.initState();
    quantityTextFocus.addListener(() {
      if (quantityTextFocus.hasFocus) {
        hintText = '';
      } else {
        hintText = '00.00';
      }
      //setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: _quantityController,
      focusNode: quantityTextFocus,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: GRAY_20),
        ),
        focusedBorder: grayBorder,
        hintText: hintText,
        hintStyle: typo18semibold.copyWith(color: GRAY_40),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Text(
            currentCoinUnit,
            style: typo16regular,
          ),
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      style: typo18semibold,
      textAlign: TextAlign.end,
      onChanged: (String text) {
        //print(text);
        setState(() {
          if (text == '0.00') {
            text = '';
          }
          quantityTextFieldIsEmpty = text.isEmpty;
          sendAmount = text;
        });
      },
      textInputAction: TextInputAction.done,
      onSubmitted: (String text) {
        quantityTextFocus.unfocus();
      },
      inputFormatters: [
        CurrencyInputFormatter(
          trailingSymbol: '',
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: 8,
        )
      ],
    );
  }
}
