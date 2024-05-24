import '../style/colors.dart';

enum CD_PROD_TYPE {
  main,     // 메인(일반) 상품
  option,   // 부가(옵션) 상품
}

enum CD_SALE_ST {
  sale,     // 판매중
  close,    // 판매완료
  cancel,   // 판매취소(판매자)
  cancelEx, // 판매취소(관리자)
}

enum CD_ITEM_ST {
  live,
  deleted,
}

enum CD_ITEM_TYPE {
  ticket,
  art,
}

enum CD_PAY_ST {
  ready,    // 1
  done,     // 2
  verify,   // 3
  complete, // 4
  cancel;   // 99

  get number {
    switch(this) {
      case CD_PAY_ST.ready:
        return '1';
      case CD_PAY_ST.done:
        return '2';
      case CD_PAY_ST.verify:
        return '3';
      case CD_PAY_ST.complete:
        return '4';
      default:
        return '99';
    }
  }

  get title {
    switch(this) {
      case CD_PAY_ST.ready:
        return '결제대기';
      case CD_PAY_ST.done:
        return '결제완료';
      case CD_PAY_ST.verify:
        return '결제검증';
      case CD_PAY_ST.complete:
        return '구매완료';
      default:
        return '구매실패';
    }
  }

  get color {
    switch(this) {
      case CD_PAY_ST.ready:
        return GRAY_50;
      case CD_PAY_ST.done:
        return GRAY_50;
      case CD_PAY_ST.verify:
        return GRAY_50;
      case CD_PAY_ST.complete:
        return SECONDARY_90;
      default:
        return ERROR_90;
    }
  }
}

