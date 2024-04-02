import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:larba_00/common/common_package.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../services/localization_service.dart';

class TermsDetailScreen extends ConsumerStatefulWidget {
  const TermsDetailScreen({this.title, this.type, super.key});
  static String get routeName => 'terms_detail';
  final String? title;
  final String? type;
  @override
  ConsumerState<TermsDetailScreen> createState() => _TermsDetailScreenState();
}

class _TermsDetailScreenState extends ConsumerState<TermsDetailScreen> {
  late String title;

  @override
  void initState() {
    print(widget.title);
    title = widget.title!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalization.of(context)!.locale.languageCode;
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        titleSpacing: 0,
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: AutoSizeText(
                  title,
                  style: typo18semibold,
                  minFontSize: 8,
                  maxFontSize: 18,
                  maxLines: 2,
                ),
              )
            ),
            SizedBox(width: 40.w)
          ],
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    getPolicyDesc(widget.type, lang),
                ))),
            ),
          );
        }),
      ),
    );
  }

  getPolicyDesc(type, lang) {
    switch (type) {
      case '0':
        return lang == 'ko' ? policy0Ko : policy0En;
      case '1':
        return lang == 'ko' ? policy1Ko : policy1En;
      case '2':
        return lang == 'ko' ? policy2Ko : policy2En;
    }
  }
}

