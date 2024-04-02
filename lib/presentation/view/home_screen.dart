import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/mainBox.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static String get routeName => 'home';
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String uid = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    uid = await UserHelper().get_uid();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: PRIMARY_20,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  SvgPicture.asset(
                    'assets/svg/logo.svg',
                    fit: BoxFit.fitWidth,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      context.pushNamed(SettingsScreen.routeName);
                    },
                    icon: SvgPicture.asset(
                      'assets/svg/settings.svg',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.r),
                child: Row(
                  children: [
                    Text(
                      '김유스비',
                      style: typo24bold150,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '님 안녕하세요 !',
                      style: typo18semibold.copyWith(color: GRAY_70, height: 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              MainBox(
                title: '사용자 정보',
                subtitle: '사용자 정보를 확인하세요',
                pressed: () {
                  print('사용자 정보');
                },
              ),
              SizedBox(height: 24.h),
              MainBox(
                title: '인증 내역',
                subtitle: 'Mauth를 이용한 인증내역을 확인하세요',
                pressed: () {
                  context.pushNamed(HistoryScreen.routeName);
                  print('인증 내역');
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
