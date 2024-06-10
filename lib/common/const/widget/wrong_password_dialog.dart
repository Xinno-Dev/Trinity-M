import '../../common_package.dart';
import '../utils/languageHelper.dart';
import 'SimpleCheckDialog.dart';

class WrongPasswordDialog extends StatelessWidget {
  const WrongPasswordDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleCheckDialog(
      hasTitle: true,
      titleString: TR('비밀번호가 일치하지 않습니다'),
      infoString: TR('비밀번호를 다시 입력해 주세요.'),
      defaultButtonText: TR('돌아가기'),
    );
  }
}