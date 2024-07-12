import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyles {
  static TextStyle font12Style = GoogleFonts.nunitoSans(
    fontSize: 12.sp,
    color: Colors.black,
  );

  static TextStyle font14Style = GoogleFonts.nunitoSans(
    fontSize: 14.sp,
    color: Colors.black,
  );

  static TextStyle font16Style = GoogleFonts.nunitoSans(
    fontSize: 16.sp,
    color: Colors.black,
  );

  static TextStyle font18Style = GoogleFonts.nunitoSans(
    fontSize: 18.sp,
    color: Colors.black,
  );

  static TextStyle font20Style = GoogleFonts.nunitoSans(
    fontSize: 20.sp,
    color: Colors.black,
  );
}

TextStyle appStyle(double size, Color color, FontWeight fw) {
  return GoogleFonts.poppins(fontSize: size.sp, color: color, fontWeight: fw);
  // return TextStyle(
  //     fontSize: size.sp, color: color, fontWeight: fw, fontFamily: "PALATIN1");
}