String policy0Ko = '''
제 1 조 (목적) 
본 약관은 [주식회사 바이핀](이하 “회사”라 합니다)가 제공하는 BYFFIN 및 BYFFIN 관련 제반 서비스(이하 “서비스”라 합니다)의 이용조건 및 절차에 관한 회사와 회원 간의 권리 의무 및 책임사항, 기타 필요한 사 항을 규정함을 목적으로 합니다. 
제 2 조 (약관의 명시, 설명과 개정) 
1. 본 약관의 내용은 회사의 홈페이지에 개시하거나 기타의 방법으로 사용자에게 공지하고, 이용자가 회 원으로 가입하면서 본약관에 동의함으로써 효력이 발생합니다. 
2.회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다. 
3. 회원은 이용약관을 주의 깊게 읽고 변경 사항에 대해 정기적으로 검토해야 합니다. 
4. 회원이 이용약관을 주의 깊게 읽지 않고 서비스 사용과 관련하여 생기는 불이익에 대해서는 회사는 책 임지지 않습니다. 
5. 회사가 이 약관을 변경하고자 하는 경우에는 변경 적용일자 30일 이전부터 그 내용을 회원에게 공지 및 개별 통지하여야 합니다. 
6. 회원은 약관의 변경 내용이 게시되거나 통지된 후부터 변경되는 약관의 시행일 전의 영업일까지 계약 을 해지할 수 있고, 약관의 변경 내용에 대하여 이의를 제기할 수 있습니다. 
7. 회원이 개정약관의 적용에 동의하지 않는다는 명시적 의사를 표명한 경우 회사는 개정 약관의 내용을 적용할 수 없으며, 이 경우 회원은 이용계약을 해지할 수 있습니다. 다만, 기존 약관을 적용할 수 없 는 특별한 사정이 있는 경우에는 회사는 이용계약을 해지할 수 있습니다. 
제 3 조 (약관 외 준칙) 
1.서비스 이용과 관련하여는 이 약관을 우선 적용하며, 이 약관에서 정하지 않은 사항은 관계 법령 또는 상관례에 따릅니다. 
2. 본 이용 약관의 다른 조항에도 불구하고 본 문서에 포함된 용어, 조건 및 표현의 의미는 영어로 된 정 의 및 해석에 따릅니다. 
제 4 조 (용어의 정의) 
본 약관에서 사용하는 용어의 정의는 다음과 같습니다. 
1. 회원: 본 약관에 따라 회사와 이용계약을 체결하고, 회사가 제공하는 서비스를 이용하는 고객을 말합니 다. 
2. 서비스: 단말기(PC, 휴대형 단말기 등의 각종 유무선 장치를 포함)에 상관없이 이용할 수 있는 블록체 인 기술을 기반으로 하는 디지털 지갑 서비스인 BYFFIN 및 그와 관련된 일체의 서비스를 의미합니다. 
3. 디지털 자산: 서비스 내에서 전자적인 방법으로 가치의 저장 수단, 교환의 매개가 되는 것으로서 코인, 토큰 등을 포함한 블록체인상의 모든 데이터를 의미합니다. 
4.지갑: 회원의 계정과 연계된 디지털 자산을 확인 및 보관하는 기능을 제공하고 계정 주소를 통해 디지 털 자산을 주고받을 수 있는 서비스를 의미합니다. 
5. 계정 주소: 서비스에서 회원 간 디지털 자산의 변화를 기록하기 위해 각 계정마다 부여된 BYFFIN에 존 재하는 고유한 식별 주소를 의미합니다. 
6.비밀번호: 회원이 계정 및 계정 주소와 일치되는 회원임을 확인할 수 있도록 하는 식별번호로 회원 자 신이 설정한 일정 이상의 문자 및/또는 숫자의 조합을 의미합니다. 
본 약관에서 사용하는 용어의 정의는 전항에서 정하는 것을 제외하고는 관계 법령 및 일반적인 상관례에 의 합니다 
제 5 조 (이용계약의 성립) 
1. 회사가 제공하는 서비스에 관한 이용계약은 회원이 되고자 하는 자 (이하 “가입신청자”) 가 서비스를 설치하고 본 약관의 내용에 대하여 동의를 한 다음 서비스를 제공받음으로써 체결됩니다. 
2. 회사는 서비스 관련 설비의 여유가 없거나, 기술상 또는 업무상 문제가 있는 경우에는 회원가입신청의 승낙을 유보(즉, 서비스 제공을 유보)할 수 있습니다. 
3. 제2항에 따라 회원가입신청의 승낙을 유보한 경우, 회사는 원칙적으로 이를 가입신청자에게 알리도록 합니다. 
제 6 조 (개인정보보호 의무) 
1. 회원의 개인정보는 서비스의 원활한 제공을 위하여 회원이 동의한 목적과 범위 내에서만 수집·이용됩 니다. 회사는 법령에 의하거나 회원이 별도로 동의하지 아니하는 한, 회원의 개인정보를 제 3자에게 제공하지 아니합니다. 이에 대한 자세한 사항은 개인정보처리방침에서 정합니다. 
제 7 조 (회사의 의무) 
1. 회사는 관련 법령과 본 약관을 준수하고 지속적이고 안정적으로 서비스를 제공하기 위하여 최선을 다 하여 노력합니다. 
2. 회사는 서비스 이용과 관련하여 발생하는 회원의 불만 또는 피해구제요청을 적절하게 처리할 수 있도 록 필요 인력 및 시스템을 구비합니다. 
3. 회사는 회원이 제기한 의견이나 요청에 대해 전자우편 등을 통하여 회원에게 처리 과정 및 결과를 전 달할 수 있습니다. 
제 8 조 (회원의 의무) 
1. 회사는 다음 각 호에 해당하는 경우 경고, 정지, 영구이용정지, 이용계약의 해지 등으로 서비스 이용을 단계적으로 제한할 수 있습니다. 
(1) 계정 신청 또는 변경 시 허위 내용의 등록 (2) 타인의 정보도용 (3) 회사가 게시한 정보의 변경 (4) 회사가 정한 정보 이외의 정보 (컴퓨터 프로그램 등) 등의 송신 또는 게시 (5) 회사와 기타 제3자의 저작권 등 지식재산권에 대한 침해 
(6) 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위 
(7) 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시 하는 행위 
(8) 회사의 사전 동의 없이 영리를 목적으로 서비스를 사용하는 행위 
(9) 기타 관련 법령에 위반되거나 부당한 행위 
2.회원은 관련 법령, 본 약관의 규정, 이용안내 및 회사가 서비스와 관련하여 공지하거나 통지한 사항 등 을 준수하여야 하며 회사의 업무에 방해되는 행위를 하여서는 아니 됩니다. 
3. 회원은 비밀번호에 관한 모든 관리책임은 회원에게 있으며, 비밀번호를 타인에게 양도, 대여할 수 없습 니다. 회사의 귀책사유에 의하지 아니한 비밀번호의 유출, 양도, 대여로 인한 손실이나 손해에 대하여 회사는 책임을 지지 않습니다. 
4. 회원은 자신의 비밀번호가 도용되거나 제 3자가 사용하고 있음을 인지한 경우에는 반드시 회사에 그 사실을 통지하고 회사의 안내에 따라야 합니다. 
5. 제4항의 경우에 해당 회원이 회사에 그 사실을 통지하지 않거나, 통지한 경우에도 안내에 따르지 않아 발생한 불이익에 대하여 회사가 귀책사유가 없는 한 회사는 책임지지 않습니다. 
제 9 조 (서비스의 제공) 1. 회사는 회원에게 다음 각 호에 해당하는 서비스를 제공합니다. 
(1) 새로운 계정 주소의 생성 (2) 디지털 자산의 확인 (3) 디지털 자산의 전송 (4) 서비스를 통해 보이는 토큰의 등록 및 해제 (5) 각종 요청에 대한 승인 및 서명 
(6) 기타 회사가 추가로 개발하거나 다른 회사와의 제휴계약 등을 통해 회원에게 제공하는 일체의 서 비스 
2. 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다. 
제 10 조 (서비스의 내용 및 변경) 
1. 회사는 서비스의 종류에 따라 각 서비스의 특성, 절차 및 방법에 대한 사항을 서비스 화면을 통하여 공지하며, 회원은 회사가 공지한 각 서비스에 관한 사항을 이해하고 서비스를 이용해야 합니다. 
2. 회사는 안정적인 서비스 제공을 위하여 서비스의 내용, 운영상, 기술상 사항 등을 변경할 수 있습니다. 
3. 회사는 서비스를 변경할 경우 변경내용과 적용 일자를 명시하여 사전에 공지합니다. 다만, 회사가 사전 에 공지할 수 없는 부득이한 사유가 있는 경우 사후에 공지할 수 있습니다. 
4.회사는 본 약관 및 서비스 내용이 변경되는 경우, 회원의 등록된 전자우편 주소 및 홈페이지 공지사항 을 통하여 회원들에게 통지, 공지할 수 있으며, 회원이 이 내용을 조회하지 않아 입은 손해에 대하여 회사에게 고의 또는 과실이 없는 한 회사는 이를 책임지지 않습니다. 전자우편 주소의 오류, 전자우편 서비스의 장애 등 회사의 귀책사유가 없음이 명백한 경우에도 그러합니다. 
제 11 조 (서비스의 중지) 
1. 회사는 다음 각 호에 해당하는 경우 서비스 제공을 중지할 수 있습니다. 이 경우 회사는 불가피한 경 우가 아닌 한 서비스 제공 중지를 사전 고지합니다. 
(1) 서비스용 설비의 보수 등 공사로 인한 부득이한 경우 (2) 전기통신사업자가 전기통신 서비스를 중지했을 경우 (3) 회사가 직접 제공하는 서비스가 아닌 제휴업체 등의 제3자를 이용하여 제공하는 서비스의 경우 제 
휴 업체 등의 제3자가 서비스를 중지했을 경우 (4) 기타 불가항력적 사유가 있는 경우 
2. 회사는 국가비상사태, 정전, 서비스 설비의 장애 또는 서비스 이용의 폭주 등으로 정상적인 서비스 이 용에 지장이 있는 때에는 서비스의 전부 또는 일부를 제한하거나 정지할 수 있습니다. 
제 12 조 (서비스 이용 제한 및 해지) 1. 회원은 언제든지 서비스 삭제를 통해 회사와의 이용계약을 해지할 수 있습니다. 2.회원은 서비스 해지 전 백업 및 관리에 유의해 주시기 바랍니다. 3. 회사는 다음과 같은 사유가 있는 경우 이용계약을 해지할 수 있습니다. 
(1) 회원이 본 약관에 위배되는 행위를 한 경우 
(2) 회원이 불법프로그램의 제공 및 서비스 운영 방해, 불법통신, 해킹, 악성프로그램의 배포, 접속권한 초과 행위 등 관련 법령에 위배되는 행위를 한 경우 
(3) 회원이 회사가 제공하는 서비스의 원활한 진행을 방해하는 행위를 하거나 그러한 행위를 시도한 경우 
4. 본 조에 따른 이용계약 해지 시 회원이 서비스 이용을 통해 획득한 모든 혜택이 소멸되며, 회사는 이 에 대해 별도로 보상하지 않습니다. 
5.제4항에 따라 회사가 이용계약을 해지하는 경우 회사는 회원의 이의신청 접수 및 처리 등을 위하여 일정 기간 동안 회원의 정보를 보관할 수 있습니다. 
제 13 조 (타 블록체인 플랫폼 기반 디지털 자산 이용 제한) 
1.본 서비스는 RIGO 블록체인 플랫폼 위에서 사용 가능한 디지털 자산의 전송과 보관 등에 대한 것으로 서 다른 블록체인 플랫폼을 기반으로 하는 디지털 자산과 관련하여서는 서비스 이용이 제한될 수 있 습니다. 회원은 회사가 서비스를 제공하는 디지털 자산에 한하여 전송, 보관 등의 서비스를 이용할 수 있습니다. 
2. 회원의 부주의로 인하여 회사가 제공하는 지갑으로 전송된 RIGO 외의 블록체인 플랫폼을 기반으로 하 는 디지털 자산에 대해서 회사는 책임지지 않으며, 회원은 이를 이유로 회사에게 어떠한 청구도 할 수 없습니다. 
제 14 조 (회사의 책임제한) 
1. 회사는 천재지변, 법령의 변경, 법원 또는 정부의 명령 또는 이에 준하는 불가항력으로 인하여 서비스 를 제공할 수 없는 경우에는 서비스제공에 관한 책임이 면제됩니다. 
2. 회사는 회원의 귀책사유로 인한 서비스이용의 장애에 대하여는 회사의 고의 또는 과실이 없는 한, 책 임을 지지 않습니다. 
3. 회사는 회원이 서비스와 관련하여 게재한 정보, 자료, 사실의 신뢰도, 정확성 등의 내용에 관하여는 책 임을 지지 않습니다. 
4. 회사는 회원 간 또는 회원과 제3자 상호 간에 서비스를 매개로 하여 거래 등을 한 경우에는 책임이 면제됩니다. 
5. 회사는 무료로 제공되는 서비스 이용과 관련하여 관련법에 특별한 규정이 없거나 회사의 고의, 과실이 없는 한 책임을 지지 않습니다. 
6.회사는 RIGO 블록체인 플랫폼의 장애로 인한 손해에 대해서는 회사의 고의, 과실이 있지 않는 한 책 임을 지지 않습니다. 
7. 회사는 서비스를 통한 디지털 자산의 보관 및 전송 기능을 제공할 뿐 회원의 디지털 자산 자체에 대한 관리 의무를 부담하지 않습니다. 계정 및 디지털 자산의 관리에 대한 모든 책임은 회원에게 있으며, 회사의 귀책사유가 없는 경우에는 어떠한 책임도 지지 않습니다. 
8. 회원이 제3자 서비스에서 제공하는 주소의 정확성에 대한 책임은 회원에게 있으며, 회사는 회원이 잘 못 기재한 주소로 서명 및 전송에 대해서는 책임을 지지 않습니다. 
제 15 조 (손해배상) 
1. 회사는 법령상 허용되는 한도 내에서 서비스와 관련하여 본 약관에 명시되지 않은 어떠한 구체적인 사 항에 대하여 약정이나 보증을 하지 않습니다. 또한, 회사는 어떠한 디지털 자산의 가치도 보증하지 않 습니다. 회사는 회원이 서비스에 게재한 정보, 자료, 사실의 신뢰도, 정확성 등에 대해서는 보증을 하 지 않으며 이로 인해 발생한 회원의 손해에 대하여 회사의 고의나 과실이 있지 않는 한 책임을 지지 않습니다. 
2. 회사의 책임 있는 사유로 인하여 회원에게 손해가 발생한 경우 회사는 원칙적으로 민법에서 정하고 있 는 통상손해의 범위에서 그 손해를 배상하고, 특별한 사정으로 인한 손해는 회사가 그러한 사정을 알 았거나 알 수 있었던 때에 한하여 손해배상의 범위에 포함됩니다. 
3. 제2항에도 불구하고 다음 각 호의 어느 하나에 해당하는 경우에는 회원이 그 책임의 전부 또는 일부 를 부담할 수 있습니다. 
(1)회원이 손해 발생의 원인 또는 손해 발생 사실을 알았음에도 불구하고 회사에 통지하지 않은 경우 
(2)회원이 고의 또는 과실로 제3자에게 지갑 관련 계정 및 거래 정보를 유출하거나 지갑을 사용하게 한 경우 
(3) 그 외에 손해 발생에 있어서 회원의 고의나 과실이 있는 경우 
4. 회사의 고의나 과실이 있지 않는 한 회사는 회원에게 발생한 손해에 대하여는 배상책임이 없습니다. 
5. 회원이 회사에게 제공한 정보가 사실과 다를 경우, 회사는 언제든지 서비스의 제공을 중단하고 본 약 관에 의해 계약 전체 또는 일부를 해지할 수 있으며, 이로 인하여 회사에게 손해가 발생한 경우, 회원 에게 그 손해의 배상을 청구할 수 있습니다. 
6.회원이 회사의 시스템 운영을 방해하는 등 고의 또는 과실로 법령, 본 약관, 공서양속에 위배하는 행위 등을 통하여 회사에 손해를 발생시킨 경우에는 회사에 발생한 손해를 모두 배상해야 합니다. 
7. 회원이 회사에게 손해배상을 청구할 경우 회사는 회원과 상호 합의하여 회원의 지갑으로 디지털 자산 을 지급하는 방법으로 회원의 손해를 배상할 수 있습니다. 
제 16 조 (준거법) 
1. 본 서비스 이용 약관은 법 선택 원칙에 영향을 미치지 않으면서 유효성, 구성, 법적 효력, 이행 및 구 제를 포함한 모든 문제에 대해 법인 설립 국가의 법률을 따릅니다. 
''';

