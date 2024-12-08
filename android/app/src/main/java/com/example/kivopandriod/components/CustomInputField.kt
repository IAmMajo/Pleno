package com.example.kivopandriod.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun CustomInputField(
    label: String,
    placeholder: String,
    modifier: Modifier = Modifier,
    isPasswort: Boolean = false,
    horizontalPadding: Dp = 16.dp,
    verticalPadding: Dp = 8.dp,
    value: String,
    onValueChange: (String) -> Unit,
) {
  val textState = remember { mutableStateOf(TextFieldValue()) }

  Column(
      modifier =
          modifier
              .padding(horizontal = horizontalPadding, vertical = verticalPadding)
              .fillMaxWidth()) {
        Text(
            text = label,
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.fillMaxWidth())
        val visualTransformation =
            if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None
        OutlinedTextField(
            visualTransformation = visualTransformation,
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text(text = placeholder) })
      }
}

@Preview(showBackground = true)
@Composable
fun CustomInputFieldPreview() {
  var username by remember { mutableStateOf("") }
  Column() {
    // Erstes CustomInputField
    CustomInputField(
        label = "Vorname",
        placeholder = "Gib deinen Vornamen ein",
        value = username,
        onValueChange = { username = it })

    //            // Zweites CustomInputField
    //            CustomInputField(
    //                label = "Nachname",
    //                placeholder = "Gib deinen Nachnamen ein",
    //
    //            )
  }
}
