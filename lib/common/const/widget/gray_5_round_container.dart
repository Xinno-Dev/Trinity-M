import '../../common_package.dart';

class Gray5RoundContainer extends StatelessWidget {
  const Gray5RoundContainer({
    super.key,
    required this.child,
    this.isNotification = false,
  });

  final Widget child;
  final bool isNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isNotification ? 16.0 : 8.0, horizontal: 16),
      decoration: BoxDecoration(
        color: GRAY_5,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: child,
    );
  }
}
