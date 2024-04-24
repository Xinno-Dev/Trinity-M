import 'package:animations/animations.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/domain/model/product_model.dart';
import 'package:larba_00/domain/repository/product_repository.dart';
import 'package:larba_00/presentation/view/market/product_store_screen.dart';

import '../../domain/model/product_item_model.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../common_package.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/uihelper.dart';

final marketProvider = ChangeNotifierProvider<MarketProvider>((_) {
  return MarketProvider();
});

class MarketProvider extends ChangeNotifier {
  static final _singleton  = MarketProvider._internal();
  static final _marketRepo = ProductRepository();
  late BuildContext context;

  factory MarketProvider() {
    _marketRepo.init();
    return _singleton;
  }
  MarketProvider._internal();

  var selectCategory = 0;
  var selectDetail = 0;
  ProductModel? selectProduct;

  showCategoryBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List<Widget>.of(_marketRepo.categoryN.map((e) =>
            _categoryItem(e, _marketRepo.categoryN.indexOf(e)))),
        ),
      ),
    );
  }

  showProductList() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(_marketRepo.productList.length, (index) =>
              _contentItem(_marketRepo.productList[index])),
        ),
      ),
    );
  }

  showProductDetail([var isShowSeller = true]) {
    return Column(
      children: [
        Image.asset('assets/samples/${selectProduct?.pic}'),
        Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isShowSeller)
                _contentSellerBar(selectProduct!),
              _contentTitleBar(selectProduct!, padding: EdgeInsets.only(top: 15)),
              _contentDescription(selectProduct!, padding: EdgeInsets.only(top: 30)),
            ],
          ),
        )
      ],
    );
  }

  showProductInfo() {
    return FutureBuilder(
      future: getImageHeight('assets/samples/${selectProduct!.externUrl}'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var exSize = snapshot.data as Size;
          return StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(builder: (context, constraints) {
                final itemHeight = constraints.maxWidth / 4;
                final itemLength = (selectProduct?.optionList?.length ?? 0) / 4 +
                    ((selectProduct?.optionList?.length ?? 0) % 4 > 0 ? 1 : 0);
                final listHeight = itemHeight * itemLength + 5;
                final detailHeight = exSize.height * (constraints.maxWidth / exSize.width);
                LOG('---> listHeight : $listHeight / $itemHeight / $itemLength /'
                    ' $detailHeight (${constraints.maxWidth / exSize.width} / ${exSize.width})');
                return DefaultTabController(
                  initialIndex: selectDetail,
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: GRAY_90,
                        labelStyle: typo16semibold,
                        unselectedLabelColor: GRAY_40,
                        indicatorColor: GRAY_90,
                        indicatorSize: TabBarIndicatorSize.tab,
                        onTap: (index) {
                          setState(() {
                            selectDetail = index;
                            LOG('--> selectDetail : $selectDetail');
                          });
                        },
                        tabs: <Widget>[
                          Tab(
                            text: TR(context, '옵션 정보'),
                          ),
                          Tab(
                            text: TR(context, '상세 정보'),
                          ),
                          // Tab(
                          //   text: TR(context, 'NFT 정보'),
                          // ),
                        ],
                      ),
                      AnimatedContainer(
                        color: Colors.white,
                        height: selectDetail == 0 ? listHeight : detailHeight,
                        margin: EdgeInsets.only(top: 2),
                        duration: Duration(milliseconds: 100),
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            showOptionTab(),
                            showDetailTab(),
                          ],
                        ),
                      )
                    ],
                  )
                );
              });
            });
      } else {
        return showLoadingFull();
      }
    });
  }

  showOptionTab() {
    LOG('--> showOptionTab : $selectProduct');
    if (selectProduct?.optionList == null) {
      return Container(
        height: 100,
        child: Center(
          child: Text('No options..'),
        ),
      );
    }
    return Container(
      child: GridView.builder(
        itemCount: selectProduct?.optionList?.length ?? 0,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2
        ),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return SizedBox(
            // width: itemHeight,
            // height: itemHeight,
            child: _optionListItem(selectProduct!.optionList![index]),
          );
        }
      ),
    );
  }

  showDetailTab() {
    if (selectProduct?.externUrl == null) {
      return Container(
        height: 100,
        child: Center(
          child: Text('No detail info..'),
        ),
      );
    }
    return Container(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/samples/${selectProduct?.externUrl}', fit: BoxFit.fitWidth),
    );
  }

  showNFTDetailTab() {
    return Container(

    );
  }

  showBuyBox() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(TR(context, '구매 상품'), style: typo16bold),
          ),
          _contentSellerBar(selectProduct!),
          _contentBuyDetailBox(selectProduct!),
          _contentBuyOptionBar(selectProduct!),
          Divider(height: 50),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(TR(context, '결제 예정 금액을 확인해 주세요.'), style: typo16bold),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(TR(context, '상품 금액'), style: typo16medium),
                Spacer(),
                Text(selectProduct!.priceText, style: typo16medium),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Row(
              children: [
                Text(TR(context, '결제 예정 금액'), style: typo18bold),
                Spacer(),
                Text(selectProduct!.priceText, style: typo18bold),
              ],
            ),
          ),
          Text(TR(context, '(주)엑시노는 통신판매 중개자이며, 통신판매의 당사자가 아닙니다. '
            '이에 따라, 당사는 상품, 거래정보 및 거래에 대하여 책임을 지지 않습니다.'),
            style: typo14normal),
        ],
      ),
    );
  }

  showStoreDetail(ProductModel item) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Column(
        children: [
          _contentStoreTopBar(item),
          _contentStoreDescBox(item,
            padding: EdgeInsets.symmetric(vertical: 20)),
          _contentFollowButton(),
        ],
      ),
    );
  }

  showStoreProductList(context, {var isShowSeller = true, var isCanBuy = true}) {
    // TODO: seller product list change..
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 5),
          child: Text(TR(context, 'Market'), style: typo16bold)
        ),
        ...List<Widget>.from(_marketRepo.productList.map((e) =>
          _contentItem(e, isShowSeller, isCanBuy)).toList())
      ],
    );
  }

  //////////////////////////////////////////////////////////////////////////////

  _categoryItem(String title, int index) {
    final isSelected = index == selectCategory;
    return GestureDetector(
      onTap: () {
        selectCategory = index;
        notifyListeners();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? GRAY_80 : GRAY_10,
        ),
        child: Text(title,
          style: typo12semibold100.copyWith(color: isSelected ? WHITE : GRAY_80)),
      )
    );
  }

  _contentItem(ProductModel item, [var isShowSeller = true, var isCanBuy = true]) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return Container(
          margin: EdgeInsets.only(bottom: 25),
          color: Colors.white,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isShowSeller)
                _contentSellerBar(item),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset('assets/samples/${item.picThumb}',
                    height: 220, fit: BoxFit.fitHeight),
              ),
              _contentTitleBar(item),
            ],
          ),
        );
      },
      openBuilder: (context, builder) {
        selectProduct = item;
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        return ProductDetailScreen(
          isShowSeller: isShowSeller,
          isCanBuy: isCanBuy,
        );
      },
    );
    // return InkWell(
    //   onTap: () {
    //     if (onSelect != null) onSelect(item);
    //   },
    //   child: Container(
    //     margin: EdgeInsets.all(15),
    //     color: Colors.white,
    //     width: double.infinity,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         _contentSellerBar(item),
    //         Padding(
    //           padding: EdgeInsets.symmetric(vertical: 10),
    //           child: Image.asset('assets/samples/${item.picThumb}',
    //               height: 220, fit: BoxFit.fitHeight),
    //         ),
    //         _contentTitleBar(item),
    //       ],
    //     ),
    //   ),
    // );
  }

  _contentSellerBar(ProductModel item, {EdgeInsets? padding}) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return Container(
          padding: padding,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Image.asset('assets/samples/${item.sellerPic}'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.sellerName, style: typo16bold),
                    if (item.sellerNameEx != null)...[
                      Text(item.sellerNameEx!, style: typo14normal),
                    ]
                  ],
                ),
              )
            ],
          ),
        );
      },
      openBuilder: (context, builder) {
        return ProductStoreScreen(item);
      },
    );
  }

  _contentStoreTopBar(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.asset('assets/samples/${item.sellerPic}'),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _contentFollowBox(TR(context, '팔로워'), STR(item.sellerFollower)),
                _contentFollowBox(TR(context, '팔로잉'), STR(item.sellerFollowing)),
              ],
            ),
          )
        ],
      ),
    );
  }

  _contentStoreDescBox(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Text(STR(item.sellerDesc), style: typo14normal),
    );
  }

  _contentFollowBox(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title, style: typo14normal),
        Text(value, style: typo14bold),
      ],
    );
  }

  _contentTitleBar(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: typo14medium),
          Row(
            children: [
              Text(CommaIntText(INT(item.price).toString()), style: typo18bold),
              Text(' ${item.currency}', style: typo14medium),
              SizedBox(width: 10),
              Text('[수량 ${item.amountText}]', style: typo14medium),
            ],
          )
        ],
      ),
    );
  }

  _contentDescription(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Text(STR(item.description), style: typo14medium),
    );
  }

  _optionListItem(ProductItemModel option, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/samples/${option.picThumb}', fit: BoxFit.cover),
          ),
          Text(STR(option.id), style: typo10regular100),
        ],
      ),
    );
  }

  _contentBuyDetailBox(ProductModel item) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/samples/${item.pic}'),
            )
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(TR(context, 'TICKET'), style: typo14bold),
                if (item.edition != null)...[
                  Row(
                    children: [
                      Text(TR(context, '에디션'), style: typo14medium),
                      Spacer(),
                      Text(TR(context, item.edition!), style: typo14medium),
                    ],
                  )
                ],
                Divider(),
                Text(item.title, style: typo14normal.copyWith(height: 1.0)),
                SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _contentBuyOptionBar(ProductModel item) {
    return Container(
      child: Row(
        children: [
          PrimaryButton(
            onTap: () {
              LOG('---> option select');
            },
            round: 8,
            color: Colors.white,
            padding: EdgeInsets.zero,
            isBorderShow: true,
            isSmallButton: true,
            textStyle: typo14bold.copyWith(color: GRAY_80),
            text: TR(context, '옵션선택'),
          ),
          Spacer(),
          Text(item.priceText, style: typo14bold),
        ],
      ),
    );
  }

  _contentFollowButton() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            color: GRAY_20,
            textStyle: typo14semibold,
            isSmallButton: true,
            onTap: () {

            },
            text: TR(context, '팔로우'),
          )
        ),
      ],
    );
  }
}