
import '../../../../common/const/utils/uihelper.dart';
import '../../../../domain/model/network_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/custom_text_edit.dart';
import '../../../../common/const/widget/custom_toast.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/network_provider.dart';

class NetworkInfoScreen extends ConsumerStatefulWidget {
  NetworkInfoScreen(this.networkModel, {Key? key, this.isCanDelete = true}) : super(key: key);
  static String get routeName => 'NetworkInfoScreen';
  NetworkModel networkModel;
  bool isCanDelete;

  @override
  ConsumerState createState() => _NetworkInfoScreenState();
}

class _NetworkInfoScreenState extends ConsumerState<NetworkInfoScreen> {
  final _socketController = TextEditingController();
  final _nameController = TextEditingController();
  final _exploreController = TextEditingController();
  final _fToast = FToast();
  late var _inputSocket   = widget.networkModel.url;
  late var _inputName     = widget.networkModel.name;
  late var _inputExplore  = widget.networkModel.exploreUrl;
  var _isEditMode = false;

  _initEditData() {
    _socketController.text = _inputSocket;
    _nameController.text = _inputName;
    _exploreController.text = _inputExplore ?? '';
  }

  @override
  void initState() {
    super.initState();
    _initEditData();
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
          title: Text(TR(context, _isEditMode ? '네트워크 편집' : '네트워크 정보'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                  children: [
                    _buildInfoItem('RPC 주소', widget.networkModel.httpUrl),
                    if (widget.networkModel.isRigo)
                      _buildInfoItem('RPC 소켓 주소', _inputSocket,
                          controller: _socketController,
                          isCanEdit: true,
                          onChanged: (text) {
                            setState(() {
                              _inputSocket = text;
                            });
                          }
                      ),
                    _buildInfoItem('체인 아이디', widget.networkModel.chainId),
                    if (STR(widget.networkModel.channel).isNotEmpty)
                      _buildInfoItem('채널', widget.networkModel.channel),
                    // if (STR(widget.networkModel.symbol).isNotEmpty)
                    //   _buildInfoItem('통화 기호', widget.networkModel.symbol),
                    _buildInfoItem('네트워크 이름', _inputName,
                      controller: _nameController,
                      isCanEdit: true,
                      onChanged: (text) {
                        setState(() {
                          _inputName = text;
                        });
                      }
                    ),
                    if (isNameEmpty)
                      _buildErrorItem(TR(context, '네트워크 이름을 입력해 주세요.')),
                    if (isNameDuplicated)
                      _buildErrorItem(TR(context, '이미 등록된 네트워크 이름입니다.')),
                    if (widget.networkModel.isRigo)...[
                      _buildInfoItem('블록 탐색기 주소(선택)', _inputExplore,
                        controller: _exploreController,
                        isCanEdit: true,
                        onChanged: (text) {
                          setState(() {
                            _inputExplore = text;
                          });
                        }
                      ),
                      if (isExplorerError)
                        _buildErrorItem(TR(context, '블록 탐색기 주소를 확인해 주세요.')),
                      SizedBox(height: 300),
                    ],
                  ],
                )
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: TR(context, _isEditMode ? '취소' : '삭제'),
                        isSmallButton: false,
                        isBorderShow: true,
                        color: Colors.transparent,
                        textStyle: typo14bold.copyWith(
                          color: widget.isCanDelete || _isEditMode ? GRAY_80 : GRAY_20),
                        onTap: () {
                          setState(() {
                            LOG('--> widget.isCanDelete : $_isEditMode / ${widget.isCanDelete}');
                            if (_isEditMode) {
                              _isEditMode = !_isEditMode;
                            } else if (widget.isCanDelete) {
                              showConfirmDialog(context, TR(context, '네트워크를 삭제하시겠습니까?')).then((result) {
                                if (BOL(result)) {
                                  var networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
                                  if (networkProv.removeNetwork(widget.networkModel)) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              });
                            }
                          });
                        }
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: PrimaryButton(
                        text:TR(context, _isEditMode ? '저장' : '편집'),
                        isSmallButton: false,
                        color: isButtonEnable ? PRIMARY_90 : GRAY_30,
                        onTap: () {
                          if (!isButtonEnable) return;
                          setState(() {
                            if (_isEditMode) {
                              if (STR(_inputExplore).isNotEmpty && _inputExplore![_inputExplore!.length-1] == '/') {
                                _inputExplore = _inputExplore!.substring(0, _inputExplore!.length-1);
                              }
                              LOG('--> _inputExplore : $_inputExplore');
                              widget.networkModel.url = _inputSocket;
                              widget.networkModel.name = _inputName;
                              widget.networkModel.exploreUrl = _inputExplore;
                              var networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
                              if (networkProv.setNetwork(widget.networkModel)) {
                                _showToast(TR(context, '네트워크 편집이 완료되었습니다.'));
                              }
                            }
                            _isEditMode = !_isEditMode;
                          });
                        }
                      ),
                    )
                  ],
                )
              )
            ],
          )
        )
      )
    );
  }

  get isNameEmpty {
    return _isEditMode && _inputName.isEmpty;
  }

  get isSocketEmpty {
    return widget.networkModel.isRigo && _isEditMode && _inputSocket.isEmpty;
  }

  get isNameDuplicated {
    var networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
    return _isEditMode &&
        (_inputName.isNotEmpty && _inputName != widget.networkModel.name &&
        !networkProv.checkNetworkName(_inputName));
  }

  get isExplorerError {
    return _isEditMode && STR(_inputExplore).isNotEmpty && !STR(_inputExplore).contains('http');
  }

  get isButtonEnable {
    return !_isEditMode || (!isSocketEmpty && !isNameEmpty && !isNameDuplicated && !isExplorerError);
  }

  _buildInfoItem(String title, String? text, {
      TextEditingController? controller,
      var isCanEdit = false,
      Function(String)? onChanged
    }) {
    if (isCanEdit && _isEditMode) {
      return showTextEdit(title, controller: controller, desc: text, onChanged: onChanged);
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TR(context, title), style: typo16bold),
            if (text != null)...[
              SizedBox(height: 5.h),
              Text(STR(text), style: typo14medium150),
            ],
          ],
        ),
      );
    }
  }

  _buildErrorItem(String text) {
    return Container(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text(text, style: typo14bold.copyWith(color: PRIMARY_90)),
    );
  }

  _showToast(String msg) {
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _fToast.init(context);
      _fToast.showToast(
        child: CustomToast(
          msg: msg,
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
    });
  }

  showTextEdit(
      title, {
        String? desc,
        String? error,
        TextEditingController? controller, String? hint,
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
      isEnabled: true,
      isShowOutline: true,
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
