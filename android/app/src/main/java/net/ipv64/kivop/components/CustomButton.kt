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

package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.models.ButtonStyle
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles

@Composable
// ToDo - ButtonStyle ergänzen
fun CustomButton(
    modifier: Modifier,
    buttonStyle: ButtonStyle? = null,
    text: String = "Button",
    color: Color = Color.Gray,
    fontColor: Color = Color.Black,
    onClick: () -> Unit = {},
    enabled: Boolean = true
    // ToDo - Icon-Option ergänzen?
) {
  if (buttonStyle != null) {
    Box(
        contentAlignment = Alignment.Center,
        modifier =
            modifier
                .fillMaxWidth()
                .height(44.dp)
                .clip(shape = RoundedCornerShape(100.dp))
                .background(color = buttonStyle.backgroundColor)
                .clickable(enabled = enabled, onClick = onClick)) {
          Text(text, color = buttonStyle.contentColor, style = TextStyles.largeContentStyle)
        }
  } else {
    Box(
        contentAlignment = Alignment.Center,
        modifier =
            modifier
                .fillMaxWidth()
                .height(44.dp)
                .clip(shape = RoundedCornerShape(100.dp))
                .background(color = color)
                .clickable(enabled = enabled, onClick = onClick)) {
          Text(text, color = fontColor, style = TextStyles.largeContentStyle)
        }
  }
}

@Composable
fun CustomPopupButton(
    text: String,
    buttonStyle: ButtonStyle?,
    // isEnabled: Boolean,
    onClick: () -> Unit,
    modifier: Modifier,
    enabled: Boolean = true,
) {
  if (buttonStyle == null) {
    Button(
        enabled = enabled,
        onClick = onClick,
        shape = RoundedCornerShape(100.dp),
        colors =
            ButtonDefaults.buttonColors(
                containerColor = Primary, contentColor = Background_secondary),
        modifier = modifier.height(35.dp).clip(shape = RoundedCornerShape(20.dp)),
    ) {
      Text(
          text = text,
          style = TextStyles.largeContentStyle,
      )
    }
  } else {
    Button(
        enabled = enabled,
        onClick = onClick,
        shape = RoundedCornerShape(20.dp),
        colors =
            ButtonDefaults.buttonColors(
                containerColor = buttonStyle.backgroundColor,
                contentColor = buttonStyle.contentColor),
        modifier = modifier.height(35.dp).clip(shape = RoundedCornerShape(20.dp)),
    ) {
      Text(
          text = text,
          style = TextStyles.largeContentStyle,
      )
    }
  }
}

// @Preview
// @Composable
// fun PreviewScreen(){
//  CustomPopupButton("hello,click me", primaryButtonStyle, onClick = {}, modifier = Modifier)
//
// }
