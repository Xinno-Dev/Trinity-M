import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import '../../common/common_package.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/const/widget/primary_button.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../../presentation/view/market/seller_detail_screen.dart';
import '../model/product_item_model.dart';
import '../model/product_model.dart';

class MarketViewModel {
  factory MarketViewModel([MarketProvider? provider]) {
    if (provider != null) {
      _singleton.prov = provider;
    }
    return _singleton;
  }
  static final _singleton = MarketViewModel._internal();
  MarketViewModel._internal();

  late MarketProvider prov;
  late BuildContext context;

  showCategoryBar() {
    // LOG('--> prov.categoryList : ${prov.categoryList}');
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List<Widget>.of(prov.categoryList.map((e) =>
              _categoryItem(STR(e.value), prov.categoryList.indexOf(e)))),
        ),
      ),
    );
  }

  showProductList() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
        List.generate(prov.marketRepo.productList.length, (index) =>
          _contentItem(prov.marketRepo.productList[index])),
        ),
      ),
    );
  }

  showProductDetail([var isShowSeller = true]) {
    final imageSize = MediaQuery.of(context).size.width;
    // LOG('--> detailPic : ${prov.optionIndex} / ${prov.selectProduct?.optionList?.length}');
    return Column(
      children: [
        if (prov.detailPic != null)
          Image.asset('assets/samples/${prov.detailPic}',
            width: imageSize, height: imageSize, fit: BoxFit.fitWidth),
        Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isShowSeller)
                _contentSellerBar(prov.selectProduct!),
              _contentTitleBar(prov.selectProduct!, padding: EdgeInsets.only(top: 15)),
              _contentDescription(prov.selectProduct!, padding: EdgeInsets.only(top: 30)),
            ],
          ),
        )
      ],
    );
  }

  showProductInfoTab() {
    return FutureBuilder(
      future: getImageHeight('assets/samples/${prov.externalPic}'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var exSize = snapshot.data as Size;
          return StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(builder: (context, constraints) {
                final itemHeight = constraints.maxWidth / 4;
                final itemLength = (prov.selectProduct?.optionList?.length ?? 0) / 4 +
                    ((prov.selectProduct?.optionList?.length ?? 0) % 4 > 0 ? 1 : 0);
                final listHeight = itemHeight * itemLength + 5;
                final detailHeight = exSize.height * (constraints.maxWidth / exSize.width);
                // LOG('---> listHeight : $listHeight / $itemHeight / $itemLength /'
                //     ' $detailHeight (${constraints.maxWidth / exSize.width} / ${exSize.width})');
                return DefaultTabController(
                  initialIndex: prov.selectDetailTab,
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
                            prov.selectDetailTab = index;
                            LOG('--> prov.selectDetail : $prov.selectDetail');
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
                        height: prov.selectDetailTab == 0 ? listHeight : detailHeight,
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
    // LOG('--> showOptionTab : $prov.selectProduct');
    if (prov.selectProduct?.optionList == null) {
      return Container(
        height: 100,
        child: Center(
          child: Text('No options..'),
        ),
      );
    }
    return Container(
      child: GridView.builder(
        itemCount: prov.selectProduct?.optionList?.length ?? 0,
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
            child: _optionListItem(
              prov.selectProduct!.optionList![index],
              index,
            ),
          );
        }
      ),
    );
  }

  showDetailTab() {
    if (STR(prov.externalPic).isEmpty) {
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
        'assets/samples/${prov.externalPic}',
        fit: BoxFit.fitWidth),
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
          _contentSellerBar(prov.selectProduct!),
          _contentBuyDetailBox(prov.selectProduct!),
          _contentBuyOptionBar(prov.selectProduct!),
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
                Text(prov.selectProduct!.priceText, style: typo16medium),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Row(
              children: [
                Text(TR(context, '결제 예정 금액'), style: typo18bold),
                Spacer(),
                Text(prov.selectProduct!.priceText, style: typo18bold),
              ],
            ),
          ),
          Text(TR(context!, '(주)엑시노는 통신판매 중개자이며, 통신판매의 당사자가 아닙니다. '
              '이에 따라, 당사는 상품, 거래정보 및 거래에 대하여 책임을 지지 않습니다.'),
              style: typo14normal),
        ],
      ),
    );
  }

  showStoreDetail(ProductModel item) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.w,
            horizontal: 30.w
          ),
          child: Column(
            children: [
              _contentSellerTopBar(item),
              _contentSellerDescBox(item,
                  padding: EdgeInsets.symmetric(vertical: 20)),
            ],
          ),
        ),
        _contentFollowButton(),
      ],
    );
  }

  showStoreProductList(String title, {var isShowSeller = true, var isCanBuy = true}) {
    // TODO: seller product list change..
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 20, bottom: 5),
            child: Text(title, style: typo16bold)
        ),
        ...List<Widget>.from(prov.marketRepo.productList.map((e) =>
            _contentItem(e, isShowSeller, isCanBuy)).toList())
      ],
    );
  }

  //////////////////////////////////////////////////////////////////////////////

  _categoryItem(String title, int index) {
    final isSelected = index == prov.selectCategory;
    return GestureDetector(
      onTap: () {
        prov.setCategory(index);
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
                child: Image.asset('assets/samples/${item.repImg}',
                    height: 220, fit: BoxFit.fitHeight),
              ),
              _contentTitleBar(item),
            ],
          ),
        );
      },
      openBuilder: (context, builder) {
        prov.selectProduct = item;
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
              if (item.sellerImage != null)...[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/samples/${item.sellerImage}'),
                ),
                SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.sellerName, style: typo16bold),
                    if (item.sellerSubtitle != null)...[
                      Text(item.sellerSubtitle!, style: typo14normal),
                    ]
                  ],
                ),
              )
            ],
          ),
        );
      },
      openBuilder: (context, builder) {
        return SellerDetailScreen(item);
      },
    );
  }

  _contentSellerTopBar(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.asset('assets/samples/${item.sellerImage}'),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _contentFollowBox(TR(context, '팔로워'), CommaIntText(item.sellerFollower)),
                _contentFollowBox(TR(context, '팔로잉'), CommaIntText(item.sellerFollowing)),
              ],
            ),
          )
        ],
      ),
    );
  }

  _contentSellerDescBox(ProductModel item, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Text(STR(item.sellerDesc), style: typo14normal, textAlign: TextAlign.center),
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
          SizedBox(height: 10),
          Text(STR(item.name), style: typo16bold),
          Row(
            children: [
              Text(CommaIntText(INT(item.itemPrice).toString()), style: typo18bold),
              Text(' ${item.priceUnit}', style: typo14medium),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(STR(item.description), style: typo14bold),
          if (STR(item.description2).isNotEmpty)...[
            SizedBox(height: 10),
            Text(STR(item.description2), style: typo14medium),
          ],
          if (STR(prov.optionDesc).isNotEmpty || STR(prov.optionDesc2).isNotEmpty)...[
            Divider(height: 50),
          ],
          if (STR(prov.optionDesc).isNotEmpty)...[
            Text(STR(prov.optionDesc), style: typo14bold),
            SizedBox(height: 10),
          ],
          if (STR(prov.optionDesc2).isNotEmpty)...[
            Text(STR(prov.optionDesc2), style: typo14medium),
          ],
        ],
      )
    );
  }

  _optionListItem(ProductItemModel option, int index, {EdgeInsets? padding}) {
    return InkWell(
      onTap: () {
        prov.setOptionIndex(index);
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: PRIMARY_100, width: prov.optionIndex == index ? 5 : 0),
        ),
        child: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset('assets/samples/${option.img}', fit: BoxFit.cover),
            ),
            Positioned(
              top: 2,
              left: 2,
              child: Text(STR(option.desc), style: typo12shadowR.copyWith(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  _contentBuyDetailBox(ProductModel item) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          if (prov.detailPic != null)
          Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/samples/${prov.detailPic!}'),
            )
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(TR(context, 'TICKET'), style: typo14bold),
                // if (item.edition != null)...[
                //   Row(
                //     children: [
                //       Text(TR(context, '에디션'), style: typo14medium),
                //       Spacer(),
                //       Text(TR(context, item.edition!), style: typo14medium),
                //     ],
                //   )
                // ],
                Divider(),
                Text(STR(item.name), style: typo14normal.copyWith(height: 1.0)),
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
            width: 100,
            round: 8,
            color: Colors.white,
            padding: EdgeInsets.zero,
            isBorderShow: true,
            isSmallButton: true,
            textStyle: typo14bold.copyWith(color: GRAY_80),
            text: TR(context, '옵션 선택'),
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