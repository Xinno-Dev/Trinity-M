import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import '../../../../common/const/widget/disabled_button.dart';
import '../../../../domain/model/coin_model.dart';
import '../../../../services/mdl_rpc_service.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../common/provider/language_provider.dart';
import '../../../domain/model/network_model.dart';
import '../../../services/json_rpc_service.dart';

enum TokenInputType {
  address,
  chainCode,
  channel,
}


class TokenAddScreen extends ConsumerStatefulWidget {
  TokenAddScreen(
    this.networkModel,
    this.walletAddress,
    {Key? key}) : super(key: key);
  static String get routeName => 'tokenAddScreen';

  NetworkModel networkModel;
  String walletAddress;

  @override
  ConsumerState<TokenAddScreen> createState() => _TokenAddScreenState();
}

class _TokenAddScreenState extends ConsumerState<TokenAddScreen> {
  var isCheckDone = false;
  var isEnableCheck = IS_DEV_MODE;
  late CoinModel newCoin;
  // IS_DEV_MODE ? '0xd906925fd6973ab8f99410f4605676c16a216099' : '');
  // late var _controller = TextEditingController(text: newCoin.contract);
  final _textController = List.generate(TokenInputType.values.length, (index) => TextEditingController());

  _enableMDLCheck() {
    return STR(newCoin.chainCode).isNotEmpty &&
           STR(newCoin.channel).isNotEmpty;
  }

