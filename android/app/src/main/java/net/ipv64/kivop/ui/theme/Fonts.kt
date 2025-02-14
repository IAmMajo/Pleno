// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

// Todo: Aline entfernen. FontStyle.kt already exists
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
