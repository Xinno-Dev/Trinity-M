import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

const Color THEME_MAIN_BG_COLOR = Color(0xFFE8E7EB);
const Color THEME_CARD_BG_COLOR = Color(0xFF58575B);

const double common_m_radius = 8.0;

final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: WHITE,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: WHITE,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
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
    indicatorColor: Colors.grey,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: PRIMARY).copyWith(background: WHITE)
);

final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: PRIMARY,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.black,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed, //선택된 버튼 이동/고정
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

