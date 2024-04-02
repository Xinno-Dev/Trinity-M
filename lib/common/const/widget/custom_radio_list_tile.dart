import '../../common_package.dart';

enum CustomRadioType {
  select,
  info,
}

class CustomRadioListTile extends StatelessWidget {
  CustomRadioListTile({
    super.key,
    required this.index,
    required this.name,
    required this.balance,
    this.image,
    this.isToken = false,
    this.tokenBalance = 1.00,
    this.tokenUnit = 'BIT',
    this.padding,
    this.backgroundColor,
    this.isSelected = false,
    this.type = CustomRadioType.select,
    this.onTap,
    this.onMenu,
  });

  final bool isSelected;
  final CustomRadioType type;
  final int index;
  final double balance, tokenBalance;
  final String name, tokenUnit;
  final bool isToken;
  final Widget? image;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Function()? onTap;
  final Function()? onMenu;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: padding ?? EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      tileColor: isSelected ? GRAY_20 : backgroundColor ?? WHITE,
      leading: image != null ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [image!],
      ) : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: typo16bold,
          ),
          if (isToken)...[
            SizedBox(
              height: 10.r,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      '$tokenBalance',
                      style: typo16medium,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      tokenUnit,
                      style: typo16regular,
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 8,
                // ),
              ],
            ),
          // Text(
          //   '\$$balance',
          //   style: isToken
          //       ? typo14regular.copyWith(color: GRAY_50)
          //       : typo14medium.copyWith(color: GRAY_70),
          // ),
          ]
        ],
      ),
      trailing: type == CustomRadioType.select ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 18.w,
            color: isSelected ? SECONDARY_90 : null,
            image: AssetImage('assets/images/radio_button_off.png'),
          ),
        ],
      ) : type == CustomRadioType.info ? InkWell(
        onTap: onMenu,
        child: Container(
          width: 40,
          height: double.infinity,
          alignment: Alignment.centerRight,
          child: Icon(Icons.more_horiz, size: 24),
        ),
      ) : null,
    );
  }
}
