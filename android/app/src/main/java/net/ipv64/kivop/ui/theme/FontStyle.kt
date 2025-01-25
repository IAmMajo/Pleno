package net.ipv64.kivop.ui.theme

import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

object TextStyles {
  val headingStyle =
      TextStyle(
          fontFamily = robotoFontFamily,
          fontWeight = FontWeight.Bold,
          fontSize = 28.sp,
          letterSpacing = 0.sp)

  val subHeadingStyle =
      TextStyle(
          fontFamily = robotoFontFamily,
          fontWeight = FontWeight.Bold,
          fontSize = 20.sp,
          letterSpacing = 0.sp)
  val largeContentStyle =
      TextStyle(
          fontFamily = robotoFontFamily,
          fontWeight = FontWeight.Bold,
          fontSize = 15.sp,
          letterSpacing = 0.1.sp)

  val contentStyle =
      TextStyle(
          fontFamily = robotoFontFamily,
          fontWeight = FontWeight.Medium,
          fontSize = 14.sp,
          letterSpacing = 0.2.sp)
}
