import '../../../common/common_package.dart';

BuildContext? dialogContext;

showLoadingDialog(BuildContext context, String message, {var isShowIcon = true}) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    barrierDismissible: false, // lock touched close..
    builder: (BuildContext context) {
      dialogContext = context;
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: 400
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isShowIcon)...[
                CircularProgressIndicator(
                  color: PRIMARY_90,
                ),
                SizedBox(width: 20),
              ],
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
  if (dialogContext == null) return;
  dialogContext!.pop();
  dialogContext = null;
}

