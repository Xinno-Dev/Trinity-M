import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/widget/back_button.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const BasicAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: WHITE,
      leading: CustomBackButton(
        onPressed: context.pop,
      ),
      centerTitle: true,
      title: Text(
        title,
        style: typo18semibold,
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