String policy1Ko = '''
주식회사 바이핀(이하 ‘회사’라 합니다)는 개인정보 보호법에 따라 정보주체의 개인정보를 보호하고 이와 관 련한 내용을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립, 공 개합니다. 
제1조 [개인정보의 처리목적] 
제2조 [수집하는 개인정보 항목] 
제3조 [개인정보의 수집방법] 
제4조 [개인정보의 제3자 제공] 
제5조 [개인정보처리의 위탁] 
제6조 [개인정보 자동 수집 장치의 설치 ∙ 운영 및 거부에 관한 사항] 
제7조 [접근권한에 대한 안내] 
제8조 [개인정보의 보유 및 이용기간] 
제9조 [개인정보 파기절차 및 방법] 
제10조 [정보주체의 권리, 의무 및 행사방법] 
제11조 [개인정보의 안전성 확보조치] 
제12조 [개인정보보호 책임자] 
제13조 [권익침해 구제 방법] 
제14조 [개인정보처리방침의 적용 제외] 
제15조 [고지 의무] 
부칙 
제1조 [개인정보의 처리목적] 
회사는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음 목적 이외의 용도로 는 이용되지 않으며, 이용 목적이 변경되는 경우에는 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다. 
1. 서비스 제공 서비스 제공, 콘텐츠 제공, 맞춤서비스 제공 등을 목적으로 개인정보를 처리합니다. 
2. 마케팅 또는 이벤트 실시 마케팅 또는 이벤트 참여기회 제공, 광고정보 제공 등의 목적으로 개인정보를 처리합니다. 
제2조 [수집하는 개인정보 항목] 
바이핀은 개인정보를 수집하지 않습니다. 다만, 사용자의 맞춤 서비스 제공 및 더 나은 환경의 광고를 제공 하기 위해 필요 최소한으로 수집, 처리할 필요가 있는 경우 관련 법령의 제한에 따라 고객의 동의 등 필요 한 조치를 거쳐 그 개인정보를 수집, 처리할 수 있습니다. 
	•	서비스 제공 이메일 주소, 전화번호, 아이디, 이름, 생년월일, 주소, 국적, 성별, 연령대 
	•	마케팅 또는 이벤트 실시 사용자의 활동 (검색하는 단어, 콘텐츠와 광고 조회 및 상호작용, 사용자가 교류하거나 콘텐츠를 공유하는 사람들, 브라우징 기록, IP Address, 쿠키, 접속로그, 방문 일시, 서비스 이용 기록, 불량 이용 기록), 암호화된 동일인 식별정보(CI) 
	•	고객센터 상담 과정 웹페이지, 메일, 팩스, 전화, 채팅 
제3조 [개인정보의 수집방법] 
	•	회원가입 및 서비스 이용 과정에서 이용자가 개인정보 수집에 대해 동의하고 직접 정보를 입력하는 경우, 회사는 해당 정보를 수집합니다. 
	•	앱 또는 웹 서비스를 통한 문의, 혹은 고객센터를 통한 상담 과정에서 개인정보가 수집될 수 있습니다. 
	•	회사와 제휴한 외부 기업이나 단체로부터 개인정보를 제공받을 수 있으며, 이러한 경우에는 제휴사에 서 이용자에게 개인정보 제공 동의를 받아야 합니다. 
	•	회사의 서비스 이용과정에서 로그분석을 통해 생성정보가 수집될 수 있으며, 쿠키에 의한 정보 등이 자동 수집될 수 있습니다 
제4조 [개인정보의 제3자 제공] 
회사는 이용자의 개인정보를 ‘제1조 개인정보의 처리목적’ 에서 고지한 범위 내에서 사용하며, 동의 범위를 초과하여 이용하거나 원칙적으로 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 개인정보를 제3자에게 제공할 수 있습니다. 
	•	통계작성, 학술연구나 시장조사를 위해 특정 개인을 식별할 수 없는 형태로 가공하여 제공하는 경우 
	•	이용자들이 사전에 동의한 경우 
	•	법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우
제5조 [개인정보처리의 위탁] 
	•	회사는 이용자의 개인정보 처리 업무를 위탁하고 있지 않습니다. 다만, 추후 서비스 제공과정에서 개인정보 처리 업무를 위탁할 수 있으며, 이 경우 회사는 이용자에게 본 개인정보처리방침을 통해 안내 하거나 관련 법령상 필요한 경우 이용자로부터 개인정보 처리 업무 위탁에 대한 동의를 받을 것입니다. 
	•	회사는 개인정보 처리 업무 위탁이 수반되는 계약의 체결 시 위탁업무 수행목적 외의 개인정보 처리 금지, 기술적 · 관리적 보호조치, 재 위탁 제한, 수탁자에 대한 관리 · 감독, 손해배상 등 책임에 관한 사 항을 문서로서 명시하고, 수탁자가 개인정보를 안전하게 처리하는지 감독합니다. 
	•	위탁업무의 내용이나 수탁자가 변경될 경우 지체없이 본 개인정보 처리방침을 통하여 공개합니다 
제6조 [개인정보 자동 수집 장치의 설치 ∙ 운영 및 거부에 관한 사항] 
	•	회사는 이용자가 웹 사이트를 더 편리하게 이용할 수 있도록 쿠키(cookie)를 수집합니다. 쿠키는 웹 사이트의 서버가 이용자 브라우저에 보내는 아주 작은 파일로 이용자 컴퓨터에 저장됩니다. 
	•	이용자는 쿠키 허용, 차단 등의 설정을 할 수 있습니다. 다만 쿠키 저장을 차단하는 경우, 서비스 이 용에 어려움이 발생할 수 있습니다. 
제7조 [접근권한에 대한 안내] 
	•	회사는 모바일 앱 서비스를 위하여 아래와 같이 고객의 이동통신단말기 내 정보 및 기능에 접근 · 이용 할 수 있습니다. 
1) (필수) 기기 및 앱 기록: 기기식별 및 앱 상태(버전) 확인 목적 2) (선택) 카메라: 촬영 및 QR코드 스캔 시 3) (선택) 생체인식: 로그인 등 
	•	필수 및 선택 접근 항목은 앱 설치 시 또는 최초 실행 시 안내하고 동의를 받습니다. 선택 접근항목의 경우 운영체제의 버전에 따라 동의를 받는 방법이 다를 수 있고, 접근을 거부하더라 도 기본 서비스 이용에 제한이 없습니다. 
제8조 [개인정보의 보유 및 이용기간] 
	•	회사는 법령에 따른 개인정보 보유, 이용 기간 또는 고객으로부터 개인정보를 수집 시에 동의 받은 개인정보 보유, 이용기간 내에서 개인정보를 취급, 보유합니다. 
	•	각각의 개인정보 이용 및 보유 기간은 다음과 같습니다. 원활한 서비스 제공을 위한 개인정보 보유 
1) 회원 가입 시 입력한 정보: 회원 탈퇴 또는 법령이 정한 시점까지 2) 법령 위반에 따른 수사 ∙ 조사 등이 진행중인 경우: 해당 수사 ∙ 조사 종료시까지 
제9조 [개인정보 파기절차 및 방법] 
	•	회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체 없이 개인정보를 파기합니다. 
	•	이용자로부터 동의 받은 개인정보 보유기간이 경과하거나 처리목적이 달성되었음에도 불구하고 다른 법령에 따라 개인정보를 계속 보존하여야 하는 경우에는 해당 개인정보를 별도의 데이터베이스(DB) 에 옮기거나 보관장소를 달리하여 보존합니다. 
	•	개인정보 파기 절차 및 방법은 다음과 같습니다. 
1) 파기절차 
회사는 파기 사유가 발생한 개인정보를 선정하고, 회사의 개인정보 보호책임자의 승인을 받아 
개인정보를 파기합니다. 
2) 파기방법 
회사는 전자적 파일 형태로 기록 ∙ 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사 용합니다. 종이 문서에 기록 ∙저장된 개인정보는 분쇄기로 분쇄하여 파기합니다. 
제10조 [정보주체의 권리, 의무 및 행사방법] 
	•	이용자는 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다. 
1) 개인정보 열람요구 
2) 오류 등이 있을 경우 정정 요구 
3) 삭제요구
4) 처리정지 요구 
	•	제1항에 따른 권리 행사는 서면, 전화, 전자우편, 팩스 등을 통하여 하실 수 있으며 회사는 이에 대 해 지체 없이 조치합니다. 
	•	이용자가 개인정보 의 오류 등에 대한 정정 또는 삭제를 요구한 경우, 회사는 정정 또는 삭제를 완료 할 때까지 당해 개인정보를 이용하거나 제공하지 않습니다. 
	•	제1항에 따른 권리 행사는 이용자의 법정대리인이나 위임을 받은 자 등 대리인을 통해 할 수 있습니다. 
	•	이용자는 정보통신망법, 개인정보 보호법 등 관계법령을 위반하여 회사가 처리하고 있는 이용자 본인 이나 타인의 개인정보 및 사생활을 침해할 수 없습니다. 
제11조 [개인정보의 안전성 확보조치] 
회사는 이용자의 개인정보를 처리함에 있어 개인정보가 분실, 도난, 유출, 변조 또는 훼손되지 않도록 안전 성 확보를 위하여 다음과 같은 기술적 ∙ 관리적 ∙ 물리적 조치를 취하고 있습니다. 
1. 관리적 조치 
1) 개인정보 내부관리계획의 수립 및 시행 
2) 개인정보취급자 지정 최소화 및 교육 
2. 기술적 조치 
1) 개인정보 접근 제한 
2) 접속기록 보관 및 위 ∙ 변조 방지 
3. 물리적 조치 
1) 비인가자에 대한 출입 통제 
회사는 이용자 개인의 실수나 기본적인 인터넷의 위험성 때문에 일어나는 일들에 대해 책임을 지지 않습니다. 회원 개개인이 본인의 개인정보를 보호하기 위해서 자신의 아이디와 비밀번호를 적절하게 관리하고 여기에 대한 책임을 져야 합니다. 
이용자 역시 개인정보를 안전하게 보호할 의무를 가지고 있습니다. 비밀번호를 포함한 개인정보가 유출되지 않도록 주의합니다 이용자의 부주의나 인터넷상의 문제로 이메일 주소, 비밀번호 등 개인정보가 유출되어 발생한 문제에 대해 회사는 책임을 지지 않습니다. 
제12조 [개인정보보호 책임자] 
회사는 개인정보 처리에 관한 업무를 총괄해 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해 구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다. 
개인정보보호 책임자 책임자: 최고정보보호책임자
이메일 주소: byffin@byffin.io 
개인정보보호 담당부서 부서: 운영팀 이메일 주소: byffin@byffin.io 
이용자는 회사의 서비스를 이용하면서 발생한 모든 개인정보 보호 관련 민원을 개인정보 보호책임자 및 담 당 부서로 문의하실 수 있습니다. 회사는 이용자의 문의에 대해 충분한 답변을 드릴 것입니다.
 제13조 [권익침해 구제 방법] 
정보주체는 아래의 기관에 대해 개인정보 침해에 대한 피해구제, 상담 등을 문의하실 수 있습니다. 아래의 기관은 회사와는 별개의 기관으로서, 회사의 자체적인 개인정보 불만처리, 피해구제 결과에 만족하지 못하 시거나 보다 자세한 도움이 필요하시면 문의하여 주시기 바랍니다 
1. 개인정보침해 신고센터 
1) 홈페이지: https://privacy.kisa.or.kr 
2) 전화번호: 118 
2. 개인정보보호협회 
1) 홈페이지: https://www.eprivacy.or.kr 
2) 전화번호: 02-550-9500 
3. 대검찰청 사이버범죄수사단 
1) 홈페이지: https://www.spo.go.kr/ 
2) 전화번호: 1301 
4. 경찰청 사이버 수사국 
1) 홈페이지: https://cyberbureau.police.go.kr/ 
2) 전화번호: 182 
제14조 [개인정보처리방침의 적용 제외] 
회사는 이용자에게 홈페이지를 통하여 다른 웹사이트 또는 자료에 대한 링크를 제공할 수 있습니다. 이 경우 회사는 외부사이트 및 자료에 대하여 통제권이 없을 뿐만 아니라 이들이 개인정보를 수집하는 행위 에 대하여 회사의 '개인정보처리방침'이 적용되지 않습니다. 따라서, 회사가 포함하고 있는 링크를 클릭하여 타 사이트의 페이지로 이동할 경우에는 새로 방문한 사이트의 개인정보처리방침을 반드시 확인하시기 바랍니다. 
제15조 [고지 의무] 
회사는 법률이나 서비스의 변경사항을 반영하기 위한 목적 등으로 개인정보처리방침을 수정할 수 있습니다. 개인정보처리방침이 변경되는 경우 회사는 변경 사항을 홈페이지를 통해 게시하며, 변경된 개인정보처리방 침은 게시한 날로부터 7일 후 효력이 발생합니다. 
부칙 
이 개인정보처리방침은 2023.11. 20.부터 적용합니다. 
''';

