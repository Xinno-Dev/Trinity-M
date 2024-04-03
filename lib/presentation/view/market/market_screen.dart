import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/mainBox.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';

import '../../../common/const/utils/languageHelper.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  static String get routeName => 'marketScreen';
  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final categoryN = ['전체','골프','F&B','숙박','여행','공연','푸드','기타',];
  final controller = ScrollController();
  var selectTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(TR(context, 'Market')),
            centerTitle: true,
            automaticallyImplyLeading: false,
            titleTextStyle: typo16bold,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(Icons.search)
                ),
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.more_vert)
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: _buildCategoryBar(),
            )
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              List.generate(20, (index) => _buildContentItem(index)),
            ),
          )
        ],
      ),
    );
  }

  _buildCategoryBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List<Widget>.of(categoryN.map((e) =>
            _buildCategoryItem(e, categoryN.indexOf(e)))),
        ),
      ),
    );
  }

  _buildCategoryItem(String title, int index) {
    final isSelected = index == selectTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? GRAY_80 : GRAY_10,
        ),
        child: Text(title,
          style: typo12semibold100.copyWith(color: isSelected ? WHITE : GRAY_80)),
      )
    );
  }

  _buildContentItem(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: PRIMARY_10,
      elevation: 3,
      child: Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Content $index', style: typo14bold),
          ],
        )
      ),
    );
  }
}
