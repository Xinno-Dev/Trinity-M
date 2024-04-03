import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/provider/firebase_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_list_screen.dart';
import 'package:larba_00/services/mdl_rpc_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart' as provider;
import 'package:uuid/uuid.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/custom_text_edit.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/language_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../services/json_rpc_service.dart';

class NetworkInputScreen extends ConsumerStatefulWidget {
  NetworkInputScreen(this.addType, this.newNetwork, {Key? key}) : super(key: key);
  static String get routeName => 'NetworkInputScreen';
  NetworkAddType addType;
  NetworkModel newNetwork;

  @override
  ConsumerState<NetworkInputScreen> createState() => _NetworkInputScreenState();
}

enum InputType {
  name,
  httpUrl,
  chainId,
  channel,
  symbol,
  explorer,
}

class _NetworkInputScreenState extends ConsumerState<NetworkInputScreen> {
  var isCheckDone     = false;
  var isNameValidated = false;
  var isIdValidated   = false;
  late var isEnableCheck = IS_DEV_MODE ? widget.addType == NetworkAddType.auto : false;
  final _controller = List.generate(InputType.values.length, (index) => TextEditingController());
  final _scrollController = ScrollController();
  late final List<DropdownMenuItem> _channelList = [channelItem('ch1', 0), channelItem('ch2', 1)];

  get _nameValidateError {
    return !isNameValidated ? widget.newNetwork.name.isEmpty ?
    '네트워크 이름을 입력해 주세요.' : '이미 등록된 네트워크 이름입니다.' : null;
  }

  DropdownMenuItem channelItem(text, value) {
    return DropdownMenuItem(
      child: Text(text),
      value: value,
    );
  }

  _refreshCheck() {
    setState(() {
      isNameValidated = widget.newNetwork.name.isNotEmpty &&
          provider.Provider.of<NetworkProvider>(context, listen: false)
              .checkNetworkName(widget.newNetwork.name);
      isIdValidated = provider.Provider.of<NetworkProvider>(context, listen: false)
          .checkNetwork(widget.newNetwork);

      isEnableCheck = isNameValidated &&
          // isEnableCheck = isNameValidated && isIdValidated &&
          widget.newNetwork.name.isNotEmpty &&
          widget.newNetwork.httpUrl.isNotEmpty &&
          widget.newNetwork.chainId.isNotEmpty &&
          (widget.newNetwork.isRigo || STR(widget.newNetwork.channel).isNotEmpty) &&
          STR(widget.newNetwork.symbol).isNotEmpty;
      LOG('--> _refreshCheck : $isCheckDone / $isNameValidated => $isEnableCheck');
    });
  }

