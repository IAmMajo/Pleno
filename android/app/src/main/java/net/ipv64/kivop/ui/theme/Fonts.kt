package net.ipv64.kivop.ui.theme

import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import net.ipv64.kivop.R

val robotoFontFamily =
    FontFamily(
        Font(R.font.roboto_regular), // Regular weight
        Font(R.font.roboto_bold, weight = FontWeight.Bold), // Bold weight
        Font(R.font.roboto_italic, style = FontStyle.Italic) // Italic style
        )