String policy2Ko = '''
1. 마케팅 활용 및 광고성 정보 수신 동의 (1) 귀하는 개인(신용)정보의 선택적인 수집∙이용, 제공에 대한 동의를 거부할 수 있습니다. 다만, 동의하지 않을 경우 관련 편의제공(이벤트 안내, 공지사항, 할인행사)안내 등 이용 목적에 따른 혜택에 제한이 있을 수 있습니다. 그 밖에 계약과 관련된 불이익은 없습니다. 동의한 경우에도 귀하는 동 의를 철회하거나 마케팅 목적으로 귀하에게 연락하는 것을 중지하도록 요청할 수 있습니다. 
2. 수집 및 이용목적 (1) 고객에 대한 편의제공, 귀사 및 제휴업체의 상품·서비스 안내 및 이용권유, 사은·판촉행사 등의 마케팅 활동, 시장조사 및 상품·서비스 개발연구 등을 목적으로 수집·이용 3. 수집 및 이용항목 
(1) 개인식별정보: 이메일 주소 
(2) 서비스이용기록, 아이피 주소, 사용자 생성 데이터(쿠키) 
4. 보유기간 
(1) 동의일로부터 회원 탈퇴 혹은 마케팅 동의 해제 시까지 보유·이용 ※ 더 자세한 내용에 대해서는 개인정보처리방침을 참고하시기 바랍니다. 
''';

