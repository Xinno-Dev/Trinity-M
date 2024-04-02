import '../../common_package.dart';

class CustomToast extends StatelessWidget {
  const CustomToast({
    super.key,
    required this.msg,
  });

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(47.0),
        color: Color.fromRGBO(16, 18, 35, 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg,
            style: typo14medium.copyWith(color: WHITE),
          ),
        ],
      ),
    );
  }
}