  @override
  void initState() {
    newCoin = widget.networkModel.isRigo ?
      CoinModel.newCoin(IS_DEV_MODE ? '0xd906925fd6973ab8f99410f4605676c16a216099' : '') :
      CoinModel.newMDLCoin(IS_DEV_MODE ? 'mdl1-ch1-mdm' : '', widget.networkModel.channel);
    _textController[TokenInputType.address.index].text = newCoin.contract ?? '';
    _textController[TokenInputType.chainCode.index].text = newCoin.chainCode ?? '';
    _textController[TokenInputType.channel.index].text = newCoin.channel ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          leadingWidth: 40.w,
          titleSpacing: 0,
          centerTitle: true,
          title: Text(TR(context, isCheckDone ? '토큰 정보 확인' : '토큰 주소 조회'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Expanded(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.networkModel.isRigo)...[
                      Text(TR(context,
                        '\'Ox\' 문자를 제외한 토큰 주소를 입력해 주세요.'),
                        maxLines: 2,
                        style: typo16bold),
                      showTextEdit('토큰 주소',
                        newCoin.contract,
                        hint: '',
                        controller: _textController[TokenInputType.address.index],
                        onChanged: (value) {
                          setState(() {
                            newCoin.contract = value;
                            isCheckDone = false;
                            isEnableCheck = false;
                            log('--> $value');
                            if (value.length == 40 && value.substring(0, 2) != '0x') {
                              newCoin.contract = '0x$value';
                              isEnableCheck = true;
                            } else if (value.length == 42) {
                              isEnableCheck = value.substring(0, 2) == '0x';
                            }
                          });
                        }
                      ),
                    ],
                    if (!widget.networkModel.isRigo)...[
                      Text(TR(context, '체인코드를 입력해 주세요.'),
                        maxLines: 2,
                        style: typo16bold),
                      showTextEdit('체인코드',
                        newCoin.chainCode,
                        hint: '',
                        controller: _textController[TokenInputType.chainCode.index],
                        onChanged: (value) {
                          setState(() {
                            newCoin.chainCode = value;
                            isEnableCheck = _enableMDLCheck();
                          });
                        }
                      ),
                    ],
                    if (isCheckDone)...[
                      showTextEdit('채널'     , newCoin.channel, isEnabled: false),
                      showTextEdit('토큰 이름' , newCoin.name   , isEnabled: false),
                      showTextEdit('토큰 심볼' , newCoin.symbol , isEnabled: false),
                      showTextEdit('토큰 소수점', newCoin.decimal, isEnabled: false),
                    ],
                    // if (!isCheckDone)...[
                    //   InkWell(
                    //     onTap: () {
                    //       showREPDialog();
                    //     },
                    //     child: Row(
                    //       children: [
                    //         Text(TR(context, 'REP-20 기반의 토큰 추가만 지원합니다.'),
                    //             style: typo14medium.copyWith(color: SECONDARY_90)),
                    //         SizedBox(width: 5),
                    //         SvgPicture.asset('assets/svg/icon_question.svg'),
                    //       ],
                    //     ),
                    //   )
                    // ]
                  ]
                )
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: isEnableCheck ?
                PrimaryButton(
                  text: TR(context, isCheckDone ? '추 가' : '조 회'),
                  onTap: () async {
                    if (isCheckDone) {
                      showConfirmDialog(newCoin.name).then((result) {
                        if (result != null && result) {
                          // newCoin.code = 'test1'; // for Dev..
                          newCoin.mainNetChainId = widget.networkModel.chainId;
                          newCoin.walletAddress  = widget.walletAddress;
                          log('---> token add : [${newCoin.toString()}]');
                          ref.read(coinProvider).addNewCoin(newCoin);
                          context.pop(true);
                        }
                      });
                    } else {
                      isCheckDone = false;
                      if (widget.networkModel.isRigo) {
                        newCoin.name = await JsonRpcService()
                            .runVmCall(widget.networkModel, 'name',
                            newCoin.contract!) ?? '';
                        if (newCoin.name.isNotEmpty) {
                          newCoin.decimal = await JsonRpcService()
                              .runVmCall(widget.networkModel, 'decimals',
                              newCoin.contract!) ?? '';
                          newCoin.symbol = await JsonRpcService()
                              .runVmCall(widget.networkModel, 'symbol',
                              newCoin.contract!) ?? '';
                          var detail = await JsonRpcService()
                              .getTokenDetail(
                              widget.networkModel, newCoin.contract!);
                          // newCoin.decimal = '4';
                          // detail = '{"image": {"logo": "https://assets.coingecko.com/coins/images/11846/small/mStable.png?1696511717"}}';
                          if (STR(detail).isNotEmpty) {
                            try {
                              var symbolJson = jsonDecode(detail);
                              var imageJson = symbolJson['image'];
                              if (imageJson != null) {
                                newCoin.logo      = imageJson['logo'];
                                newCoin.logo_flat = imageJson['logo_flat'];
                                newCoin.logo_hash = imageJson['logo_hash'];
                              }
                            } catch (e) {
                              log('---> newCoin.logo error : $e');
                            }
                          }
                        }
                        log('---> add token info : ${newCoin.toJson()}');
                        isCheckDone =
                            newCoin.name.isNotEmpty &&
                            newCoin.symbol.isNotEmpty &&
                            newCoin.decimal!.isNotEmpty;
                      } else {
                        var result = await MdlRpcService().getTokenInfo(
                            widget.networkModel,
                            newCoin.chainCode!,
                            newCoin.channel!);
                        if (result != null) {
                          newCoin.name    = STR(result['name']);
                          newCoin.symbol  = STR(result['symbol']);
                          newCoin.decimal = STR(result['decimals']);
                          isCheckDone = newCoin.name.isNotEmpty &&
                              newCoin.symbol.isNotEmpty &&
                              INT(newCoin.decimal) > 0;
                          log('---> add MDL token info : $isCheckDone');
                        }
                      }
                      setState(() {
                        if (!isCheckDone) {
                          showSimpleDialog(context, TR(context,
                              '올바르지 않은 토큰 주소입니다.\n주소를 다시 확인해 주세요.'),
                              'assets/svg/icon_error.svg');
                        }
                      });
                    }
                  }
                ) : DisabledButton(
                  text: TR(context, isCheckDone ? '추 가' : '조 회'),
                )
              )
            ]
          ),
        )
      )
    );
  }

  showTextEdit(
    title, desc,
    {TextEditingController? controller, String? hint, bool isEnabled = true, Function(String)? onChanged})
  {
    // if (desc != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     controller.selection =
    //         TextSelection.fromPosition(TextPosition(offset: desc.length));
    //   });
    // }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TR(context, title), style: typo14medium),
          SizedBox(height: 10.h),
          TextField(
            controller: controller ?? TextEditingController(text: desc ?? ''),
            style: isEnabled ? typo14medium : typo14disable,
            enabled: isEnabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(width: 1, color: Colors.yellow),
              ),
              hintText: hint,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w)
            ),
            maxLines: 1,
            scrollPadding: EdgeInsets.only(bottom: 2000.h),
            onChanged: onChanged,
          ),
        ]
      )
    );
  }

  showConfirmDialog(tokenName) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          content: Text(
            ref.read(languageProvider).isKor ?
            TR(context, '\'$tokenName\' 토큰을\n추가하시겠습니까?') :
            TR(context, 'Would you like to\nadd a \'$tokenName\' token?'),
            style: typo16dialog, textAlign: TextAlign.center),
          contentPadding: EdgeInsets.only(top: 40.h, bottom: 10.h),
          actionsPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Container(
              height: 45.h,
              child: Row(
                children: [
                  Expanded(child:
                  OutlinedButton(
                    onPressed: context.pop,
                    child: Text(
                      TR(context, '취소'),
                      style: typo12semibold100,
                    ),
                    style: darkBorderButtonStyle,
                  )),
                  SizedBox(width: 5.w),
                  Expanded(child:
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      TR(context, '추가'),
                      style: typo12semibold100.copyWith(color: WHITE),
                    ),
                    style: primaryBorderButtonStyle,
                  ))
                ],
              ),
            )
          ],
        ),
    );
  }

  showREPDialog() async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          content: Text(
            ref.read(languageProvider).isKor ?
            TR(context, '토큰 추가 기능은 리고 메인 네트워크에서\n발행된 토큰(REP-20) 만 지원됩니다.') :
            TR(context, 'The token addition feature only supports tokens\n(REP-20) issued on the Rigo main network.'),
            style: typo12dialog, textAlign: TextAlign.center),
          contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          actionsPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Container(
              height: 45.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        TR(context, '확인'),
                        style: typo12semibold100,
                      ),
                      style: darkBorderButtonStyle,
                    )
                  )
                ],
              ),
            )
          ],
        ),
    );
  }}
