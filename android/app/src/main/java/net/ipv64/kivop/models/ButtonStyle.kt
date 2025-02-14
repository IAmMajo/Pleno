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

package net.ipv64.kivop.models

import androidx.compose.ui.graphics.Color
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Background_tertiary
import net.ipv64.kivop.ui.theme.CustomFontStyle
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_neutral_20
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Signal_red_20
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_tertiary
import net.ipv64.kivop.ui.theme.textContentStyle
import net.ipv64.kivop.ui.theme.textContentUnderlineStyle

data class ButtonStyle(
    var backgroundColor: Color,
    var contentColor: Color,
    var textStyle: CustomFontStyle,
    // ToDo?
    // var selectedBackgroundColor: Color,
    // var selectedContentColor: Color,
    // var disabledBackgroundColor: Color,
    // var disabledContentColor: Color,
)

var primaryButtonStyle = ButtonStyle(Tertiary, Background_secondary, textContentStyle)
var secondaryButtonStyle = ButtonStyle(Secondary, Text_tertiary, textContentStyle)
var neutralButtonStyle = ButtonStyle(Signal_neutral_20, Signal_neutral, textContentStyle)
var alertButtonStyle = ButtonStyle(Signal_red, Background_secondary, textContentStyle)
var alertSecondaryButtonStyle = ButtonStyle(Signal_red_20, Text_tertiary, textContentStyle)
var textButtonStyle = ButtonStyle(Color.Transparent, Primary, textContentUnderlineStyle)
var posterButtonStyle =
    ButtonStyle(Background_secondary.copy(0.15f), Background_tertiary, textContentStyle)