String policy0En = '''
Article 1 (Purpose) 
	•	The purpose of these terms and conditions (hereinafter referred to as the "Terms") is to establish the rights, obligations, and responsibilities between [BYFFIN Corporation] (hereinafter referred to as the "Company") providing BYFFIN and its related services (hereinafter referred to as the "Service") and its members, regarding the conditions and procedures for using BYFFIN and related services.

Article 2 (Specification, Explanation, and Amendment of Terms)
	•	The contents of these Terms shall be disclosed on the Company's website or notified to users by other means. The effectiveness of these Terms arises when users agree to these Terms by becoming members upon signing up for the Service.
	•	The Company may amend these Terms within the scope that does not violate relevant laws.
	•	Members should carefully read and periodically review changes to these Terms.
	•	The Company shall not be responsible for any disadvantages arising from members not carefully reading these Terms before using the Service.
	•	In the event the Company intends to amend these Terms, it must notify members of the contents at least 30 days before the effective date of the changes, providing individual notices.
	•	After the announcement or notification of amended terms, members have the right to terminate the contract until the business day before the effective date of the amended terms or raise objections to the changes.
	•	If a member explicitly expresses disagreement with the application of the revised terms, the Company cannot apply the revised terms. In this case, the member may terminate the service agreement. However, if there are special circumstances where the existing terms cannot be applied, the Company may terminate the service agreement.

Article 3 (Supplementary Provisions)
	•	Regarding the use of the service, this agreement takes precedence, and matters not covered by this agreement shall be governed by relevant laws or customs.
	•	Notwithstanding other provisions of this terms of service, the meanings of terms, conditions, and expressions contained in this document shall be interpreted according to their English definitions and interpretations.

Article 4 (Definition of Terms) The definitions of terms used in this agreement are as follows:
	•	Member: Refers to a customer who enters into an service contract with the company according to this agreement and uses the services provided by the company.
	•	Service: Refers to the digital wallet service, BYFFIN, based on blockchain technology that can be used regardless of terminal devices (such as PCs, mobile devices, etc.) and all related services.
	•	Digital Assets: Refers to all data on the blockchain, including coins, tokens, and any electronic means of storing value and facilitating exchanges within the service.
	•	Wallet: Refers to the service that provides the function of verifying and storing digital assets associated with a member's account and enables the exchange of digital assets through account addresses.
	•	Account Address: Refers to the unique identification address existing in BYFFIN assigned to each account to record changes in digital assets between members within the service.
	•	Password: Refers to a combination of a certain number of letters and/or numbers set by the member to confirm their identity corresponding to the account and account address.

The definitions of terms used in this agreement are governed by relevant laws and general customs, except as stipulated in the preceding clause.

Article 5 (Establishment of Service Agreement)
	•	An agreement for the service provided by the company is established by the applicant who wishes to become a member (hereinafter referred to as the "applicant") installing the service and agreeing to the contents of this agreement before receiving the service.
	•	The company may withhold acceptance of a membership application if there is no availability in the service-related equipment or if there are technical or operational issues.
	•	If the acceptance of a membership application is withheld according to clause 2, the company will generally inform the applicant of this.

Article 6 (Obligation to Protect Personal Information)
	•	The personal information of a member is collected and used within the scope and purpose agreed upon by the member for the smooth provision of the service. The company does not provide a member's personal information to third parties unless required by law or separately agreed upon by the member. Details are specified in the Privacy Policy.

Article 7 (Obligations of the Company)
	•	The company endeavors to comply with relevant laws and this agreement, striving to provide the service continuously and stably.
	•	The company equips necessary personnel and systems to appropriately handle members' complaints or requests for remedy related to service usage.
	•	The company may communicate the processing steps and results of opinions or requests raised by members via email or other electronic means.

Article 8 (Obligations of Members)
	•	The company may gradually restrict the use of the service through warnings, suspensions, permanent suspensions, or termination of service contracts in cases falling under the following: 
  (1) Registering false information upon account application or modification. 
  (2) Impersonation of another individual's information. 
  (3) Modifying information posted by the company. 
  (4) Transmitting or posting information (such as computer programs, etc.) other than the information specified by the company. 
  (5) Infringement upon the copyrights or other intellectual property rights of the company or third parties. 
  (6) Damaging the company's or third parties' reputation or disrupting business operations. 
  (7) Posting or disclosing obscene or violent messages, images, audio, or other information that contradicts public order and morals within the service. 
  (8) Using the service for profit purposes without the company's prior consent. 
  (9) Violation of relevant laws or engaging in unfair practices.

	•	Members must comply with relevant laws, the provisions of these terms, instructions for use, and any notifications or notices that the company has announced or notified regarding the service and should not engage in any actions that disrupt the company's operations.
	•	Members are responsible for all management of their passwords and must not transfer or lend their passwords to others. The company is not responsible for any leakage, transfer, or loss caused by the member's password without attributing to the company's fault.
	•	If a member detects that their password has been stolen or used by a third party, they must notify the company of this fact and follow the company's instructions.
	•	In the event a member fails to notify the company of the situation described in clause 4 or does not follow the instructions even after notifying, the company shall not be held responsible for any resulting disadvantages unless the company is at fault.

Article 9 (Provision of Services)
	•	The company provides the following services to members: 
  (1) Generating new account addresses 
  (2) Verification of digital assets 
  (3) Transmission of digital assets 
  (4) Registration and release of tokens visible through the service 
  (5) Approval and signature for various requests 
  (6) All services provided to members through additional development by the company or through partnership agreements with other companies.

	•	The service is provided 24/7, all year round, as a general rule.


Article 10 (Content and Modification of Services)
	•	The company informs members of the characteristics, procedures, and methods of each service through the service screen according to the type of service. Members should understand the details of each service announced by the company and use the service.
	•	The company may change the content, operational, or technical aspects of the service for stable service provision.
	•	When changing the service, the company announces the details of the changes and their effective date in advance. However, if the company has unavoidable reasons for not making prior announcements, it can announce them afterward.
	•	If this agreement or the service content is modified, the company can notify the members through the registered email address and the homepage notice. The company shall not be responsible for damages incurred by members failing to check this information, provided that there is no intentional or gross negligence by the company, even if there are clear errors in the email address or failure of the email service due to reasons not attributed to the company.

Article 11 (Suspension of Services)
	•	The company may suspend service provision in the following cases. In such cases, unless inevitable circumstances arise, the company will notify the suspension of service provision in advance. 
  (1) Unavoidable maintenance or construction work on service equipment. 
  (2) If the telecommunication service provider suspends the telecommunication service. 
  (3) In the case of services provided through third parties such as affiliate companies, if the third party suspends the service. 
  (4) In case of other force majeure circumstances.

	•	In the event of national emergencies, power outages, equipment failures, or a surge in service usage that disrupts normal service provision, the company may restrict or suspend part or all of the service.

Article 15 (Indemnification)
	•	Within the limits allowed by law, the company does not contract or guarantee any specific matters not specified in these terms regarding the service. Additionally, the company does not guarantee the value of any digital assets. The company does not warrant the reliability, accuracy, or content of information, data, or facts posted by members on the service and will not be liable for any member's losses unless there is intentional or gross negligence on the company's part.
	•	If a member incurs losses due to the company's accountable reasons, the company, in principle, compensates for the damages within the scope of ordinary damages stipulated by the Civil Law. Damages resulting from special circumstances will be included in the scope of indemnification if the company was aware of or could have been aware of such circumstances.
	•	Notwithstanding clause 2, a member may bear all or part of the responsibility in the following cases: 
  (1) If a member fails to notify the company despite knowing the cause or occurrence of the loss. 
  (2) If a member, intentionally or negligently, discloses wallet-related account or transaction information to a third party or allows the use of the wallet. 
  (3) In cases where a member's intention or negligence contributes to the incurred loss.
	•	Except in cases of the company's intentional or gross negligence, the company is not liable for damages incurred by a member.
	•	If the information provided by a member to the company is untrue, the company may suspend the provision of the service at any time and may terminate all or part of the contract per these terms. In case the company incurs losses due to this, the company can claim compensation for those losses from the member.
	•	If a member causes losses to the company through intentional or negligent acts, disrupting the company's system operation, violating laws, these terms, or public morals, the member is liable to fully indemnify the company for the losses incurred.
	•	If a member claims indemnification from the company, the company may compensate for the member's losses by transferring digital assets to the member's wallet through mutual agreement between the member and the company.

Article 16 (Governing Law)
	•	This Service Usage Agreement shall be governed by the laws of the country of incorporation regarding validity, composition, legal effect, enforcement, and all issues, without affecting the principles of the choice of law.
''';

