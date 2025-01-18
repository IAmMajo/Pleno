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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.models.ButtonStyle
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary

@Preview
@Composable
//ToDo - ButtonStyle ergänzen
fun CustomButton(
    modifier: Modifier = Modifier,
    text: String = "Button",
    color: Color = Color.Gray,
    fontColor: Color = Color.Black,
    onClick: () -> Unit = {},
    // ToDo - Icon-Option ergänzen?
) {
  Box(
      contentAlignment = Alignment.Center,
      modifier =
      modifier
        .fillMaxWidth()
        .height(60.dp) // todo: get dp from stylesheet
        .background(
          color = color, shape = RoundedCornerShape(16.dp) // todo: get dp from stylesheet
        )
        .clickable(onClick = onClick)
  ){
        Text(text, color = fontColor)
  }
}

@Composable
fun CustomPopupButton(
  text: String,
  buttonStyle: ButtonStyle?,
 // isEnabled: Boolean,
  onClick: () -> Unit,
  modifier: Modifier
) { 
  if(buttonStyle == null){
      Button(
        onClick = onClick,
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(
          containerColor = Primary,
          contentColor = Background_secondary
        ),
//        modifier = modifier
//          .clip(shape = RoundedCornerShape(20.dp)),
        ){ 
        Text(
          text = text,
          )
    }
  } else {
    Button(
      onClick = onClick,
      shape = RoundedCornerShape(20.dp),
      colors = ButtonDefaults.buttonColors(
        containerColor = buttonStyle.backgroundColor,
        contentColor = buttonStyle.contentColor
      ),
//      modifier = modifier
//        .clip(shape = RoundedCornerShape(20.dp)),
    ){
      Text(
        text = text,
      )
    } 
  }
}
