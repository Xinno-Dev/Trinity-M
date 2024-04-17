import 'dart:convert';

import 'package:larba_00/common/const/widget/dialog_utils.dart';
import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/provider/firebase_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_channel_screen.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_list_screen.dart';
import 'package:larba_00/services/mdl_rpc_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_multi_formatter/extensions/string_extensions.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
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

class NetworkAddScreen extends ConsumerStatefulWidget {
  NetworkAddScreen(this.addType, {Key? key}) : super(key: key);
  static String get routeName => 'NetworkAddScreen';
  NetworkAddType addType;

  @override
  ConsumerState<NetworkAddScreen> createState() => _NetworkAddScreenState();
}

enum NetworkInputType {
  name,
  url,
  httpUrl,
  chainId,
  channel,
  symbol,
  explorer,
}

class _NetworkAddScreenState extends ConsumerState<NetworkAddScreen> {
  var isCheckDone     = false;
  var isNameValidated = false;
  var isIdValidated   = false;
  late var isEnableCheck = IS_DEV_MODE ? widget.addType == NetworkAddType.auto : false;
  NetworkModel newNetwork = IS_DEV_MODE ?
    NetworkModel.create(
      // httpUrl: 'http://3.38.199.57:3001', // MDL
      url: TEST_NET_URI,
      httpUrl: TEST_HTTP_URL, // RIGO
      // chainId: 'mdl1-ch1',
      // name: 'MDL Network',
      // channel: 'ch1',
      // chainCode: 'mdl1-ch1-mdm',
      // symbol: 'MDL'
    ) : NetworkModel.create();

  final _controller = List.generate(NetworkInputType.values.length, (index) => TextEditingController());
  final _scrollController = ScrollController();
  // late final List<DropdownMenuItem> _channelList = [channelItem('ch1', 0), channelItem('ch2', 1)];

  get _searchValidate {
    return newNetwork.httpUrl.isNotEmpty;
  }

  get _nameValidateError {
    return !isNameValidated ? newNetwork.name.isEmpty ?
    TR(context, '네트워크 이름을 입력해 주세요.') : TR(context, '이미 등록된 네트워크 이름입니다.') : null;
  }

  get _chainIdValidateError {
    return !isIdValidated ? TR(context, '이미 등록된 네트워크입니다.') : null;
  }

  DropdownMenuItem channelItem(text, value) {
    return DropdownMenuItem(
      child: Text(text),
      value: value,
    );
  }

  _refreshCheck() {
    setState(() {
      isNameValidated = newNetwork.name.isNotEmpty &&
          provider.Provider.of<NetworkProvider>(context, listen: false)
          .checkNetworkName(newNetwork.name);
      isIdValidated = provider.Provider.of<NetworkProvider>(context, listen: false)
          .checkNetwork(newNetwork);

      if (widget.addType == NetworkAddType.manual || isCheckDone) {
        isEnableCheck = !isDuplicated && isNameValidated &&
        // isEnableCheck = isNameValidated && isIdValidated &&
            newNetwork.name.isNotEmpty &&
            newNetwork.httpUrl.isNotEmpty &&
            newNetwork.chainId.isNotEmpty &&
            (newNetwork.isRigo || STR(newNetwork.channel).isNotEmpty) &&
            STR(newNetwork.symbol).isNotEmpty;
      } else {
        isEnableCheck = _searchValidate;
      }
      LOG('--> _refreshCheck : $isCheckDone / ${newNetwork.channel} => $isEnableCheck');
    });
  }

  _initData() {
    _controller[NetworkInputType.name.index     ].text = newNetwork.name;
    _controller[NetworkInputType.url.index      ].text = newNetwork.url;
    _controller[NetworkInputType.httpUrl.index  ].text = newNetwork.httpUrl;
    _controller[NetworkInputType.chainId.index  ].text = newNetwork.chainId;
    _controller[NetworkInputType.channel.index  ].text = newNetwork.channel ?? '';
    _controller[NetworkInputType.symbol.index   ].text = newNetwork.symbol ?? '';
    _controller[NetworkInputType.explorer.index ].text = newNetwork.exploreUrl ?? '';
    // for Dev..
    // isEnableCheck = IS_DEV_MODE ? widget.addType == NetworkAddType.auto : false;
    _refreshCheck();
  }

  _showChannelSelect() {
    if (newNetwork.chainList != null) {
      Navigator.of(context).push(
          createAniRoute(NetworkChannelScreen(newNetwork.chainList!, ''))
      ).then((result) {
        LOG('---> NetworkChannelScreen result : $result');
        if (STR(result).isNotEmpty) {
          newNetwork.channel  = result['channel'];
          newNetwork.chainId  = result['chainId'];
          newNetwork.symbol   = result['chainType'];
          newNetwork.name     = result['network'];
          newNetwork.nameOrg  = result['network'];

          _controller[NetworkInputType.channel.index].text = newNetwork.channel ?? '';
          _controller[NetworkInputType.chainId.index].text = newNetwork.chainId;
          _controller[NetworkInputType.symbol.index ].text = newNetwork.symbol ?? '';
          _controller[NetworkInputType.name.index   ].text = newNetwork.name;

          isCheckDone = true;
          _refreshCheck();
        }
      });
    }
  }

