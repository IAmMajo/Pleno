package net.ipv64.kivop

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.customRoundedTop


@Composable
fun DebugSliderTest() {
  // State for the height and width percentages
  var heightPercent by remember { mutableStateOf(50f) }
  var widthPercent by remember { mutableStateOf(30f) }

  // UI Layout
  Column(
    modifier = Modifier
      .fillMaxSize()
      .padding(0.dp),
    horizontalAlignment = Alignment.CenterHorizontally
  ) {
    // Slider for height percentage
    Text("Height Percent: ${heightPercent.toInt()}%")
    Slider(
      value = heightPercent,
      onValueChange = { heightPercent = it },
      valueRange = 0f..100f,
      steps = 100,
      modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp)
    )

    Spacer(modifier = Modifier.height(16.dp))

    // Slider for width percentage
    Text("Width Percent: ${widthPercent.toInt()}%")
    Slider(
      value = widthPercent,
      onValueChange = { widthPercent = it },
      valueRange = 0f..50f,
      steps = 100,
      modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp)
    )

    Spacer(modifier = Modifier.weight(1f))

    // Box with custom rounded top applied
    Box(
      modifier = Modifier
        .fillMaxWidth()
        .height(100.dp)
        .customRoundedTop(color = Color.Blue, heightPercent = heightPercent.toInt(), widthPercent = widthPercent.toInt())
    ) {
      // Optionally, you can add some content inside the box if you want
      Text("Testing customRoundedTop", modifier = Modifier.align(Alignment.Center), color = Color.White)
    }
  }
}

@Preview(showBackground = true)
@Composable
fun PreviewDebugSliderTest() {
  DebugSliderTest()
}
