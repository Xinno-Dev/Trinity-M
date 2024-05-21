import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/domain/model/purchase_model.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/viewModel/profile_view_model.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../common/common_package.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/dialogHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/const/widget/image_widget.dart';
import '../../common/const/widget/primary_button.dart';
import '../../presentation/view/market/item_select_screen.dart';
import '../../presentation/view/market/payment_item_screen.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../../presentation/view/market/seller_detail_screen.dart';
import '../model/product_item_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';

class MarketViewModel {
  factory MarketViewModel() {
    return _singleton;
  }
  static final _singleton = MarketViewModel._internal();
  MarketViewModel._internal();

  final prov = MarketProvider();
  late BuildContext context;

  showCategoryBar() {
    // LOG('--> prov.categoryList : ${prov.categoryList}');
    return Container(
      height: 40.h,
      color: WHITE,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.of(prov.categoryList.map((e) =>
                _categoryItem(STR(e.value), prov.categoryList.indexOf(e),
                  onChanged: (index) {
                    setState(() {});
                }))),
            ),
          );
        },
      ),
    );
  }

  showSliverProductList() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
        List.generate(prov.marketList.length, (index) =>
            productListItem(prov.marketList[index])),
        ),
      ),
    );
  }

  showProductList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(15, 10, 15, kToolbarHeight.h),
      itemCount: prov.marketList.length,
      itemBuilder: (context, index) {
        return productListItem(prov.marketList[index]);
      }
    );
  }

  showProductDetail(BuildContext context, [var isShowSeller = true]) {
    final imageSize = MediaQuery.of(context).size.width;
    LOG('--> showProductDetail : ${prov.detailPic} / ${prov.selectProduct?.toJson()}');
    return Column(
      children: [
        if (STR(prov.detailPic).isNotEmpty)
          showImage(STR(prov.detailPic),
            Size.square(imageSize.r), fit: BoxFit.fitWidth),
        Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isShowSeller)
                _contentSellerBar(prov.selectProduct!.seller!),
              _contentTitleBar(prov.selectProduct!, padding: EdgeInsets.only(top: 15)),
              _contentDescription(prov.selectProduct!, padding: EdgeInsets.only(top: 30)),
            ],
          ),
        )
      ],
    );
  }

  showProductInfoTab(ref) {
    return FutureBuilder(
      future: getNetworkImageInfo(prov.externalPic),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var info = snapshot.data as NetworkImageInfo;
          return StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(builder: (context, constraints) {
                var itemHeight = constraints.maxWidth / 4;
                var itemLength = (prov.selectProduct?.itemList?.length ?? 0) / 4 +
                    ((prov.selectProduct?.itemList?.length ?? 0) % 4 > 0 ? 1 : 0);
                var listHeight = itemLength > 0 ? itemHeight * itemLength + 5 : 120.h;
                var screenWidth = MediaQuery.of(context).size.width;
                var detailHeight = DBL(info.size?.width) <= 0 ? 0.0 :
                    DBL(info.size?.height) * (screenWidth / DBL(info.size?.width));
                // LOG('---> listHeight : $listHeight / $itemHeight / $itemLength /'
                //     ' $detailHeight (${screenWidth} / ${info.size})');
                return DefaultTabController(
                  length: 2,
                  initialIndex: prov.selectDetailTab,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: GRAY_90,
                        labelStyle: typo16semibold,
                        indicatorColor: GRAY_90,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: GRAY_40,
                        onTap: (index) {
                          setState(() {
                            prov.selectDetailTab = index;
                            LOG('--> prov.selectDetail : $prov.selectDetail');
                          });
                        },
                        tabs: <Widget>[
                          Tab(
                            text: TR(context, '상세 정보'),
                          ),
                          Tab(
                            text: TR(context, '옵션 정보'),
                          ),
                          // Tab(
                          //   text: TR(context, 'NFT 정보'),
                          // ),
                        ],
                      ),
                      AnimatedContainer(
                        color: Colors.white,
                        height: prov.selectDetailTab == 1 ? listHeight : detailHeight,
                        margin: EdgeInsets.only(top: 2),
                        duration: Duration(milliseconds: 100),
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            showDetailTab(),
                            showOptionTab(),
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

  showOptionSelectList() {
    return showOptionTab(isSelect: true);
  }

  showOptionTab({var isSelect = false}) {
    var itemCount = prov.selectProduct?.itemList?.length ?? 0;
    if (itemCount <= 0) {
      return Container(
        height: 120.h,
        child: Center(
          child: Text(TR(context, 'No options..')),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2
      ),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _optionListItem(
          prov.selectProduct!.itemList![index],
          index,
          isFirst: prov.selectProduct?.itemLastId == null,
          isCanSelect: isSelect,
        );
      }
    );
  }

  showDetailTab() {
    if (!STR(prov.externalPic).contains('http')) {
      return Container(
        height: 100.h,
        child: Center(
          child: Text(TR(context, 'No detail info..')),
        ),
      );
    }
    return Container(
      alignment: Alignment.topCenter,
      child: showImage(prov.externalPic, Size.zero, fit: BoxFit.fitWidth),
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
          _contentSellerBar(prov.selectProduct!.seller!),
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
          Text(TR(context, '(주)엑시노는 통신판매 중개자이며, 통신판매의 당사자가 아닙니다. '
              '이에 따라, 당사는 상품, 거래정보 및 거래에 대하여 책임을 지지 않습니다.'),
              style: typo14normal),
        ],
      ),
    );
  }

  showStoreDetail(SellerModel seller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.w,
            horizontal: 30.w
          ),
          child: Column(
            children: [
              _contentSellerTopBar(seller),
              _contentSellerDescBox(seller,
                  padding: EdgeInsets.symmetric(vertical: 20)),
            ],
          ),
        ),
        // _contentFollowButton(),
      ],
    );
  }

  showStoreProductList(String title, {var isShowSeller = true, var isCanBuy = true}) {
    // TODO: seller product list change..
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Text(title, style: typo16bold)
        ),
        ...List<Widget>.from(prov.marketRepo.productList.map((e) =>
            productListItem(e, isShowSeller, isCanBuy)).toList())
      ],
    );
  }

  //////////////////////////////////////////////////////////////////////////////

  showPurchaseResult(BuildContext context) {
    var info = prov.purchaseInfo;
    return Column(
      children: [
        _contentSellerBar(info!.seller!),
        _purchaseItem(context, info),
      ],
    );
  }

  showPurchaseList(BuildContext context) {
    if (prov.purchaseList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: prov.purchaseList.length,
        itemBuilder: (context, index) {
          return _purchaseItem(context, prov.purchaseList[index], isShowDetail: true);
        }
      );
    } else {
      return Container(
        height: 140.h,
        alignment: Alignment.center,
        child: Text('No purchase data..'),
      );
    }
  }
  
  showPurchaseDate(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(prov.purchaseSearchDate, style: typo14semibold),
          Spacer(),
          PrimaryButton(
            onTap: _showPurchaseDatePicker,
            text: TR(context, '조회 기간'),
            height: 30.h,
            color: WHITE,
            textStyle: typo12semibold100,
            isBorderShow: true,
            isSmallButton: true
          ),
        ],
      ),
    );
  }

  showPurchaseDetail(BuildContext context, [var isShowSeller = true]) {
    final imageSize = MediaQuery.of(context).size.width;
    LOG('--> showPurchaseInfo : ${prov.detailPic} / ${prov.selectProduct?.toJson()}');
    return FutureBuilder(
      future: prov.getPurchaseProductInfo(),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          var productInfo = snapShot.data as ProductModel;
          return Column(
            children: [
              if (STR(prov.selectPurchaseItem!.itemImg).isEmpty &&
                  STR(productInfo.repDetailImg).isNotEmpty)
                showImage(STR(productInfo.repDetailImg),
                  Size.square(imageSize.r), fit: BoxFit.fitWidth),
              if (STR(prov.selectPurchaseItem!.itemImg).isNotEmpty)
                showImage(STR(prov.selectPurchaseItem!.itemImg),
                    Size.square(imageSize.r), fit: BoxFit.fitWidth),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isShowSeller)
                      _contentSellerBar(prov.selectPurchaseItem!.seller!,
                        padding: EdgeInsets.symmetric(vertical: 10)
                      ),
                    _contentTitleBar(productInfo, isShowAmount: false),
                    _contentDescription(productInfo, padding: EdgeInsets.only(top: 30)),
                  ],
                ),
              ),
              Divider(height: 40),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Text(
                      TR(context, '구매일 : '),
                      style: typo14bold,
                    ),
                    Text(
                      STR(prov.selectPurchaseItem!.txDateTime),
                      style: typo14bold,
                    ),
                  ],
                )
              ),
            ],
          );
        } else {
          return showLoadingFull();
        }
      }
    );
  }


  _showPurchaseDatePicker() {
    showDialog(context: context,
      builder: (BuildContext context) =>
        DateRangePickerDialog(
          currentDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: prov.purchaseStartDate,
            end:   prov.purchaseEndDate,
          ),
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now(),
          saveText: TR(context, '선택완료'),
        )
    ).then((result) {
      if (result != null) {
        var range = result as DateTimeRange;
        LOG('--> date result : ${range.start} ~ ${range.end}');
        prov.purchaseStartDate = range.start;
        prov.purchaseEndDate   = range.end;
        prov.refresh();
      }
    });
  }


  _purchaseTitleBar(PurchaseModel item, {EdgeInsets? padding}) {
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
              Text(prov.selectPurchaseItem!.priceText, style: typo14bold),
              SizedBox(width: 10),
              Text('[수량 1]', style: typo14medium),
            ],
          )
        ],
      ),
    );
  }


  _purchaseItem(BuildContext context, PurchaseModel item,
    {EdgeInsets? margin, var isShowDetail = false}) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 15),
      color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                if (isShowDetail) {
                  prov.selectPurchaseItem = item;
                  Navigator.of(context).push(createAniRoute(PaymentItemScreen()));
                }
              },
              child: Container(
                  child: Row(
                    children: [
                      if (prov.detailPic != null)
                        Container(
                            width: 80,
                            height: 80,
                            margin: EdgeInsets.only(right: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: showImage(STR(prov.detailPic), Size(100, 100)),
                            )
                        ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(STR(item.name), style: typo14bold.copyWith(height: 1.0)),
                            SizedBox(height: 10),
                            Text(item.priceText, style: typo16bold),
                          ],
                        ),
                      ),
                    ],
                  )
              )
          ),
          if (isShowDetail)...[
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      prov.selectPurchaseItem = item;
                      Navigator.of(context).push(createAniRoute(PaymentItemScreen()));
                    },
                    child: Text(TR(context, '상품 정보'), style: typo14normal),
                  ),
                  Container(
                    width: 1,
                    height: 16.h,
                    color: GRAY_50,
                  ),
                  Text(TR(context, '구매 상세'), style: typo14normal),
                ],
              ),
            ),
            Divider()
          ],
        ],
      )
    );
  }

  //////////////////////////////////////////////////////////////////////////////

  _categoryItem(String title, int index, {Function(int)? onChanged}) {
    final isSelected = index == prov.selectCategory;
    return GestureDetector(
      onTap: () {
        prov.setCategory(index);
        if (onChanged != null) onChanged(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        margin: EdgeInsets.only(right: 10),
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

  productListItem(ProductModel item,
    [var isShowSeller = true, var isCanBuy = true]) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return VisibilityDetector(
          key: GlobalKey(),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0) {
              prov.refreshProductList(context, item.saleProdId);
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 25),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isShowSeller && item.seller != null)
                  _contentSellerBar(item.seller!, padding: EdgeInsets.only(bottom: 10.h)),
                showImage(STR(item.repImg),
                    Size(MediaQuery.of(context).size.width, 220.r),
                    fit: BoxFit.fitHeight),
                _contentTitleBar(item),
              ],
            ),
          )
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
    //     prov.selectProduct = item;
    //     ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    //     Navigator.of(context).push(createAniRoute(ProductDetailScreen(
    //       isShowSeller: isShowSeller,
    //       isCanBuy: isCanBuy,
    //     );
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

  _contentSellerBar(SellerModel info, {EdgeInsets? padding}) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return Container(
          padding: padding,
          child: Row(
            children: [
              if (STR(info.pfImg).isNotEmpty)...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(PROFILE_RADIUS_S.r),
                  child: showImage(STR(info.pfImg),
                    Size.square(PROFILE_RADIUS_S.r),
                    fit: BoxFit.fill),
                ),
                SizedBox(width: 10.w),
              ],
              if (STR(info.pfImg).isEmpty)...[
                SvgPicture.asset('assets/svg/icon_profile_00.svg',
                  width: PROFILE_RADIUS_S.r,
                  height: PROFILE_RADIUS_S.r, fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(GRAY_20, BlendMode.srcIn),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(STR(info.nickId), style: typo16bold),
                    if (STR(info.subTitle).isNotEmpty)...[
                      Text(info.subTitle!, style: typo14normal),
                    ]
                  ],
                ),
              )
            ],
          ),
        );
      },
      openBuilder: (context, builder) {
        return SellerDetailScreen(info);
      },
    );
  }

  _contentSellerTopBar(SellerModel seller, {EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (STR(seller.pfImg).isNotEmpty)...[
            ClipRRect(
              borderRadius: BorderRadius.circular(PROFILE_RADIUS.r),
              child: showImage(STR(seller.pfImg),
                Size.square(PROFILE_RADIUS.r),
                fit: BoxFit.fill),
            ),
            SizedBox(width: 10.w),
          ],
          if (STR(seller.pfImg).isEmpty)...[
            SvgPicture.asset('assets/svg/icon_profile_00.svg',
              width: PROFILE_RADIUS.r, height: PROFILE_RADIUS.r, fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(GRAY_20, BlendMode.srcIn),
            ),
            SizedBox(width: 10.w),
          ],
          // SizedBox(width: 20),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _contentFollowBox(TR(context, '팔로워'), CommaIntText(item.sellerFollower)),
          //       _contentFollowBox(TR(context, '팔로잉'), CommaIntText(item.sellerFollowing)),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  _contentSellerDescBox(SellerModel seller, {EdgeInsets? padding}) {
    if (STR(seller.pfImg).isNotEmpty) {
      return Container(
        padding: padding,
        child: Text(STR(seller.pfImg), style: typo14normal,
            textAlign: TextAlign.center),
      );
    }
    return Container();
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

  _contentTitleBar(ProductModel item, {EdgeInsets? padding, var isShowAmount = true}) {
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
              if (isShowAmount)...[
                SizedBox(width: 10),
                Text('[수량 ${item.amountText}]', style: typo14medium),
              ],
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
          Text(STR(item.description), style: typo14medium),
          if (STR(item.description2).isNotEmpty)...[
            SizedBox(height: 10),
            Text(STR(item.description2), style: typo14medium),
          ],
          if (STR(prov.optionDesc).isNotEmpty || STR(prov.optionDesc2).isNotEmpty)...[
            Divider(height: 50),
          ],
          if (STR(prov.optionDesc).isNotEmpty)...[
            Text(STR(prov.optionDesc), style: typo14medium),
            SizedBox(height: 10),
          ],
          if (STR(prov.optionDesc2).isNotEmpty)...[
            Text(STR(prov.optionDesc2), style: typo14medium),
          ],
        ],
      )
    );
  }

  _optionListItem(ProductItemModel option, int index,
    {var isFirst = false, var isCanSelect = false, EdgeInsets? padding}) {
    return InkWell(
      onTap: () {
        if (isCanSelect) {
          prov.setOptionIndex(index);
        } else {
          showImageDialog(context, STR(option.img));
        }
      },
      child: VisibilityDetector(
        key: GlobalKey(),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0) {
            prov.refreshProductItemList(context, option.itemId);
          }
        },
        child: Container(
          padding: padding,
          decoration: isCanSelect ? BoxDecoration(
            border: Border.all(color: PRIMARY_100, width: prov.optionIndex == index ? 3 : 0),
          ) : null,
          child: Stack(
            children: [
              SizedBox.expand(
                child: showImage(STR(option.img), Size.zero, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 3,
                left: 3,
                child: Text(STR(option.itemId), style: typo12shadowR.copyWith(fontSize: 10)),
              ),
              if (isCanSelect)
                Positioned(
                  top: 3,
                  right: 3,
                  child: showCheckBoxImg(prov.optionIndex == index),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _contentBuyDetailBox(ProductModel item) {
    return Container(
      height: 100,
      margin: EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (prov.detailPic != null)
          Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(right: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: showImage(STR(prov.detailPic), Size(100, 100)),
            )
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(TR(context, 'TICKET'), style: typo14bold),
                // if (item.edition != null)...[
                //   Row(
                //     children: [
                //       Text(TR(context, '에디션'), style: typo14medium),
                //       Spacer(),
                //       Text(TR(context, item.edition!), style: typo14medium),
                //     ],
                //   )
                // ],
                Text(STR(item.name), style: typo14bold.copyWith(height: 1.0)),
                SizedBox(height: 10),
                Text(item.priceText, style: typo16bold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _contentBuyOptionBar(ProductModel item) {
    final height = 80.0.r;
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prov.optionIndex >= 0)...[
            Container(
              width:  height / 2,
              height: height,
              margin: EdgeInsets.only(right: 5),
              child: SvgPicture.asset('assets/svg/sub_line_00.svg',
                fit: BoxFit.fitHeight,
                colorFilter: ColorFilter.mode(GRAY_40, BlendMode.srcIn)
              ),
            ),
          ],
          Expanded(child: Column(
            children: [
              if (prov.optionIndex >= 0)...[
                Row(
                  children: [
                    Container(
                      width:  height,
                      height: height,
                      margin: EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: showImage(STR(prov.optionPic),
                          Size.square(height), fit: BoxFit.fitHeight),
                      )
                    ),
                    Text(STR(prov.optionDesc), style: typo16regular),
                  ],
                ),
                SizedBox(height: 10),
              ],
              if (prov.optionIndex < 0)...[
                SizedBox(height: 14),
              ],
              Row(
                children: [
                  PrimaryButton(
                    onTap: () {
                      Navigator.of(context).push(createAniRoute(ItemSelectScreen())).then((index) {
                        if (index != null) {
                          prov.setOptionIndex(index);
                        }
                      });
                    },
                    width: height,
                    round: 8,
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    isBorderShow: true,
                    isSmallButton: true,
                    textStyle: typo14bold.copyWith(color: prov.optionIndex >= 0 ? GRAY_80 : Colors.red),
                    text: TR(context, '옵션 선택'),
                  ),
                  Spacer(),
                ],
              ),
            ],
          ))
        ],
      )
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