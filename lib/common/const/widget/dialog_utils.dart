import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';

import '../../style/colors.dart';
import '../utils/convertHelper.dart';

BuildContext? _dialogContext;

showLoadingDialog(BuildContext context, String message, {var isShowIcon = true}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false, // lock touched close..
    builder: (BuildContext context) {
      _dialogContext = context;
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isShowIcon)
                CircularProgressIndicator(
                  color: PRIMARY_90,
                ),
              Text(message,
                style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white),
                  maxLines: 5, softWrap: true),
            ],
          ),
        )
      );
    },
  );
}

hideLoadingDialog() {
  if (_dialogContext == null) return;
  _dialogContext!.pop();
  _dialogContext = null;
}

