import '../../common_package.dart';

class QuantityRow extends StatelessWidget {
  const QuantityRow({
    super.key,
    required this.leftWidget,
    required this.rightWidgetList,
    this.padding = EdgeInsets.zero,
  });

  final Widget leftWidget;
  final List<Widget> rightWidgetList;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftWidget,
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: rightWidgetList,
          )
        ],
      ),
    );
  }
}
