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

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

enum class TextFieldStatus {
  nothing,
  pending,
  done,
}

@Composable
fun DebouncedTextFieldCustomInputField(
    label: String,
    labelColor: Color = Background_prime,
    placeholder: String,
    modifier: Modifier = Modifier,
    isPasswort: Boolean = false,
    singleLine: Boolean = true,
    lines: Int = 1,
    value: String,
    backgroundColor: Color = Background_prime,
    status: () -> TextFieldStatus = { TextFieldStatus.nothing },
    onValueChange: (String) -> Unit,
    onDebouncedChange: (String) -> Unit
) {
  LaunchedEffect(value) {
    delay(2000)
    onDebouncedChange(value) // Call function after user stops typing
  }
  Column(modifier = modifier.fillMaxWidth()) {
    if (label.isNotEmpty()) {
      Text(
          text = label,
          style = TextStyles.contentStyle,
          color = labelColor,
          modifier = Modifier.fillMaxWidth())
      SpacerBetweenElements(4.dp)
    }
    val visualTransformation =
        (if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None).also {
          OutlinedTextField(
              visualTransformation = it,
              value = value,
              colors =
                  OutlinedTextFieldDefaults.colors(
                      focusedContainerColor = backgroundColor,
                      unfocusedContainerColor = backgroundColor,
                      disabledContainerColor = backgroundColor,
                      unfocusedBorderColor =
                          if (status() == TextFieldStatus.pending) Color.Yellow
                          else if (status() == TextFieldStatus.done) Color.Green
                          else backgroundColor,
                      focusedBorderColor =
                          if (status() == TextFieldStatus.pending) Color.Yellow
                          else if (status() == TextFieldStatus.done) Color.Green
                          else backgroundColor,
                      focusedTextColor = Text_prime,
                      unfocusedTextColor = Text_prime),
              singleLine = singleLine,
              maxLines = if (singleLine) 1 else lines,
              minLines = lines,
              onValueChange = onValueChange,
              modifier = Modifier.fillMaxWidth(),
              textStyle = TextStyles.contentStyle,
              placeholder = {
                Text(
                    text = placeholder,
                    color = Text_tertiary.copy(0.4f),
                    style = TextStyles.contentStyle)
              })
        }
  }
}
