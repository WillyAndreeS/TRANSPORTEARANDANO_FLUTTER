import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Colors that we use in our app
const kPrimaryColor = Color(0xFF00AB74);
const kTextColor = Color(0xFF3C4046);
const kBackgroundColor = Color(0xFFF9F8FD);

// ignore: constant_identifier_names
const url_base = "https://190.223.54.4/";

const double kDefaultPadding = 20.0;

const kSpacingUnit = 10;

const kDarkPrimaryColor = Color(0xFF4FB75A);
const kArandano = Color(0xFF455AB4);
const kDarkSecondaryColor = Color(0xFF757A63);
const kPanetone = Color(0xFF4FB75A);
const kLightPrimaryColor = Color(0xFFFFFFFF);
const kLightSecondaryColor = Color(0xFFF3F7FB);
const kAccentColor = Color(0xFFFFC107);

final kTitleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
  fontWeight: FontWeight.w100,
);

final kButtonTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
  fontWeight: FontWeight.w400,
  color: kDarkPrimaryColor,
);

final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'SFProText',
  primaryColor: kDarkPrimaryColor,
  canvasColor: kDarkPrimaryColor,
  backgroundColor: kDarkSecondaryColor,
  iconTheme: ThemeData.dark().iconTheme.copyWith(
        color: kLightSecondaryColor,
      ),
  textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'SFProText',
        bodyColor: kLightSecondaryColor,
        displayColor: kLightSecondaryColor,
      ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kAccentColor),
);

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'SFProText',
  primaryColor: kLightPrimaryColor,
  canvasColor: kLightPrimaryColor,
  backgroundColor: kLightSecondaryColor,
  iconTheme: ThemeData.light().iconTheme.copyWith(
        color: kDarkSecondaryColor,
      ),
  textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'SFProText',
        bodyColor: kDarkSecondaryColor,
        displayColor: kDarkSecondaryColor,
      ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kAccentColor),
);
