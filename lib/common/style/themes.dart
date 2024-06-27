import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

const Color THEME_MAIN_BG_COLOR = Color(0xFFE8E7EB);
const Color THEME_CARD_BG_COLOR = Color(0xFF58575B);

const double common_m_radius = 18.0;

final ThemeData lightTheme = ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: WHITE,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: WHITE,
      surfaceTintColor: WHITE,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    highlightColor: Colors.white,
    disabledColor: Colors.grey[800],
    cardColor: Colors.grey[200],
    cardTheme: CardTheme(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
      backgroundColor: Colors.white
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMARY,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
        )),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: WHITE,
          elevation: 0,
          side: BorderSide(color: Colors.grey[800]!, width: 1),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
          // side: BorderSide(color: Colors.grey[800]!),
        )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WHITE,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.zero),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      // focusedBorder: InputBorder.none,
      // disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide.none, borderRadius: BorderRadius.zero),

      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // disabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // focusedBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
    ),
    indicatorColor: Colors.grey,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: PRIMARY).copyWith(background: WHITE)
);

final ThemeData darkTheme = ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: Colors.grey[900],
    primarySwatch: PRIMARY,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.grey),
      backgroundColor: Colors.grey[900],
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[200],
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    highlightColor: Colors.grey[900],
    disabledColor: Colors.white60,
    cardColor: Colors.grey[800],
    cardTheme: CardTheme(
      color: Colors.grey[800],
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        color: Colors.white70,
      ),
      bodyLarge: TextStyle(
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        color: Colors.white70,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[800],
      )
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
      backgroundColor: Colors.grey[800],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
        )),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: PRIMARY,
          elevation: 0,
          side: BorderSide(color: PRIMARY, width: 1),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
          // side: BorderSide(color: Colors.grey[800]!),
        )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WHITE,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.zero),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      // focusedBorder: InputBorder.none,
      // disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide.none, borderRadius: BorderRadius.zero),

      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // disabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // focusedBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
    ),
    indicatorColor: Colors.grey
);

final ThemeData darkWearTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: PRIMARY,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: GRAY_80,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
      backgroundColor: GRAY_80
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
        )),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: PRIMARY,
          elevation: 0,
          side: BorderSide(color: PRIMARY, width: 1),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(common_m_radius))),
          // side: BorderSide(color: Colors.grey[800]!),
        )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WHITE,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.zero),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.zero),
      // focusedBorder: InputBorder.none,
      // disabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide.none, borderRadius: BorderRadius.zero),

      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // disabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
      // focusedBorder: OutlineInputBorder(
      //     borderSide: BorderSide.none,
      //     borderRadius: BorderRadius.circular(common_m_radius)),
    ),
    indicatorColor: Colors.grey
);

