import '../../common_package.dart';
import 'balance_row.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: typo16medium.copyWith(color: GRAY_70),
          ),
          Spacer(),
          content,
        ],
      ),
    );
  }
}

class DetailQuantityRow extends StatelessWidget {
  DetailQuantityRow({
    super.key,
    required this.title,
    required this.quantity,
    required this.unit,
    this.color,
    this.isBalanceRow = false,
  });

  final String title, quantity, unit;
  final unitStyle = typo16regular.copyWith(color: GRAY_70);
  final Color? color;
  final bool isBalanceRow;

  @override
  Widget build(BuildContext context) {
    return DetailRow(
      title: title,
      content: Row(
        children: [
          if (isBalanceRow)...[
            BalanceRow(
              balance: quantity,
              isShowUnit: false,
              isShowRefresh: false,
              fontSize: 16,
              height: 18,
              textColor: color,
            ),
          ],
            if (!isBalanceRow)...[
            Text(
              quantity,
              style: typo16medium,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              unit,
              style: unitStyle,
              textAlign: TextAlign.right,
            ),
          ]
        ],
      ),
    );
  }
}

class DetailResizeRow extends StatelessWidget {
  DetailResizeRow({
    super.key,
    required this.title,
    this.content,
    this.titleColor,
  });

  final String title;
  Widget? content;
  Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: typo16medium.copyWith(color: titleColor ?? GRAY_70),
          ),
          if (content != null)...[
            SizedBox(width: 10.w),
            Expanded(child: content!),
          ]
        ],
      ),
    );
  }
}

