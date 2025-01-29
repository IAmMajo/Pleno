package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun MultiProgressBar(
  progress1: Int,
  progress2: Int,
  progress3: Int,
  progress4: Int,
  progress1Color: Color = Color.Red,
  progress2Color: Color = Color.Green,
  progress3Color: Color = Color.Blue,
  progress4Color: Color = Color.Yellow,
  progress1TextColor: Color = Text_prime,
  progress2TextColor: Color = Text_prime,
  progress3TextColor: Color = Text_prime,
  progress4TextColor: Color = Text_prime,
  progress1Label: String = "Progress 1",
  progress2Label: String = "Progress 2",
  progress3Label: String = "Progress 3",
  progress4Label: String = "Progress 4",
  modifier: Modifier = Modifier,
  barHeight: Int = 20
) {
  // Calculate the total progress
  val totalProgress = progress1 + progress2 + progress3 + progress4
  // Calculate the progress for each bar
  val progress1Percentage = progress1.toFloat() / totalProgress
  val progress2Percentage = progress2.toFloat() / totalProgress
  val progress3Percentage = progress3.toFloat() / totalProgress
  val progress4Percentage = progress4.toFloat() / totalProgress
  //TODO: Change colors!!
  Column(
  ) {
    Row(modifier = Modifier.fillMaxWidth()) {
      //Progress 1 lable
      if (progress1 > 0){
        Box(modifier = Modifier.background(progress1Color.copy(0.2f), shape = RoundedCornerShape(2.dp)).padding(horizontal = 4.dp,vertical = 2.dp)) {
          Text(text = "$progress1Label: $progress1",style = TextStyles.contentStyle, color = progress1TextColor)
        }
        Spacer(modifier = Modifier.weight(1f))
      }
      //Progress 2 lable
      if (progress2 > 0){
        
        Box(modifier = Modifier.background(progress2Color.copy(0.2f), shape = RoundedCornerShape(2.dp)).padding(horizontal = 4.dp,vertical = 2.dp)) {
          Text(text = "$progress2Label: $progress2",style = TextStyles.contentStyle, color = progress2TextColor)
        }
      }
      //Progress 3 lable
      if (progress3 > 0){
        Spacer(modifier = Modifier.weight(1f))
        Box(modifier = Modifier.background(progress3Color.copy(0.2f), shape = RoundedCornerShape(2.dp)).padding(horizontal = 4.dp,vertical = 2.dp)) {
          Text(text = "$progress3Label: $progress3",style = TextStyles.contentStyle, color = progress3TextColor)
        }
      }
      //Progress 3 lable
      if (progress4 > 0){
        Spacer(modifier = Modifier.weight(1f))
        Box(modifier = Modifier.background(progress4Color.copy(0.2f), shape = RoundedCornerShape(2.dp)).padding(horizontal = 4.dp,vertical = 2.dp)) {
          Text(text = "$progress4Label: $progress4",style = TextStyles.contentStyle, color = progress4TextColor)
        }
      }
    }
    SpacerBetweenElements(12.dp)
    Box(
      modifier = modifier
        .fillMaxWidth()
        .height(barHeight.dp)
        .clip(shape = RoundedCornerShape(100))
        .background(color = Color.Gray) // Background track
    ){
      Row(modifier = Modifier.fillMaxSize()) {
        // First Progress
        if (progress1Percentage > 0)
          Box(
            modifier = Modifier
              .weight(progress1Percentage)
              .fillMaxHeight()
              .background(color = progress1Color)
          )
        // Second Progress
        if (progress2Percentage > 0)
          Box(
            modifier = Modifier
              .weight(progress2Percentage)
              .fillMaxHeight()
              .background(color = progress2Color)
          )
        // Third Progress
        if (progress3Percentage > 0)
          Box(
            modifier = Modifier
              .weight(progress3Percentage)
              .fillMaxHeight()
              .background(color = progress3Color)
          )
        // Fourth Progress
        if (progress4Percentage > 0)
          Box(
            modifier = Modifier
              .weight(progress4Percentage)
              .fillMaxHeight()
              .background(color = progress4Color)
          )
      }
    }
  }
}

@Preview
@Composable
fun MultiProgressBarPreview() {
  MultiProgressBar(
    progress1 = 5,
    progress2 = 5,
    progress3 = 0,
    progress4 = 0,
    barHeight = 16
  )
}