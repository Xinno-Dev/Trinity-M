import '../../common_package.dart';

class StakingWaitingColumn extends StatelessWidget {
  const StakingWaitingColumn({
    super.key,
    required this.title,
    required this.content,
  });

  final String title, content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typo14medium.copyWith(color: GRAY_50),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            content,
            style: typo14regular150,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
