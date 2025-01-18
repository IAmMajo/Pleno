package net.ipv64.kivop.models

import androidx.compose.ui.graphics.Color
import net.ipv64.kivop.ui.theme.Background_secondary
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
var neutralBttonStyle = ButtonStyle(Signal_neutral_20, Signal_neutral, textContentStyle)
var alertButtonStyle = ButtonStyle(Signal_red, Background_secondary, textContentStyle)
var alertSecondaryButtonStyle = ButtonStyle(Signal_red_20, Text_tertiary, textContentStyle)
var textButtonStyle = ButtonStyle(Color.Transparent, Primary, textContentUnderlineStyle)
