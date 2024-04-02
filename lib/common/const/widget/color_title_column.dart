import '../../common_package.dart';

class ColorTitleColumn extends StatelessWidget {
  const ColorTitleColumn({
    super.key,
    required this.titleWidget,
    required this.bodyWidget,
    required this.titleColor,
    this.bodyWidgetPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final Widget titleWidget, bodyWidget;
  final Color titleColor;
  final EdgeInsetsGeometry bodyWidgetPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: titleColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: titleWidget,
        ),
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(8),
          ),
          child: Container(
            color: GRAY_20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                  margin: EdgeInsets.only(left: 1, bottom: 1, right: 1),
                  child: Padding(
                    padding: bodyWidgetPadding,
                    child: bodyWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
