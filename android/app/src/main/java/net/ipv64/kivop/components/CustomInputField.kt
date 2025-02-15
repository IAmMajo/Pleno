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
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun CustomInputField(
    label: String? = null,
    labelColor: Color = Background_prime,
    placeholder: String,
    modifier: Modifier = Modifier,
    isPasswort: Boolean = false,
    singleLine: Boolean = true,
    lines: Int = 1,
    value: String,
    backgroundColor: Color = Background_prime,
    onValueChange: (String) -> Unit,
    isNumberOnly: Boolean = false,
    maxChars: Int? = null,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    focusRequester: FocusRequester = FocusRequester(),
    nextFocusRequester: FocusRequester? = null // Für Fokuswechsel zum nächsten Feld
) {
  val focusManager = LocalFocusManager.current // Steuerung des Fokus-Managements

  Column(modifier = modifier.fillMaxWidth()) {
    if (label != null) {
      Text(
          text = label,
          style = TextStyles.contentStyle,
          color = labelColor,
          modifier = Modifier.fillMaxWidth())
      SpacerBetweenElements(4.dp)
    }
    val visualTransformation =
        (if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None).also {
          Box() {
            OutlinedTextField(
                visualTransformation = it,
                value = value,
                colors =
                    OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = backgroundColor,
                        unfocusedContainerColor = backgroundColor,
                        disabledContainerColor = backgroundColor,
                        unfocusedBorderColor = backgroundColor,
                        focusedBorderColor = backgroundColor,
                        focusedTextColor = Text_prime,
                        unfocusedTextColor = Text_prime),
                singleLine = singleLine,
                maxLines = if (singleLine) 1 else lines,
                minLines = lines,
                onValueChange = onValueChange,
                modifier = Modifier.fillMaxWidth().focusRequester(focusRequester),
                textStyle = TextStyles.contentStyle,
                placeholder = {
                  Text(
                      text = placeholder,
                      color = Text_tertiary.copy(0.4f),
                      style = TextStyles.contentStyle)
                },
                keyboardOptions =
                    keyboardOptions.copy(
                        keyboardType = if (isNumberOnly) KeyboardType.Number else KeyboardType.Text,
                        imeAction =
                            if (nextFocusRequester != null) ImeAction.Next else ImeAction.Done),
                keyboardActions =
                    KeyboardActions(
                        onNext = {
                          nextFocusRequester?.requestFocus() // Springt zum nächsten Eingabefeld
                        },
                        onDone = {
                          focusManager.clearFocus() // Schließt die Tastatur
                        }))
            if (maxChars != null) {
              Box(modifier = Modifier.matchParentSize().zIndex(1f).padding(3.dp)) {
                val textColor =
                    if (value.length <= maxChars) Text_tertiary.copy(0.4f)
                    else Signal_red.copy(0.4f)
                Text(
                    text = "${value.length}/${maxChars}",
                    color = textColor,
                    style = TextStyles.contentStyle.copy(fontSize = 10.sp),
                    modifier = Modifier.align(Alignment.BottomEnd))
              }
            }
          }
        }
  }
}

@Preview(showBackground = true)
@Composable
fun CustomInputFieldPreview() {
  var username by remember { mutableStateOf("") }
  Column(modifier = Modifier.background(Signal_blue)) {
    // Erstes CustomInputField
    CustomInputField(
        label = "Vorname",
        placeholder = "Gib deinen Vornamen ein",
        value = username,
        onValueChange = { username = it })

    CustomInputField(
        label = "Vorname",
        placeholder = "Gib deinen Vornamen ein",
        value = username,
        onValueChange = { username = it },
        singleLine = false,
        lines = 3,
        maxChars = 10)
  }
}