  get isExplorerError {
    return STR(newNetwork.exploreUrl).isNotEmpty &&
        !STR(newNetwork.exploreUrl).contains('http');
  }

  get isDuplicated {
   return !provider.Provider.of<NetworkProvider>(context, listen: false)
        .checkNetwork(newNetwork);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(TR(context, '네트워크 추가'),
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
                    child: widget.addType == NetworkAddType.auto ?
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCheckDone)...[
                          Text(TR(context, 'RPC 주소를 입력해 주세요.'),
                            maxLines: 2,
                            style: typo16bold),
                          // if (newNetwork.isRigo)
                          //   showTextEdit('RPC 소켓 주소',
                          //     controller: _controller[NetworkInputType.url.index],
                          //     onChanged: (value) {
                          //       setState(() {
                          //         newNetwork.url = value;
                          //         isCheckDone = false;
                          //         _refreshCheck();
                          //       });
                          //     }
                          //   ),
                          showTextEdit('RPC 주소',
                            controller: _controller[NetworkInputType.httpUrl.index],
                            onChanged: (value) {
                              setState(() {
                                newNetwork.httpUrl = value;
                                isCheckDone = false;
                                _refreshCheck();
                              });
                            }
                          ),
                        ],
                        if (isCheckDone)...[
                          // showTextEdit('체인 코드', desc: newNetwork.chainCode, isEnabled: false, isShowOutline: false),
                          // if (newNetwork.isRigo)
                          //   showTextEdit('RPC 소켓 주소',
                          //     desc: newNetwork.url, isEnabled: false, isShowOutline: false),
                          showTextEdit('RPC 주소',
                              desc: newNetwork.httpUrl, isEnabled: false, isShowOutline: false),
                          if (!newNetwork.isRigo)...[
                            showTextEdit('채널 이름',
                              isEnabled: false,
                              controller: _controller[NetworkInputType.channel.index],
                              onTap: () {
                                _showChannelSelect();
                              }),
                            showTextEdit('체인 아이디', desc: newNetwork.chainId, isEnabled: false, isShowOutline: false),
                            // showTextEdit('통화 기호', desc: newNetwork.symbol, isEnabled: false, isShowOutline: false),
                          ],
                          // showTextEdit('통화 기호' , desc: newNetwork.symbol, isEnabled: false, isShowOutline: false),
                          showTextEdit('네트워크 이름',
                            error: _nameValidateError,
                            controller: _controller[NetworkInputType.name.index],
                            onChanged: (value) {
                              newNetwork.name = value;
                              _refreshCheck();
                            }),
                          if (newNetwork.isRigo)
                            showTextEdit('블록 탐색기 주소(선택)',
                              controller: _controller[NetworkInputType.explorer.index],
                              onChanged: (value) {
                                newNetwork.exploreUrl = value;
                                _refreshCheck();
                            }),
                          if (isExplorerError)
                            _buildErrorItem(TR(context, '블록 탐색기 주소를 확인해 주세요.')),
                          if (isDuplicated)...[
                            SizedBox(height: 20),
                            _buildErrorItem(TR(context, '* 이미 등록된 네트워크입니다.')),
                          ]
                        ],
                        // if (!isCheckDone)...[
                        //   Text(TR(context, 'MDL 기반의 네트워크 추가만 지원합니다.'),
                        //       style: typo14medium.copyWith(color: SECONDARY_90)),
                        // ],
                        SizedBox(height: 500)
                      ]
                    ) : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TR(context, '다음 정보를 입력해 주세요.'), style: typo16bold),
                        showTextEdit('RPC 주소',
                          controller: _controller[NetworkInputType.httpUrl.index],
                          onChanged: (value) {
                            newNetwork.httpUrl = value;
                            _refreshCheck();
                        }),
                        showTextEdit('채널 이름',
                            controller: _controller[NetworkInputType.channel.index],
                            onChanged: (value) {
                              newNetwork.channel = value;
                              _refreshCheck();
                            }),
                        showTextEdit('체인 아이디',
                          controller: _controller[NetworkInputType.chainId.index],
                          onChanged: (value) {
                            newNetwork.chainId = value;
                            _refreshCheck();
                        }),
                        // showTextEdit('통화 기호',
                        //   controller: _controller[NetworkInputType.symbol.index],
                        //   onChanged: (value) {
                        //     newNetwork.symbol = value;
                        //     _refreshCheck();
                        // }),
                        showTextEdit('네트워크 이름',
                          controller: _controller[NetworkInputType.name.index],
                          onChanged: (value) {
                            newNetwork.name = value;
                            _refreshCheck();
                        }),
                        if (newNetwork.isRigo)
                          showTextEdit('블록 탐색기 주소(선택)',
                            controller: _controller[NetworkInputType.explorer.index],
                            onChanged: (value) {
                              newNetwork.exploreUrl = value;
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
                    text: TR(context,
                      (widget.addType == NetworkAddType.manual || isCheckDone) ?
                      '추 가' : '조 회'),
                    onTap: () async {
                      if (widget.addType == NetworkAddType.manual || isCheckDone) {
                        // 수동 추가 & 자동 추가 입력
                        if (!isEnableCheck) {
                          showResultDialog(context, TR(context, '입력 내용을 확인해 주세요.'));
                          return;
                        }
                        showConfirmDialog(context, ref.read(languageProvider).isKor ?
                          TR(context, '\'${newNetwork.name}\'\n네트워크를 추가하시겠습니까?') :
                          TR(context, 'Would you like to add a\n\'${newNetwork.name}\' network?')).then((result) async {
                          if (result != null && result) {
                            // final validate = await ref.read(jsonRpcServiceProvider)
                            //   .validateNetwork(newNetwork);
                            var validate = false;
                            if (!newNetwork.isRigo) {
                              // RIGO 가 아닐경우 네트워크 체크..
                              validate = await MdlRpcService()
                                  .validateNetwork(newNetwork);
                            } else {
                              final chainId = await JsonRpcService()
                                  .getNetworkInfo(newNetwork);
                              validate = STR(chainId).isNotEmpty;
                            }
                            if (validate) {
                              // TODO: 네트워크, 월렛 주소 통합관리 필요....
                              if (STR(newNetwork.exploreUrl).isNotEmpty && newNetwork.exploreUrl![newNetwork.exploreUrl!.length-1] == '/') {
                                newNetwork.exploreUrl = newNetwork.exploreUrl!.substring(0, newNetwork.exploreUrl!.length-1);
                              }
                              provider.Provider.of<NetworkProvider>(context, listen: false)
                                .addNewNetwork(newNetwork);
                              ref.read(coinProvider).setNetworkFromId(newNetwork.id);
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
                        showLoadingDialog(context, '네트워크 확인중입니다.');
                        // 마지막 / 문자 제거..
                        if (newNetwork.httpUrl[newNetwork.httpUrl.length-1] == '/') {
                          newNetwork.httpUrl = newNetwork.httpUrl.removeLast();
                          LOG('---> newNetwork.httpUrl removed last "/" : ${newNetwork.httpUrl}');
                        }
                        final chainId = await JsonRpcService()
                          .getNetworkInfo(newNetwork);
                        if (STR(chainId).isNotEmpty) {
                          LOG('---> newNetwork chainId : $chainId');
                          newNetwork.id           = Uuid().v4();
                          newNetwork.url          = newNetwork.createUrlFromHttps;
                          newNetwork.chainId      = chainId!;
                          newNetwork.name         = 'RIGO $chainId';
                          newNetwork.symbol       = 'RIGO';
                          newNetwork.networkType  = 0;
                          print('---> checkResult : ${newNetwork.toJson()}');
                          isCheckDone = newNetwork.isValidated;
                          hideLoadingDialog();
                        } else if (mounted) {
                          final checkNetList = await ref.read(firebaseProvider)
                              .getMDLNetworkCheckUrl();
                          for (var item in checkNetList) {
                            LOG('---> checkNetList item : ${item.toJson()}');
                            final checkResult = await MdlRpcService()
                                .checkNetworkAuto(item.url, item.method,
                                url: newNetwork.httpUrl,
                                chainId: newNetwork.chainId);
                            LOG('---> checkResult : $checkResult');
                            if (checkResult != null) {
                              newNetwork.id           = Uuid().v4();
                              newNetwork.httpUrl      = STR(checkResult['url']);
                              newNetwork.chainList    = checkResult['chains'];
                              newNetwork.networkType  = 1;
                              newNetwork.chainId      = '';
                              LOG('---> checkNetList result : ${newNetwork.toJson()}');
                              hideLoadingDialog();
                              Future.delayed(Duration(milliseconds: 200)).then((_) {
                                _showChannelSelect();
                              });
                              break;
                            } else {
                              hideLoadingDialog();
                              showResultDialog(context,
                                TR(context, '잘못된 네트워크입니다.'), 'assets/svg/icon_error.svg').then((_) {
                                isCheckDone = false;
                              });
                              return;
                            }
                          }
                        } else {
                          hideLoadingDialog();
                        }
                        if (isDuplicated) {
                          showResultDialog(context, TR(context,
                              '이미 추가한 네트워크입니다.\n다시 입력해 주세요.'),
                              'assets/svg/icon_error.svg').then((_) {
                                setState(() {
                                  isCheckDone = false;
                                });;
                          });
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
      bool showPaste = false,
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
        isShowOutline: isShowOutline,
        showPaste: showPaste,
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
        // itemHeight: kMinInteractiveDimension,
        // dropdownWidth: 140,
        // buttonHeight: 30,
        // buttonWidth: 30,
        // itemPadding: const EdgeInsets.only(left: 12, right: 12),
        // offset: const Offset(0, 8),
        items: list,
        onChanged: (value) {
          LOG('---> selected item : $value');
          var selected = value as DropdownMenuItem;
          if (onSelected != null) onSelected(selected.value);
        },
      ),
    );
  }

  _buildErrorItem(String text) {
    return Container(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text(text, style: typo12medium100.copyWith(color: PRIMARY_90)),
    );
  }
}
