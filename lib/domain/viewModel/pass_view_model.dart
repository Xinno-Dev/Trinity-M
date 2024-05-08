
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../presentation/view/signup/signup_terms_screen.dart';

enum PassType {
  signIn,
  signUp,
  cloudUp,
  cloudDown;

  get title {
    switch(this) {
      case PassType.signIn: return '비밀번호 확인';
      case PassType.cloudUp: return '지갑 복구';
      case PassType.cloudDown: return '지갑 복구';
      default: return '비밀번호 등록';
    }
  }

  get info1 {
    switch(this) {
      case PassType.signIn:
        return '비밀번호를\n입력해 주세요.';
      case PassType.cloudUp:
        return '복구 비밀번호를\n등록해 주세요.';
      case PassType.cloudDown:
        return '복구 비밀번호를\n입력해 주세요.';
      default: return '비밀번호를\n등록해 주세요.';
    }
  }

  get info2 {
    switch(this) {
      case PassType.signIn:
        return '회원가입시 생성한\n비밀번호를 입력해 주세요.';
      case PassType.cloudUp:
        return '클라우드에 복구 단어를 백업합니다.\n'
            '앱 재설치시 복구 비밀번호를 사용하여\n지갑복구가 가능합니다.';
      case PassType.cloudDown:
        return '클라우드에 백업시 생성한\n비밀번호를 입력해 주세요.';
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
    loginProv.emailStep   = EmailSignUpStep.none;
    loginProv.recoverStep = RecoverPassStep.none;
    passInputController[0].text = loginProv.inputPass[0];
    passInputController[1].text = loginProv.inputPass[1];
  }

  get comparePass {
    LOG('--> comparePass : ${passInputController[0].text} / ${passInputController[1].text}');
    return passInputController[0].text.length > 4 &&
      passInputController[0].text == passInputController[1].text;
  }

  get password {
    return passInputController[0].text;
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