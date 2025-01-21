package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

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
    onValueChange: (String) -> Unit,
    onDebouncedChange: (String) -> Unit
) {
  val textState = remember { mutableStateOf(TextFieldValue()) }
  LaunchedEffect(value) {
    delay(2000)
    onDebouncedChange(value) // Call function after user stops typing
  }
  Column(modifier = modifier.fillMaxWidth()) {
    Text(
        text = label,
        style = TextStyles.contentStyle,
        color = labelColor,
        modifier = Modifier.fillMaxWidth())
    val visualTransformation =
      (if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None).also {
        SpacerBetweenElements(4.dp)
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
                    unfocusedTextColor = Text_prime
                ),
            singleLine = singleLine,
            maxLines=  if (singleLine) 1 else lines,
            minLines=  lines,
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

