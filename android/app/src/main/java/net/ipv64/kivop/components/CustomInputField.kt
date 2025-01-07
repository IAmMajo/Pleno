package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun CustomInputField(
    label: String,
    labelColor: Color = Background_prime,
    placeholder: String,
    modifier: Modifier = Modifier,
    isPasswort: Boolean = false,
    value: String,
    backgroundColor: Color = Background_prime,
    onValueChange: (String) -> Unit,
) {
  val textState = remember { mutableStateOf(TextFieldValue()) }

  Column(modifier = modifier.fillMaxWidth()) {
    Text(
        text = label,
        style = MaterialTheme.typography.titleMedium,
        color = labelColor,
        modifier = Modifier.fillMaxWidth())
    val visualTransformation =
        if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None
    OutlinedTextField(
      visualTransformation = visualTransformation,
      value = value,
      colors =
        OutlinedTextFieldDefaults.colors(
          focusedContainerColor = backgroundColor,
          unfocusedContainerColor = backgroundColor,
          disabledContainerColor = backgroundColor,
          unfocusedBorderColor = backgroundColor,
          focusedBorderColor = backgroundColor,
        ),
      singleLine = true,
      onValueChange = onValueChange,
      modifier = Modifier.fillMaxWidth(),
      textStyle = MaterialTheme.typography.titleMedium.copy(color = Text_prime),
      placeholder = {
        Text(text = placeholder, color = Text_tertiary.copy(0.4f), style = MaterialTheme.typography.titleMedium)
      })
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
        onValueChange = { username = it })
  }
}
