import 'package:flutter/material.dart';
import 'colors.dart';

const kFontGrotesk = 'SpaceGrotesk';
const kFontMono = 'JetBrainsMono';

class MeshTextStyles {
  MeshTextStyles._();

  static const headline = TextStyle(
    fontFamily: kFontGrotesk,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: kText,
    letterSpacing: -0.5,
  );

  static const title = TextStyle(
    fontFamily: kFontGrotesk,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: kText,
    letterSpacing: -0.3,
  );

  static const body = TextStyle(
    fontFamily: kFontGrotesk,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kText,
  );

  static const caption = TextStyle(
    fontFamily: kFontGrotesk,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: kTextMuted,
  );

  static const mono = TextStyle(
    fontFamily: kFontMono,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: kTextMuted,
    letterSpacing: -0.1,
  );

  static const monoSmall = TextStyle(
    fontFamily: kFontMono,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: kTextDim,
    letterSpacing: 0.08,
  );

  static const label = TextStyle(
    fontFamily: kFontMono,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: kTextMuted,
    letterSpacing: 0.6,
  );
}
