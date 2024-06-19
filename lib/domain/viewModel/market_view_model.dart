import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trinity_m_00/common/const/cd_enum_const.dart';
import 'package:trinity_m_00/domain/model/purchase_model.dart';
import 'package:trinity_m_00/presentation/view/market/payment_done_screen.dart';
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
import '../../presentation/view/profile/profile_target_screen.dart';
import '../model/product_item_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';

class MarketViewModel {
  MarketViewModel(BuildContext context) {
    this.context = context;
  }
  late BuildContext context;
  final prov = MarketProvider();

  get titleStyle {
    return typo16bold;
  }

  get descStyle {
    return typo16medium;
  }

  get descSmallStyle {
    return typo12normal;
  }

  get priceStyle {
    return typo18bold;
  }

  showCategoryBar() {
    // LOG('--> prov.categoryList : ${prov.categoryList}');
    return Container(
      height: 40,
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
                    prov.setCategory(index);
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
    LOG('--> showProductList : ${prov.marketList.length}');
    if (prov.marketList.isNotEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        itemCount: prov.marketList.length,
        padding: EdgeInsets.symmetric(vertical: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPadMode ? 2 : 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          return productListItem(
            prov.marketList[index],
            height: 230,
          );
        }
      );
      // return ListView.builder(
      //   shrinkWrap: true,
      //   padding: EdgeInsets.fromLTRB(15, 10, 15, kToolbarHeight.h),
      //   itemCount: prov.marketList.length,
      //   itemBuilder: (context, index) {
      //     return productListItem(prov.marketList[index]);
      //   }
      // );
    } else {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(TR('상품이 없습니다.')),
      );
    }
  }

  showUserProductList(String title, String ownerAddr,
    { var isShowSeller = true, var isCanBuy = true}) {
    return FutureBuilder(
      future: prov.getProductList(ownerAddr: ownerAddr),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(title, style: typo16bold)
              ),
              if (prov.marketRepo.userProductList.isNotEmpty)...[
                GridView.builder(
                    shrinkWrap: true,
                    itemCount: prov.marketRepo.userProductList.length,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isPadMode ? 2 : 1,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return productListItem(
                        prov.marketRepo.userProductList[index],
                        height: isPadMode ? 220 : 230,
                        isShowSeller: isShowSeller,
                        isCanBuy: isCanBuy,
                      );
                    }
                ),
                // ...List<Widget>.from(prov.marketRepo.userProductList.
                // map((e) => productListItem(e,
                //   isShowSeller: isShowSeller, isCanBuy: isCanBuy))
                //   .toList())
              ],
              if (prov.marketRepo.userProductList.isEmpty)...[
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(TR('판매중인 상품이 없습니다.')),
                )
              ]
            ],
          );
        } else {
          return showLoadingFull();
        }
      }
    );
  }

  showProductDetail([var isShowSeller = true]) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        if (STR(prov.detailPic).isNotEmpty)
          showImage(STR(prov.detailPic),
            Size(width, 0), fit: BoxFit.fitWidth),
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
                var isShowAll = prov.canOptionSelect && prov.catShowExternalPic;
                var height = isShowAll ?
                  (prov.selectDetailTab == 1 ? detailHeight : listHeight) :
                  prov.canOptionSelect ? listHeight : detailHeight;

                // LOG('---> listHeight : $listHeight / $itemHeight / $itemLength /'
                //     ' $detailHeight (${screenWidth} / ${info.size})');
                return DefaultTabController(
                  length: isShowAll ? 2 : 1,
                  initialIndex: isShowAll ? prov.selectDetailTab : 0,
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
                          if (prov.canOptionSelect)
                            Tab(
                              text: TR('옵션 정보'),
                            ),
                          if (prov.catShowExternalPic)
                            Tab(
                              text: TR('상세 정보'),
                            ),
                        ],
                      ),
                      AnimatedContainer(
                        color: Colors.white,
                        height: height,
                        margin: EdgeInsets.only(top: 2),
                        duration: Duration(milliseconds: 100),
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            if (prov.canOptionSelect)
                              showOptionTab(),
                            if (prov.catShowExternalPic)
                              showDetailTab(prov.externalPic),
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
          child: Text(TR('No options..')),
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
          prov.selectProduct!.itemList![index], index, isCanSelect: isSelect);
      }
    );
  }

  showDetailTab(String? externalUrl, {double? height}) {
    LOG('--> showDetailTab : $externalUrl');
    if (STR(externalUrl).isEmpty) {
      return Container(
        height: 100.h,
        child: Center(
          child: Text('No detail info..'),
        ),
      );
    }
    return Container(
      height: height,
      alignment: Alignment.topCenter,
      child: showImage(STR(externalUrl), Size.zero, fit: BoxFit.fitWidth),
    );
  }

  showNFTDetailTab() {
    return Container(

    );
  }

  showBuyBox() {
    if (!prov.canOptionSelect && prov.hasOption) {
      prov.optionIndex = 0;
    }
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(TR('구매 상품'), style: typo16bold),
          ),
          _contentSellerBar(prov.selectProduct!.seller!),
          _contentBuyDetailBox(prov.selectProduct!),
          if (prov.canOptionSelect)
            _contentBuyOptionBar(prov.selectProduct!),
          Divider(height: 50),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(TR('결제 예정 금액을 확인해 주세요.'), style: typo16bold),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(TR('상품 금액'), style: typo16medium),
                Spacer(),
                Text(prov.selectProduct!.priceText, style: typo16medium),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Row(
              children: [
                Text(TR('결제 예정 금액'), style: typo18bold),
                Spacer(),
                Text(prov.selectProduct!.priceText, style: typo18bold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showSellerDetail(SellerModel seller) {
    return FutureBuilder(
      future: prov.getSellerInfo(seller),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          seller = snapShot.data as SellerModel;
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _contentSellerTopBar(seller),
                    _contentSellerDescBox(seller,
                      padding: EdgeInsets.only(top: 20)),
                  ],
                ),
              ),
              // _contentFollowButton(),
            ],
          );
        } else {
          return showLoadingFull(30);
        }
      }
    );
  }

  //////////////////////////////////////////////////////////////////////////////

  showPurchaseResult() {
    var info = prov.purchaseInfo;
    return Column(
      children: [
        _contentSellerBar(info!.seller!),
        _purchaseItem(info),
      ],
    );
  }

  showPurchaseList({var showStatus = true, EdgeInsets? padding}) {
    return Container(
      child: FutureBuilder(
        future: prov.getPurchaseList(),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            if (prov.purchaseList.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                padding: padding,
                itemCount: prov.purchaseList.length,
                itemBuilder: (context, index) {
                  return _purchaseItem(prov.purchaseList[index],
                    isShowDetail: true);
                }
              );
            } else {
              return Container(
                height: 140.h,
                alignment: Alignment.center,
                child: Text(TR('구매한 상품이 없습니다.')),
              );
            }
          } else {
            return showLoadingFull();
          }
        }
      )
    );
  }

  showUserItemListShowType() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Spacer(),
          InkWell(
            onTap: () {
              prov.userItemShowGrid = false;
              prov.refresh();
            },
            child: Container(
              padding: EdgeInsets.all(5),
              color: Colors.transparent,
              child: Icon(Icons.view_agenda_outlined,
                color: !prov.userItemShowGrid ? GRAY_80 : GRAY_20),
            )),
          InkWell(
            onTap: () {
              prov.userItemShowGrid = true;
              prov.refresh();
            },
            child: Container(
              padding: EdgeInsets.all(5),
              color: Colors.transparent,
              child: Icon(Icons.grid_view,
                color: prov.userItemShowGrid ? GRAY_80 : GRAY_20),
            )),
        ],
      ),
    );
  }

  showUserItemList(String ownerAddr) {
    return FutureBuilder(
      future: prov.getUserItemList(ownerAddr),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          var userItemList = prov.userItemList(ownerAddr);
          if (userItemList.isNotEmpty) {
            if (prov.userItemShowGrid) {
              return GridView.builder(
                shrinkWrap: true,
                itemCount: userItemList.length,
                padding: EdgeInsets.symmetric(vertical: 15),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPadMode ? 4 : 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5
                ),
                itemBuilder: (context, index) {
                  final image = getUserItemImage(userItemList[index]);
                  return _userOptionListItem(
                      userItemList[index], index, image: image);
                }
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: userItemList.length,
                padding: EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  return _userProductListItem(userItemList[index]);
                }
              );
            }
          } else {
            return Container(
              height: 140.h,
              alignment: Alignment.center,
              child: Text(TR('보유중인 상품이 없슴니다.')),
            );
          }
        } else {
          return showLoadingFull();
        }
      }
    );
  }

  popUserItemDetail(ProductItemModel item) {
    final width  = MediaQuery.of(context).size.width * 0.9;
    final height = MediaQuery.of(context).size.height * 0.9;
    final image  = getUserItemImage(item, isShowEmpty: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WHITE,
      builder: (context) {
        return Container(
          height: height,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0.sp),
              topRight: Radius.circular(16.0.sp),
            ),
            color: WHITE,
          ),
          child: Stack(
            children: [
              Container(
                height: 35,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 12),
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: GRAY_20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 35),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (item.issuer != null)...[
                      _contentSellerBar(item.issuer!),
                    ],
                    SizedBox(height: 10),
                    if (image.isNotEmpty)...[
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: showImage(image, Size.square(width))
                      ),
                    ],
                    _barcodeSelectButtonBox(item),
                    _contentTitleBarFromItem(item,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      isShowAmount: false),
                    _contentDescriptionFromItem(item),
                    if (STR(item.externalUrl).isNotEmpty)
                      _contextExternalImage(STR(item.externalUrl),
                          padding: EdgeInsets.only(top: 10)),
                  ],
                ),
              )
            ]
          )
        );
      },
    );
  }

  popBankPayDetail(PurchaseModel item) {
    var priceStr = CommaIntText(INT(item.buyPrice).toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WHITE,
      builder: (context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(25),
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0.sp),
              topRight: Radius.circular(16.0.sp),
            ),
            color: WHITE,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('${TR('이체금액')}: ${item.priceText}', style: typo18bold),
              Text('${TR('은행명')}: ${item.bankName}', style: typo18bold),
              Text('${TR('계좌번호')}: ${item.bankNumber}', style: typo18bold),
            ]
          )
        );
      },
    );
  }

  _barcodeSelectButtonBox(ProductItemModel item) {
    final width = MediaQuery.of(context).size.width * 0.8;
    return StatefulBuilder(
      builder: (context, setState) {
        final isQR = prov.userItemShowQR;
        return Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: InkWell(
                      onTap: () {
                        setState(() {
                          prov.userItemShowQR = false;
                        });
                      },
                      child: Container(
                        height: 30,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(TR('바코드'),
                          style: typo14bold.copyWith(
                            color: !isQR ? GRAY_80 : GRAY_30)),
                      ),
                    )),
                    Container(
                      width: 1,
                      height: 30,
                      color: GRAY_50,
                    ),
                    Expanded(child: InkWell(
                      onTap: () {
                        setState(() {
                          prov.userItemShowQR = true;
                        });
                      },
                      child: Container(
                        height: 30,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(TR('QR'),
                          style: typo14bold.copyWith(
                            color: isQR ? GRAY_80 : GRAY_20))
                      ),
                    )),
                  ],
                ),
              ),
              if (!prov.userItemShowQR)
                showImage(
                  'assets/samples/barcode_00.png', Size(width, width / 4)),
              if (prov.userItemShowQR)
                Padding(padding: EdgeInsets.symmetric(vertical: 10),
                child :showImage(
                  'assets/samples/qr_00.png', Size.square(width / 1.5)),
                )
            ],
          )
        );
      }
    );
  }

  showPurchaseDate() {
    return Container(
      height: 55,
      padding: EdgeInsets.only(bottom: 10),
      color: WHITE,
      child: Column(
        children: [
          Row(
            children: [
              Text(prov.purchaseSearchDate, style: typo14semibold),
              Spacer(),
              PrimaryButton(
                onTap: () {
                  _showPurchaseDatePicker();
                },
                text: TR('조회 기간'),
                height: 35,
                color: WHITE,
                textStyle: typo12semibold100,
                isBorderShow: true,
                isSmallButton: true
              ),
            ],
          ),
          Spacer(),
          Divider(height: 1),
        ],
      ),
    );
  }

  showPurchaseDetail([var isShowSeller = true]) {
    final imageSize = MediaQuery.of(context).size.width;
    LOG('--> showPurchaseInfo : ${prov.selectPurchaseItem?.prodSaleId}');
    return FutureBuilder(
      future: prov.getPurchaseProductInfo(),
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          var productInfo = snapShot.data as ProductModel;
          LOG('--> productInfo : ${productInfo.toJson()}');
          return Column(
            children: [
              if (STR(productInfo.repDetailImg).isNotEmpty)
                showImage(STR(productInfo.repDetailImg),
                    Size.square(imageSize.r), fit: BoxFit.fitWidth),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isShowSeller && productInfo.seller != null)
                      _contentSellerBar(productInfo.seller!,
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
                      TR('구매일 : '),
                      style: typo14bold,
                    ),
                    Text(
                      SERVER_TIME_STR(prov.selectPurchaseItem!.txDateTime),
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
    showDateRangePicker(context: context,
      currentDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: prov.purchaseStartDate,
        end:   prov.purchaseEndDate,
      ),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      saveText: TR('선택완료'),
    ).then((range) {
      if (range != null) {
        prov.purchaseStartDate = range.start;
        prov.purchaseEndDate   = range.end.add(Duration(hours: 23, minutes: 59, seconds: 59));
        prov.refresh();
        LOG('--> date result : ${prov.purchaseStartDate} ~ ${prov.purchaseEndDate}');
      }
    });
  }

  _purchaseItem(PurchaseModel item,
    {EdgeInsets? margin, var isShowDetail = false}) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 15),
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (isShowDetail) {
                _showPurchaseItemDetail(item);
                // prov.getProductDetailFromId(STR(item.prodSaleId)).then((result) {
                //   if (result != null) {
                //     prov.selectProduct = result;
                //     Navigator.of(context).push(createAniRoute(ProductDetailScreen()));
                //   }
                // });
              }
            },
            child: Container(
                child: Row(
                  children: [
                    Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(right: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: showImage(item.itemImg ?? EMPTY_IMAGE, Size(100, 100)),
                    )
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isShowDetail)...[
                          Text(_purchaseStatusTitle(item.status),
                              style: typo14bold.copyWith(
                                  color: _purchaseStatusColor(item.status))),
                          Text(SERVER_TIME_STR(item.txDateTime), style: typo12normal),
                          SizedBox(height: 5),
                        ],
                        Text(STR(item.name), style: typo14normal.copyWith(height: 1.0)),
                        SizedBox(height: 5),
                        Text(item.priceText, style: typo14bold, textAlign: TextAlign.start),
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
                      prov.getProductDetailFromId(STR(item.prodSaleId)).then((result) {
                        if (result != null) {
                          prov.selectProduct = result;
                          Navigator.of(context).push(createAniRoute(
                            ProductDetailScreen(isCanBuy: false)));
                        }
                      });
                    },
                    child: Text(TR('상품 정보'), style: typo14semibold),
                  ),
                  Container(
                    width: 1,
                    height: 16.h,
                    color: GRAY_50,
                  ),
                  InkWell(
                    onTap: () {
                      _showPurchaseItemDetail(item);
                    },
                    child: Text(TR('구매 상세'), style: typo14semibold),
                  ),
                ],
              ),
            ),
            Divider()
          ],
        ],
      )
    );
  }

  _showPurchaseItemDetail(PurchaseModel item) {
    prov.purchaseInfo = item;
    Navigator.of(context).push(createAniRoute(PaymentDetailScreen()));
  }

  _purchaseStatusTitle(String? num) {
      switch(num) {
        case '1':
          return CD_PAY_ST.ready.title;
        case '2':
          return CD_PAY_ST.done.title;
        case '3':
          return CD_PAY_ST.verify.title;
        case '4':
          return CD_PAY_ST.complete.title;
        default:
          return CD_PAY_ST.cancel.title;
      }
  }

  _purchaseStatusColor(String? num) {
    switch(num) {
      case '1':
        return CD_PAY_ST.ready.color;
      case '2':
        return CD_PAY_ST.done.color;
      case '3':
        return CD_PAY_ST.verify.color;
      case '4':
        return CD_PAY_ST.complete.color;
      default:
        return CD_PAY_ST.cancel.color;
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  _categoryItem(String title, int index, {Function(int)? onChanged}) {
    final isSelected = index == prov.selectCategory;
    return GestureDetector(
      onTap: () {
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
        child: Text(TR(title),
          style: typo12semibold100.copyWith(
            color: isSelected ? WHITE : GRAY_80)),
      )
    );
  }

  productListItem(ProductModel item,
    {var isShowSeller = true, var isCanBuy = true, double? height}) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return VisibilityDetector(
          key: GlobalKey(),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0) {
              prov.refreshProductList(context, item.prodSaleId);
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 25),
            height: 300,
            color: WHITE,
            child: Column(
              children: [
                if (isShowSeller && item.seller != null)
                  _contentSellerBar(item.seller!,
                    padding: EdgeInsets.only(bottom: 10)),
                Expanded(
                  child: showImage(STR(item.repImg),
                  Size(double.infinity, height ?? 230)),
                ),
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

  getUserItemImage(ProductItemModel item,
    {var isShowEmpty = true}) {
    if (STR(item.img).isNotEmpty) return STR(item.img);
    var img = prov.marketRepo.getProductImgFromData(item.itemId);
    return img ?? (isShowEmpty ? EMPTY_IMAGE : '');
  }

  _userProductListItem(
      ProductItemModel item,
      {EdgeInsets? margin}) {
    final image = getUserItemImage(item);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              prov.selectUserProductItem = item;
              popUserItemDetail(item);
            },
            child: Container(
              child: Row(
                children: [
                  Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: showImage(image, Size(100, 100)),
                      )
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(STR(item.name), style: typo14bold.copyWith(height: 1.0), maxLines: 2),
                        SizedBox(height: 5),
                        Text(STR(item.desc), style: typo12normal, maxLines: 2),
                      ],
                    ),
                  ),
                ],
              )
            )
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 15),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       InkWell(
          //         onTap: () {
          //           // prov.getProductDetailFromId(STR(item.prodSaleId)).then((result) {
          //           //   if (result != null) {
          //           //     prov.selectUserProductItem = item;
          //           //     Navigator.of(context).push(createAniRoute(ProductDetailScreen()));
          //           //   }
          //           // });
          //         },
          //         child: Text(TR('상품 정보'), style: typo14semibold),
          //       ),
          //       Container(
          //         width: 1,
          //         height: 16.h,
          //         color: GRAY_50,
          //       ),
          //       InkWell(
          //         onTap: () {
          //           prov.purchaseInfo = PurchaseModel();
          //           // Navigator.of(context).push(createAniRoute(PaymentDetailScreen(
          //           //   title: '',
          //           // )));
          //         },
          //         child: Text(TR('구매 상세'), style: typo14semibold),
          //       ),
          //     ],
          //   ),
          // ),
          Divider()
        ],
      )
    );
  }

  // _userProductListItem(ProductItemModel item,
  //     {EdgeInsets? margin}) {
  //   final image = getUserItemImage(item);
  //   return Container(
  //     color: Colors.transparent,
  //     child: Column(
  //       children: [
  //         InkWell(
  //           onTap: () {
  //             prov.selectUserProductItem = item;
  //             showUserItemDetail(context, item);
  //           },
  //           child: Container(
  //             margin: EdgeInsets.symmetric(vertical: 15),
  //             child: Row(
  //               children: [
  //                 if (image.isNotEmpty)
  //                   Container(
  //                     width: 80,
  //                     height: 80,
  //                     margin: EdgeInsets.only(right: 15),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(10),
  //                       child: showImage(image, Size(80, 80)),
  //                     )
  //                   ),
  //                 Expanded(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(STR(item.name), style: typo14bold.copyWith(height: 1.0)),
  //                       SizedBox(height: 10),
  //                       Text(STR(item.desc), style: typo12normal),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ),
  //         Divider(height: 1)
  //       ],
  //     )
  //   );
  // }

  _contentSellerBar(SellerModel info, {EdgeInsets? padding}) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      closedBuilder: (context, builder) {
        return Container(
          color: WHITE,
          padding: padding,
          child: Row(
            children: [
              if (STR(info.pfImg).isNotEmpty)...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(PROFILE_RADIUS_S),
                  child: showImage(STR(info.pfImg),
                    Size.square(PROFILE_RADIUS_S),
                    fit: BoxFit.fill),
                ),
                SizedBox(width: 10),
              ],
              if (STR(info.pfImg).isEmpty)...[
                SvgPicture.asset('assets/svg/icon_profile_00.svg',
                  width: PROFILE_RADIUS_S,
                  height: PROFILE_RADIUS_S, fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(GRAY_20, BlendMode.srcIn),
                ),
                SizedBox(width: 10),
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
        return ProfileTargetScreen(info);
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
            Container(
              width:  PROFILE_RADIUS,
              height: PROFILE_RADIUS,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: GRAY_70)
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PROFILE_RADIUS.r),
                  child: showImage(STR(seller.pfImg),
                    Size.square(PROFILE_RADIUS), fit: BoxFit.fill),
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
          if (STR(seller.pfImg).isEmpty)...[
            SvgPicture.asset('assets/svg/icon_profile_00.svg',
              width: PROFILE_RADIUS,
              height: PROFILE_RADIUS,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(GRAY_20, BlendMode.srcIn),
            ),
            SizedBox(width: 10),
          ],
          // SizedBox(width: 20),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _contentFollowBox(TR('팔로워'), CommaIntText(item.sellerFollower)),
          //       _contentFollowBox(TR('팔로잉'), CommaIntText(item.sellerFollowing)),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  _contentSellerDescBox(SellerModel seller, {EdgeInsets? padding}) {
    if (STR(seller.description).isNotEmpty) {
      return Container(
        padding: padding,
        child: Text(STR(seller.description), style: typo14normal,
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
    var priceStr = CommaIntText(INT(item.itemPrice).toString());
    var unitStr = ' ${item.priceUnitText}';
    var amountStr = '[${TR('수량')} ${item.amountText}]';
    return _contentTitleTextBar(
      STR(item.name),
      price: priceStr,
      unit: unitStr,
      amount: amountStr,
      padding: padding,
      isShowAmount: isShowAmount
    );
  }

  _contentTitleBarFromItem(ProductItemModel item, {EdgeInsets? padding, var isShowAmount = true}) {
    return _contentTitleTextBar(
        STR(item.name),
        padding: padding,
        isShowAmount: isShowAmount
    );
  }

  _contentTitleTextBar(String title,
    {String? price, String? unit, String? amount, EdgeInsets? padding, var isShowAmount = true}) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(title, style: titleStyle),
          Row(
            children: [
              if (price != null)...[
                Text(price, style: priceStyle),
                if (unit != null)
                  Text(unit, style: priceStyle),
              ],
              if (isShowAmount && amount != null)...[
                SizedBox(width: 10),
                Text(amount, style: descStyle),
              ],
            ],
          )
        ],
      ),
    );
  }

  _contextExternalImage(String imageUrl, {EdgeInsets? padding}) {
    return FutureBuilder(
      future: getNetworkImageInfo(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var info = snapshot.data as NetworkImageInfo;
          return Container(
            padding: padding,
            height: info.size?.height,
            child: showDetailTab(imageUrl, height: info.size?.height)
          );
        } else {
          return showLoadingItem(30);
        }
      }
    );
  }

  _contentDescription(ProductModel item, {EdgeInsets? padding}) {
    return _contentDescriptionStr(
        STR(item.description), desc2: item.description2, padding: padding);
  }

  _contentDescriptionFromItem(ProductItemModel item, {EdgeInsets? padding}) {
    return _contentDescriptionStr(
        STR(item.desc), desc2: item.desc2, padding: padding);
  }

  _contentDescriptionStr(String desc, {String? desc2, EdgeInsets? padding}) {
    return Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: descStyle),
            if (STR(desc2).isNotEmpty)...[
              SizedBox(height: 10),
              Text(STR(desc2), style: descStyle),
            ],
            if (STR(prov.optionDesc).isNotEmpty || STR(prov.optionDesc2).isNotEmpty)...[
              Divider(height: 50),
            ],
            if (STR(prov.optionDesc).isNotEmpty)...[
              Text(STR(prov.optionDesc), style: descStyle),
              SizedBox(height: 10),
            ],
            if (STR(prov.optionDesc2).isNotEmpty)...[
              Text(STR(prov.optionDesc2), style: descStyle),
            ],
          ],
        )
    );
  }

  _optionListItem(ProductItemModel option, int index,
    {var isCanSelect = false, EdgeInsets? padding, String? image}) {
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
                child: showImage(image ?? STR(option.img), Size.zero, fit: BoxFit.cover),
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


  _userOptionListItem(ProductItemModel item, int index,
      {EdgeInsets? padding, String? image}) {
    return InkWell(
      onTap: () {
        prov.selectUserProductItem = item;
        popUserItemDetail(item);
      },
      child: Container(
        padding: padding,
        child: Stack(
          children: [
            SizedBox.expand(
              child: showImage(image ?? STR(item.img), Size.zero, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 5,
              left: 3,
              child: Text(STR(item.name),
                style: typo12shadowR.copyWith(fontSize: 10), maxLines: 2),
            ),
          ],
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
          if (prov.optionPic != null)
            Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: showImage(STR(prov.optionPic), Size(100, 100)),
                )
            ),
          if (prov.optionPic == null && prov.detailPic != null)
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
                // Text(TR('TICKET'), style: typo14bold),
                // if (item.edition != null)...[
                //   Row(
                //     children: [
                //       Text(TR('에디션'), style: typo14medium),
                //       Spacer(),
                //       Text(TR(item.edition!), style: typo14medium),
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
    final height = 100.0;
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            text: TR('옵션 선택'),
          ),
          Spacer(),
          // if (prov.optionIndex >= 0)...[
          //   Container(
          //     width:  height / 2,
          //     height: height,
          //     margin: EdgeInsets.only(right: 5),
          //     child: SvgPicture.asset('assets/svg/sub_line_00.svg',
          //       fit: BoxFit.fitHeight,
          //       colorFilter: ColorFilter.mode(GRAY_40, BlendMode.srcIn)
          //     ),
          //   ),
          // ],
          // Expanded(child: Column(
          //   children: [
          //     if (prov.optionIndex >= 0)...[
          //       Row(
          //         children: [
          //           Container(
          //             width:  height,
          //             height: height,
          //             margin: EdgeInsets.only(right: 15),
          //             child: ClipRRect(
          //               borderRadius: BorderRadius.circular(10),
          //               child: showImage(STR(prov.optionPic),
          //                 Size.square(height), fit: BoxFit.fitHeight),
          //             )
          //           ),
          //           Text(STR(prov.optionDesc), style: typo16regular),
          //         ],
          //       ),
          //       SizedBox(height: 10),
          //     ],
          //     if (prov.optionIndex < 0)...[
          //       SizedBox(height: 14),
          //     ],
          //     Row(
          //       children: [
          //         PrimaryButton(
          //           onTap: () {
          //             Navigator.of(context).push(createAniRoute(ItemSelectScreen())).then((index) {
          //               if (index != null) {
          //                 prov.setOptionIndex(index);
          //               }
          //             });
          //           },
          //           width: height,
          //           round: 8,
          //           color: Colors.white,
          //           padding: EdgeInsets.zero,
          //           isBorderShow: true,
          //           isSmallButton: true,
          //           textStyle: typo14bold.copyWith(color: prov.optionIndex >= 0 ? GRAY_80 : Colors.red),
          //           text: TR('옵션 선택'),
          //         ),
          //         Spacer(),
          //       ],
          //     ),
          //   ],
          // ))
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
              text: TR('팔로우'),
            )
        ),
      ],
    );
  }
}