  _initData() {
    _controller[InputType.name.index      ].text = widget.newNetwork.name;
    _controller[InputType.httpUrl.index   ].text = widget.newNetwork.httpUrl;
    _controller[InputType.chainId.index   ].text = widget.newNetwork.chainId;
    _controller[InputType.channel.index   ].text = widget.newNetwork.channel ?? '';
    _controller[InputType.symbol.index    ].text = widget.newNetwork.symbol ?? '';
    _controller[InputType.explorer.index  ].text = widget.newNetwork.exploreUrl ?? '';
    // for Dev..
    // isEnableCheck = IS_DEV_MODE ? widget.addType == NetworkAddType.auto : false;
    _refreshCheck();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    // if (isCheckDone) {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     isIdValidated = newNetwork.chainId.isNotEmpty &&
    //       provider.Provider.of<NetworkProvider>(context, listen: false)
    //       .checkNetworkID(newNetwork.chainId);
    //     LOG('--> isIdValidated : ${newNetwork.chainId} => $isIdValidated');
    //     if (!isIdValidated) {
    //       showResultDialog(context, _chainIdValidateError).then((_) {
    //         isCheckDone = false;
    //         _refreshCheck();
    //       });
    //     }
    //   });
    // }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: WHITE,
            leading: CustomBackButton(
              onPressed: () {
                if (isCheckDone) {
                  isCheckDone = false;
                  _refreshCheck();
                } else {
                  context.pop();
                }
              },
            ),
            leadingWidth: 40.w,
            titleSpacing: 0,
            centerTitle: true,
            title: Text(TR(context,
              widget.addType == NetworkAddType.auto ?
              '네트워크 정보 확인' : '네트워크 수동 추가'),
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
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TR(context, '다음 정보를 입력해 주세요.'), style: typo16bold),
                        showTextEdit('RPC 주소',
                            controller: _controller[InputType.httpUrl.index],
                            onChanged: (value) {
                              widget.newNetwork.httpUrl = value;
                              _refreshCheck();
                            }),
                        showTextEdit('채널 이름',
                            controller: _controller[InputType.channel.index],
                            onChanged: (value) {
                              widget.newNetwork.channel = value;
                              _refreshCheck();
                            }),
                        showTextEdit('체인 아이디',
                            controller: _controller[InputType.chainId.index],
                            onChanged: (value) {
                              widget.newNetwork.chainId = value;
                              _refreshCheck();
                            }),
                        // showTextEdit('통화 기호',
                        //     controller: _controller[InputType.symbol.index],
                        //     onChanged: (value) {
                        //       widget.newNetwork.symbol = value;
                        //       _refreshCheck();
                        //     }),
                        showTextEdit('네트워크 이름',
                            controller: _controller[InputType.name.index],
                            onChanged: (value) {
                              widget.newNetwork.name = value;
                              _refreshCheck();
                            }),
                        if (widget.newNetwork.isRigo)
                          showTextEdit('블록 탐색기 주소(선택)',
                              controller: _controller[InputType.explorer.index],
                              onChanged: (value) {
                                widget.newNetwork.exploreUrl = value;
                                _refreshCheck();
                              }),
                          SizedBox(height: 300)
                        ]
                      )
                    )
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: isEnableCheck ?
                    PrimaryButton(
                      text: TR(context, '추 가'),
                      onTap: () async {
                        if (widget.addType == NetworkAddType.manual || isCheckDone) {
                          // 수동 추가 & 자동 추가 입력
                          if (!isEnableCheck) {
                            showResultDialog(context, TR(context, '입력 내용을 확인해 주세요.'));
                            return;
                          }
                          showConfirmDialog(widget.newNetwork.name).then((result) async {
                            if (result != null && result) {
                              // final validate = await ref.read(jsonRpcServiceProvider)
                              //   .validateNetwork(newNetwork);
                              var validate = false;
                              if (!widget.newNetwork.isRigo) {
                                // RIGO 가 아닐경우 네트워크 체크..
                                validate = await MdlRpcService()
                                    .validateNetwork(widget.newNetwork);
                              } else {
                                final chainId = await JsonRpcService()
                                    .getNetworkInfo(widget.newNetwork);
                                validate = STR(chainId).isNotEmpty;
                              }
                              if (validate) {
                                // TODO: 네트워크, 월렛 주소 통합관리 필요....
                                provider.Provider.of<NetworkProvider>(context, listen: false)
                                    .addNewNetwork(widget.newNetwork);
                                ref.read(coinProvider).setNetworkFromId(widget.newNetwork.id);
                                context.pop(true);
                              } else {
                                showResultDialog(context, TR(context, '잘못된 네트워크입니다.'));
                              }
                            }
                          });
                        } else {
                          // 자동 추가 체크
                          // RIGO first
                          isCheckDone = false;
                          final chainId = await JsonRpcService()
                              .getNetworkInfo(widget.newNetwork);
                          if (STR(chainId).isNotEmpty) {
                            LOG('---> newNetwork chainId : $chainId');
                            widget.newNetwork.id           = Uuid().v4();
                            widget.newNetwork.url          = widget.newNetwork.createUrlFromHttps;
                            widget.newNetwork.chainId      = chainId!;
                            widget.newNetwork.name         = 'RIGO $chainId';
                            widget.newNetwork.symbol       = 'RIGO';
                            widget.newNetwork.networkType  = 0;
                            print('---> checkResult : ${widget.newNetwork.toJson()}');
                            isCheckDone = widget.newNetwork.isValidated;
                          } else {
                            final checkNetList = await ref.read(firebaseProvider)
                                .getMDLNetworkCheckUrl();
                            for (var item in checkNetList) {
                              LOG('---> checkNetList : ${item.toJson()}');
                              final checkResult = await MdlRpcService()
                                  .checkNetworkAuto(item.url, item.method,
                                  url: widget.newNetwork.httpUrl,
                                  chainId: widget.newNetwork.chainId);
                              if (checkResult != null) {
                                widget.newNetwork.id           = Uuid().v4();
                                widget.newNetwork.httpUrl      = STR(checkResult['url']);
                                widget.newNetwork.chainId      = STR(checkResult['chainId']);
                                widget.newNetwork.symbol       = STR(checkResult['chainType']);
                                widget.newNetwork.name         = STR(checkResult['network']);
                                widget.newNetwork.channel      = STR(checkResult['channel']);
                                widget.newNetwork.networkType  = 1;
                                print(
                                    '---> checkResult : ${widget.newNetwork.toJson()}');
                                isCheckDone = widget.newNetwork.isValidated;
                                break;
                              }
                            }
                          }
                          _initData();
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
      )
    );
  }

  showTextEdit(
      title, {
        String? desc,
        String? error,
        TextEditingController? controller, String? hint,
        bool isEnabled = true,
        bool isShowOutline = true,
        Function(String)? onChanged,
        Function()? onTap,
      }) {
    return CustomTextEdit(
      context,
      title,
      desc: desc,
      error: error,
      controller: controller,
      hint: hint,
      isEnabled: isEnabled,
      isShowOutline:
      isShowOutline,
      onChanged: onChanged,
      onTap: onTap,
    );
  }

  showTextSelect(
      title, List<DropdownMenuItem> list, {
        String? desc,
        TextEditingController? controller, String? hint,
        Function(String)? onChanged,
        Function(String)? onSelected,
      }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: showTextEdit(title,
          desc: desc,
          controller: controller,
          hint: hint,
          isEnabled: false,
          isShowOutline: true,
          onChanged: onChanged,
        ),
        value: 0,
        itemHeight: kMinInteractiveDimension,
        dropdownWidth: 140,
        buttonHeight: 30,
        buttonWidth: 30,
        itemPadding: const EdgeInsets.only(left: 12, right: 12),
        offset: const Offset(0, 8),
        items: list,
        onChanged: (value) {
          LOG('---> selected item : $value');
          var selected = value as DropdownMenuItem;
          if (onSelected != null) onSelected(selected.value);
        },
      ),
    );
  }

  showConfirmDialog(tokenName) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            content: Text(
                ref.read(languageProvider).isKor ?
                TR(context, '\'$tokenName\'\n네트워크를 추가하시겠습니까?') :
                TR(context, 'Would you like to add a\n\'$tokenName\' network?'),
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
}
