
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/const/utils/uihelper.dart';
import '../../presentation/view/signup/signup_terms_screen.dart';

enum PassType {
  signUp,
  recover;

  get title {
    switch(this) {
      case PassType.recover: return '지갑 복구';
      default: return '비밀번호 등록';
    }
  }

  get info1 {
    switch(this) {
      case PassType.recover:
        return '복구 비밀번호를\n등록해 주세요.';
      default: return '비밀번호를\n등록해 주세요.';
    }
  }

  get info2 {
    switch(this) {
      case PassType.recover:
        return '클라우드에 복구 단어를 백업합니다.\n'
            '앱 재설치시 복구 비밀번호를 사용하여\n지갑복구가 가능합니다.';
      default: return '비밀번호 등록을 진행합니다.';
    }
  }
}

class PassViewModel {
  PassViewModel(this.passType);
  final PassType passType;
  final passInputController = List.generate(2, (index) => TextEditingController());
  late WidgetRef ref;

  init(WidgetRef ref) {
    this.ref = ref;
    final loginProv = ref.read(loginProvider);
    if (passType == PassType.signUp) {
      passInputController[0].text = loginProv.inputPass[0];
      passInputController[1].text = loginProv.inputPass[1];
      loginProv.emailStep = EmailSignUpStep.none;
    } else {
      passInputController[0].text = loginProv.recoverPass[0];
      passInputController[1].text = loginProv.recoverPass[1];
      loginProv.recoverStep = RecoverPassStep.none;
    }
  }

  get title {
    return passType.title;
  }

  get info1 {
    return passType.info1;
  }

  get info2 {
    return passType.info2;
  }
}