package net.ipv64.kivop.ui.theme

import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R

val robotoFontFamily =
    FontFamily(
        Font(R.font.roboto_regular), // Regular weight
        Font(R.font.roboto_bold, weight = FontWeight.Bold), // Bold weight
        Font(R.font.roboto_italic, style = FontStyle.Italic) // Italic style
        )
//Todo: Aline entfernen. FontStyle.kt already exists
data class CustomFontStyle(
    val fontFamily: FontFamily,
    val fontWeight: FontWeight?,
    val fontSize: TextUnit,
    val fontStyle: FontStyle? = null,
    val textDecoration: TextDecoration? = null,
    val textAlign: TextAlign? = null,
)

val textHeadingStyle =
    CustomFontStyle(
        robotoFontFamily, FontWeight.Bold, 28.sp, FontStyle.Normal, null, TextAlign.Start)
val textSubHeadingStyle =
    CustomFontStyle(
        robotoFontFamily, FontWeight.Bold, 20.sp, FontStyle.Normal, null, TextAlign.Start)
val textContentStyle =
    CustomFontStyle(
        robotoFontFamily, FontWeight.Normal, 14.sp, FontStyle.Normal, null, TextAlign.Start)
val textContentBoldStyle =
    CustomFontStyle(
        robotoFontFamily, FontWeight.Bold, 14.sp, FontStyle.Normal, null, TextAlign.Start)
val textContentUnderlineStyle =
    CustomFontStyle(
        robotoFontFamily,
        FontWeight.Normal,
        14.sp,
        FontStyle.Normal,
        TextDecoration.Underline,
        TextAlign.Start)
