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

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.MaterialTheme.colors
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Text_prime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MarkdownEditorTab(
    editableMarkdown: String,
    onMarkdownChange: (String) -> Unit,
    modifier: Modifier
) {
  Column(modifier = modifier) {
    TextField(
        value = editableMarkdown,
        onValueChange = { newValue ->
          Log.d("MarkdownEditor", "TextField changed: $newValue")
          onMarkdownChange(newValue)
        },
        modifier = Modifier.background(color = Color.Transparent).fillMaxSize(),
        colors =
            TextFieldDefaults.colors(
                focusedTextColor = Text_prime,
                unfocusedTextColor = Text_prime,
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                disabledContainerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
            ),
    )
  }
}

@Composable
fun MarkdownPreviewTab(markdown: String, modifier: Modifier) {
  Log.d("MarkdownPreview", "Markdown content: $markdown")
  Column(modifier = modifier, horizontalAlignment = Alignment.Start) {
    Markdown(
        modifier = Modifier.fillMaxWidth().padding(8.dp),
        markdown = markdown,
        fontColor = Text_prime)
  }
}
