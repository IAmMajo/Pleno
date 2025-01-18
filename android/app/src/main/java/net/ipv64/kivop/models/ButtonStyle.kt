package net.ipv64.kivop.models

import androidx.compose.ui.graphics.Color
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Text_tertiary

data class ButtonStyle(
  var backgroundColor: Color,
  var contentColor: Color,
// ToDo?  
//var selectedBackgroundColor: Color,
//var selectedContentColor: Color,
//var disabledBackgroundColor: Color, 
//var disabledContentColor: Color,
)

var primaryButtonStyle = ButtonStyle(Primary, Background_secondary)
var secondaryButtonStyle = ButtonStyle(Secondary, Text_tertiary)
var alertButtonStyle = ButtonStyle(Signal_red, Background_secondary)
var textButtonStyle = ButtonStyle(Color.Transparent, Primary) //ToDo - add underlined text