import '../../../common/const/widget/network_error_screen.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../presentation/view/staking/staking_screen.dart';
import '../../../presentation/view/staking/validators_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../domain/model/rpc/staking_type.dart';

class StakingMainScreen extends ConsumerStatefulWidget {
  const StakingMainScreen({Key? key}) : super(key: key);
  static String get routeName => 'staking_main';

  @override
  ConsumerState<StakingMainScreen> createState() => _StakingMainScreenState();
}

class _StakingMainScreenState extends ConsumerState<StakingMainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = ref.watch(errorProvider);

    return SafeArea(
      top: false,
      child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WHITE,
          title: Text(
            TR(context, '스테이킹'),
            style: typo18semibold,
          ),
          centerTitle: false,
          shadowColor: Color(0x19AEAEAE),
          bottom: TabBar(
            // padding: EdgeInsets.only(top: 10.0),
            labelColor: GRAY_90,
            labelStyle: typo16semibold,
            unselectedLabelColor: GRAY_40,
            indicatorColor: GRAY_90,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 69.5),
            tabs: [
              // Tab(
              //   text: '스테이킹',
              // ),
              Tab(
                text: TR(context, '위임'),
              ),
              Tab(
                text: TR(context, '검증인'),
              ),
            ],
          ),
        ),
        body: isError
            ? NetworkErrorScreen()
            : Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        // StakingScreen(stakingType: StakingType.staking),
                        StakingScreen(stakingType: StakingType.delegate),
                        ValidatorsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
        ),
      )
    );
  }
}
