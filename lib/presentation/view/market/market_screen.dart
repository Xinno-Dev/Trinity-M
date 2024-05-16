import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/mainBox.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/market/product_detail_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';

import 'package:animations/animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../domain/model/product_model.dart';
import '../../../domain/viewModel/market_view_model.dart';
import '../../../services/google_service.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  static String get routeName => 'marketScreen';

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  RefreshController _refreshController =
    RefreshController(initialRefresh: false);
  final _scrollController  = ScrollController();
  late MarketViewModel _viewModel;

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    final prov = ref.read(marketProvider);
    await prov.getProductList();
    if (prov.isLastPage) {
     _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    final prov = ref.read(marketProvider);
    prov.getProductList();
    _viewModel = MarketViewModel();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final prov = ref.read(marketProvider);
    // prov.selectProduct!.
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    _viewModel.context = context;
    return SafeArea(
      top: false,
      child: Container(
        child: _viewModel.showProductList()
        // padding: EdgeInsets.symmetric(horizontal: 15.w),
    //     child: SmartRefresher(
    //       enablePullDown: false,
    //       enablePullUp: true,
    //       // header: WaterDropHeader(),
    //       footer: CustomFooter(
    //         loadStyle: LoadStyle.ShowWhenLoading,
    //         builder: (BuildContext context,LoadStatus? mode) {
    //           Widget body;
    //           if(mode == LoadStatus.idle){
    //             body =  Text("pull up load");
    //           }
    //           else if(mode == LoadStatus.loading){
    //             body =  CupertinoActivityIndicator();
    //           }
    //           else if(mode == LoadStatus.failed){
    //             body = Text("Load Failed!Click retry!");
    //           }
    //           else if(mode == LoadStatus.canLoading){
    //             body = Text("release to load more");
    //           }
    //           else{
    //             body = Text("No more Data");
    //             Fluttertoast.showToast(msg: TR(context, '마지막 입니다.'));
    //           }
    //           return Container(
    //             height: 55.0,
    //             child: Center(child:body),
    //           );
    //         },
    //       ),
    //       controller: _refreshController,
    //       onRefresh: _onRefresh,
    //       onLoading: _onLoading,
    //       child: ListView.builder(
    //         itemCount: prov.productList.length + 1,
    //         itemBuilder: (c, i) => i == 0 ? _viewModel.showCategoryBar() :
    //           _viewModel.productListItem(prov.marketRepo.productList[i - 1]),
    //       ),
    //     ),
    //   )
    // );
    //     child: CustomScrollView(
    //       controller: _scrollController,
    //       physics: ClampingScrollPhysics(),
    //       slivers: [
    //         SliverAppBar(
    //           toolbarHeight: 0,
    //           automaticallyImplyLeading: false,
    //           backgroundColor: Colors.white,
    //           surfaceTintColor: Colors.white,
    //           bottom: PreferredSize(
    //             preferredSize: Size.fromHeight(kToolbarHeight),
    //             child: _viewModel.showCategoryBar(),
    //           ),
    //         ),
    //         _viewModel.showProductList()
    //       ],
    //     )
      )
    );
  }
}
