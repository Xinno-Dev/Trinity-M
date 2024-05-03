import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/history_model.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  static String get routeName => 'history';
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String a = '';
  String b = '';
  String c = '';
  String d = '';
  List<History> historyList = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    DateTime dt = DateTime.now();
    a = dt.toString();
    b = dt.minute.toString();
    print(a);
    DateTime dt2 = DateTime.parse('2023-02-21 10:18:34.231209');
    c = dt2.toString();
    d = dt2.minute.toString();
    print(c);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '인증내역'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
          child: Center(
        child: Text(TR(context, '인증 목록')),
      )),
    );
  }
}
