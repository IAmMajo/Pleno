package com.example.kivopandriod.components

import android.inputmethodservice.Keyboard.Row
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.ui.theme.Text_light
import org.commonmark.node.Text

@Composable
fun Subtitles(subText: String) {
  
  Column(modifier =
  Modifier.fillMaxWidth().padding(start = 12.dp))  {
    Text(
      text = subText,
      color = Text_light,
      style = MaterialTheme.typography.bodySmall,
      fontWeight = FontWeight.Bold
    )
  }
}

@Preview(showBackground = true)
@Composable
fun SubtitlesPreview() {
  
  ListsItemPreview()
  
}