String policy1En = '''
BYFFIN Co., Ltd. (hereinafter referred to as the 'Company') establishes and publicly discloses the Privacy Policy to protect the personal information of data subjects in accordance with the Personal Information Protection Act and ensure the swift and smooth handling of related matters.

Article 1 [Purpose of Processing Personal Information] 
Article 2 [Types of Personal Information Collected] 
Article 3 [Methods of Collecting Personal Information] 
Article 4 [Provision of Personal Information to Third Parties] 
Article 5 [Commission of Personal Information Processing] 
Article 6 [Installation, Operation, and Rejection of Automatic Collection Devices for Personal Information] 
Article 7 [Guidance on Access Rights] 
Article 8 [Retention and Use Period of Personal Information] 
Article 9 [Procedure and Method for Destruction of Personal Information] 
Article 10 [Rights, Obligations, and Methods of Exercising Data Subject Rights] 
Article 11 [Security Measures for Personal Information] 
Article 12 [Personal Information Protection Manager] 
Article 13 [Remedy for Privacy Rights Violations] 
Article 14 [Exceptions to the Application of the Privacy Policy] 
Article 15 [Notification Obligations] Supplementary Provisions

Article 1 [Purpose of Processing Personal Information] The company processes personal information for the following purposes. Personal information being processed will not be used for purposes other than those listed below, and in the event of a change in the purpose of use, separate consent will be obtained or necessary measures will be taken.
	•	Service Provision Personal information is processed for the purpose of providing services, offering content, and providing personalized services.
	•	Marketing or Event Implementation Personal information is processed for the purpose of providing marketing or event participation opportunities, offering advertising information, etc.

Article 2 [Types of Personal Information Collected] BYFFIN does not collect personal information. However, in cases where it is necessary to collect and process the minimum required personal information for providing customized services to users and offering improved advertising environments, the Company may collect and process such personal information in compliance with relevant laws, obtaining necessary consent from customers, etc.
	•	Service Provision Email address, phone number, ID, name, date of birth, address, nationality, gender, age group.
	•	Marketing or Event Implementation User activity (terms searched, interactions with content and advertisements, people interacted with or shared content, browsing history, IP Address, cookies, access logs, visit timestamps, service usage records, improper usage records), encrypted identifying information (CI).
	•	Customer Center Counseling Process Web pages, emails, faxes, calls, chats.

Article 3 [Methods of Collecting Personal Information]
	•	When users agree to the collection of personal information during the membership registration and service usage process and directly input information, the Company collects such information.
	•	Personal information may be collected through inquiries via apps or web services or counseling processes through the customer center.
	•	The company may receive personal information from external companies or organizations affiliated with it. In such cases, the company must obtain the user's consent to provide personal information to the affiliated company.
	•	Information generated through log analysis during the company's service usage process and information collected via cookies may be automatically collected.

Article 4 [Provision of Personal Information to Third Parties] The company uses user personal information within the scope notified in 'Article 1 - Purpose of Processing Personal Information' and does not generally provide it to third parties unless:
	•	It is provided in a form that cannot identify specific individuals for statistical analysis, academic research, or market research purposes.
	•	Users have agreed in advance.
	•	There are legal requirements, or upon the request of investigative agencies, following the legal procedures and methods stipulated by the law.

Article 5 [Outsourcing of Personal Information Processing]
	•	The Company does not outsource the processing of user's personal information. However, in the future during the process of providing services, the Company may outsource the handling of personal information. In such cases, the Company will inform the user through this privacy policy or obtain the user's consent as required by relevant laws regarding the outsourcing of personal information processing.
	•	When entering into a contract involving outsourced personal information processing, the Company will document and specify matters related to prohibiting the handling of personal information beyond the outsourcing purpose, technical and managerial protective measures, restrictions on re-outsourcing, management and supervision of the trustee, responsibility for damages, etc.
	•	If there are changes in the content of the outsourced tasks or the trustee, such changes will be promptly disclosed through this privacy policy.

Article 6 [Installation, Operation, and Refusal of Automatic Collection Devices for Personal Information]
	•	The Company collects cookies to enable users to conveniently use the website. Cookies are tiny files sent by the website server to the user's browser and stored on the user's computer.
	•	Users can configure settings to allow or block cookies. However, blocking cookie storage may cause difficulties in using the services.

Article 7 [Guidance on Access Permissions]
	•	For mobile app services, the Company may access and use information and functions within the customer's mobile communication device as follows:
	•	(Required) Device and app logs: for device identification and app status/version confirmation.
	•	(Optional) Camera: for shooting and scanning QR codes.
	•	(Optional) Biometrics: for login purposes, etc.

	•	Required and optional access items will be explained and consent will be obtained when installing the app or upon the first run. For optional access items, denying access may not restrict basic service usage, and the method of obtaining consent may vary depending on the operating system version.

Article 8 [Retention and Use Period of Personal Information]
	•	The Company handles and retains personal information within the period stipulated by laws or the consent-obtained duration from the customer when collecting personal information.
	•	The utilization and retention periods for each type of personal information are as follows:
	•	Information entered during membership registration: until membership withdrawal or as required by law.
	•	In cases where investigations or inquiries are being conducted due to legal violations: until the completion of the relevant investigation or inquiry.

Article 9 [Procedure and Method for Destruction of Personal Information]
	•	The company promptly destroys personal information when it becomes unnecessary due to the expiration of the retention period or achievement of the processing purpose.
	•	If personal information must be retained further according to other laws despite the expiration of the consent-based retention period from the user or the achievement of the processing purpose, the company separately transfers the relevant personal information to another database or stores it in a different location for preservation.
	•	The procedure and method for the destruction of personal information are as follows:
	•	Procedure The company selects the personal information for destruction when the grounds for destruction arise and destroys the personal information after obtaining approval from the company's personal information protection manager.
	•	Method The company uses technical methods that render electronic files unrecoverable for the destruction of electronically recorded and stored personal information. Personal information recorded or stored on paper documents is shredded for destruction.

Article 10 [Rights, Obligations, and Exercise Methods of the Data Subject]
	•	Users can exercise the following rights regarding personal information protection at any time:
	•	Request for access to personal information.
	•	Request for correction in case of errors.
	•	Request for deletion.
	•	Request for suspension of processing.

	•	The exercise of rights under clause 1 can be done through written forms, telephone, email, fax, etc., and the company promptly takes action in response.
	•	If a user requests correction or deletion of personal information errors, the company does not use or provide such personal information until the correction or deletion is completed.
	•	The rights under clause 1 can be exercised through legal representatives or authorized agents.
	•	Users cannot infringe upon the personal information and privacy of themselves or others processed by the company, violating laws related to information and communication networks, personal information protection, and other relevant laws.

Article 11 [Measures for Securing Personal Information]
The company implements technical, managerial, and physical measures to ensure the security of user's personal information against loss, theft, leakage, alteration, or damage:
	•	Managerial measures:
	•	Establishment and enforcement of an internal personal information management plan.
	•	Minimization and education of personal information handlers.

	•	Technical measures:
	•	Access restriction to personal information.
	•	Maintenance and prevention of alteration in access records.

	•	Physical measures:
	•	Control of unauthorized access.

The company does not take responsibility for incidents arising from user negligence or general internet risks. Users have an obligation to protect their personal information by appropriately managing their IDs and passwords. The company is not liable for problems arising from user carelessness or internet-related issues resulting in the leakage of personal information like email addresses or passwords.

Article 12 [Personal Information Protection Manager]
The company appoints a personal information protection manager responsible for overseeing tasks related to personal information processing, handling user complaints, and providing remedies related to personal information processing issues:

Personal Information Protection Manager
	•	Manager: Chief Information Protection Officer
	•	Email Address: byffin@byffin.io

Department Responsible for Personal Information Protection
	•	Department: Operations Team
	•	Email Address: byffin@byffin.io

Effective as of November 20, 2023, this privacy policy is applicable.
''';

String policy2En = '''
	•	Consent for Marketing Use and Receipt of Advertising Information 
(1) You may refuse to consent to the selective collection and use or provision of personal (credit) information. However, if you do not consent, there may be restrictions on benefits related to convenience provisions (event notifications, announcements, discounts, etc.) based on the purpose of use. There are no disadvantages related to the contract. Even if you have consented, you may request to withdraw your consent or to stop contacting you for marketing purposes.
	•	Purpose of Collection and Use
(1) Collection and use are for the purpose of providing convenience to customers, informing about products or services from your company and affiliated companies, encouraging use, conducting gifts or promotional events, marketing activities, market research, and product or service development studies.
	•	Items of Collection and Use
(1) Personal identifying information: Email address
(2) Service usage records, IP address, user-generated data (cookies)

	•	Retention Period 
(1) Kept and used from the date of consent until withdrawal of membership or cancellation of marketing consent.
	•	For more detailed information, please refer to the Privacy Policy.
''';

