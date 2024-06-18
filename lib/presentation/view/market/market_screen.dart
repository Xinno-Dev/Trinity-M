import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/appVersionHelper.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/viewModel/market_view_model.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  static String get routeName => 'marketScreen';

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    final prov = ref.read(marketProvider);
    prov.getProductList();
    _viewModel = MarketViewModel(context);
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    final scrRatio = MediaQuery.of(context).size.width /
                     MediaQuery.of(context).size.height;
    isPadMode = scrRatio > 0.6;
    LOG('---> scrRatio : [$isPadMode] $scrRatio - '
      '${MediaQuery.of(context).size.width} / '
      '${MediaQuery.of(context).size.height}');

    return Container(
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40, bottom: kToolbarHeight),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: _viewModel.showProductList(),
          ),
          _viewModel.showCategoryBar(),
        ]
      )
    );
  }
}
