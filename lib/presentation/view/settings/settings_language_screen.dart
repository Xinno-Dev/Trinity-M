import '../../../../common/common_package.dart';
import '../../../../common/provider/language_provider.dart';
import '../../../../services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/CustomCheckBox.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/style/colors.dart';

class SettingsLanguageScreen extends ConsumerStatefulWidget {
  const SettingsLanguageScreen({super.key});
  static String get routeName => 'settings_language';
  @override
  _SettingsLanguageScreenState createState() =>
      _SettingsLanguageScreenState();
}

class _SettingsLanguageScreenState
    extends ConsumerState<SettingsLanguageScreen> {

  @override
  WidgetRef get ref => context as WidgetRef;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var prov = ref.watch(languageProvider);
    return Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: CustomBackButton(
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(
            TR(context, '언어 설정'),
            style: typo18semibold,
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
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      ...List.generate(LanguageHelper.supportedLocales.length,
                        (index) => _buildLanguageItem(context, index)),
                    ]
                  )
                )
              )
            );
          }
        )
      )
    );
  }

  Widget _buildLanguageItem(context, index) {
    final localeTitle = LanguageHelper().getLocaleName(index);
    final locale = LanguageHelper.supportedLocales[index];
    final isSelected = locale.languageCode == ref.read(languageProvider).getLocale!.languageCode;
    print('---> _buildLanguageItem : ${locale.languageCode} / ${ref.read(languageProvider).getLocale!.languageCode}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          alignment: Alignment.centerLeft,
          child: CustomCheckbox(
            title: localeTitle,
            checked: isSelected,
            pushed: false,
            localAuth: true,
            height: 60,
            onChanged: (value) {
              print('=====> language : $index => ${locale.languageCode}');
              final lang = ref.read(languageProvider);
              lang.changeLocale(locale.languageCode);
            },
          )
        ),
      ],
    );
  }
}