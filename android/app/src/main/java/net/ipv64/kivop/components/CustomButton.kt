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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Text_tertiary
import kotlin.math.round

@Preview
@Composable
fun CustomButton(
    modifier: Modifier = Modifier,
    text: String = "Button",
    color: Color = Color.Gray,
    fontColor: Color = Color.Black,
    onClick: () -> Unit = {},
    // ToDo: Icon-Option ergänzen?
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
  type: String, //"confirm" or "cancel"; [brauchen wir "alert" als status?]
 // isEnabled: Boolean,
  onClick: () -> Unit,
  modifier: Modifier
) { 
  if(type=="confirm"){
    // ToDo - die Farben werden nicht richtig angezeigt (background stimmt nicht)
      Button(
        onClick = onClick,
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(
          containerColor = Primary,
          contentColor = Signal_red
        ),
        modifier = modifier
          .clip(shape = RoundedCornerShape(16.dp)),
        ){ 
        Text(
          text = text,
          color = Background_secondary,
          )
    }
  } else {
    // ToDo - die Farben werden nicht richtig angezeigt
    Button(
      onClick = onClick,
      modifier = modifier
        .background(color = Secondary)
        .clip(shape = RoundedCornerShape(20.dp)),
    ){
      Text(
        text = text,
        color = Text_tertiary,
      )
    } 
  }
}

@Preview
@Composable
fun Screent() {
  fun fertig() = {}
  CustomPopupButton(
    text = "Confirm",
    type = "confirm",
   // isEnabled = true,
    onClick = fertig(),
    modifier = Modifier
  )
}