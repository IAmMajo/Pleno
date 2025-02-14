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

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// Set of Material typography styles to start with
val Typography =
    Typography(
        // Inhalt
        bodyMedium =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Normal,
                fontSize = 14.sp,
                lineHeight = 16.sp,
                letterSpacing = 0.5.sp),
        // Hervorgehebter Inhalt
        bodyLarge =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 16.sp,
                lineHeight = 18.sp,
                letterSpacing = 0.5.sp),
        // Buttons,Labels
        labelLarge =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 16.sp,
                lineHeight = 18.sp,
                letterSpacing = 0.5.sp),
        labelMedium =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 14.sp,
                lineHeight = 16.sp,
                letterSpacing = 0.5.sp),
        // Überschriften
        headlineLarge =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 30.sp,
                lineHeight = 32.sp,
                letterSpacing = 0.5.sp),
        // Überschriften in Elementen
        headlineMedium =
            TextStyle(
                fontFamily = robotoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 20.sp,
                lineHeight = 22.sp,
                letterSpacing = 0.5.sp),
    )
