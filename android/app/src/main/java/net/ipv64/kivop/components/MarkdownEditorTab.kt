package net.ipv64.kivop.components

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Text_prime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MarkdownEditorTab(
  editableMarkdown: String,
  onMarkdownChange: (String) -> Unit
) {
  Column(
    modifier = Modifier
      .fillMaxWidth()
      .padding(16.dp)
  ) {
    TextField(
      value = editableMarkdown,
      onValueChange = { newValue ->
        Log.d("MarkdownEditor", "TextField changed: $newValue")
        onMarkdownChange(newValue)
      },
      modifier = Modifier
        .fillMaxWidth()
        .weight(1f, fill = true)
        .background(color = Color.Transparent),
      colors = TextFieldDefaults.colors(
        focusedTextColor = Text_prime,
        unfocusedTextColor = Text_prime,
        focusedContainerColor = Color.Transparent, // Hintergrund transparent
        unfocusedContainerColor = Color.Transparent,
        disabledContainerColor = Color.Transparent,
        focusedIndicatorColor = Color.Transparent,  // Linienfarbe fokussiert
        unfocusedIndicatorColor = Color.Transparent, // Linienfarbe unfokussiert
      ),
      
      
     
    )
  }
}

@Composable
fun MarkdownPreviewTab(markdown: String,modifier: Modifier) {
  Log.d("MarkdownPreview", "Markdown content: $markdown")
  Column(
    modifier = modifier
  ) {
    Markdown(
      modifier = Modifier.fillMaxSize(),
      markdown = markdown,
      fontColor = Text_prime
    )
  }
}
