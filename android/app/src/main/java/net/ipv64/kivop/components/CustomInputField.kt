package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
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
  focusRequester: FocusRequester = FocusRequester(), // Hinzugefügt: FocusRequester
  nextFocusRequester: FocusRequester? = null, // Optional: Für den nächsten Fokus
  imeAction: ImeAction = ImeAction.Done // Standardmäßig "Done", kann angepasst werden
) {
  Column(modifier = modifier.fillMaxWidth()) {
    // Label
    Text(
      text = label,
      style = MaterialTheme.typography.titleMedium,
      color = labelColor,
      modifier = Modifier.fillMaxWidth()
    )

    // Visual Transformation (für Passwort-Felder)
    val visualTransformation =
      if (isPasswort) PasswordVisualTransformation() else VisualTransformation.None

    // Eingabefeld
    OutlinedTextField(
      visualTransformation = visualTransformation,
      value = value,
      onValueChange = onValueChange,
      singleLine = true,
      textStyle = TextStyle(Text_prime, fontWeight = FontWeight.SemiBold, fontSize = 16.sp),
      modifier = Modifier
        .fillMaxWidth()
        .focusRequester(focusRequester), // Fokussteuerung
      colors = OutlinedTextFieldDefaults.colors(
        focusedContainerColor = backgroundColor,
        unfocusedContainerColor = backgroundColor,
        disabledContainerColor = backgroundColor,
        unfocusedBorderColor = backgroundColor,
        focusedBorderColor = backgroundColor,
      ),
      placeholder = {
        Text(
          text = placeholder,
          color = Text_tertiary,
          fontWeight = FontWeight.SemiBold,
          fontSize = 16.sp
        )
      },
      keyboardOptions = KeyboardOptions.Default.copy(
        imeAction = imeAction // IME-Aktion für die Tastatur
      ),
      keyboardActions = KeyboardActions(
        onNext = { nextFocusRequester?.requestFocus() }, // Zum nächsten Fokus wechseln
      )
    )
  }
}

@Preview(showBackground = true)
@Composable
fun CustomInputFieldPreview() {
// Zustände für die Eingabefelder
  val firstValue = remember { mutableStateOf("") }
  val secondValue = remember { mutableStateOf("") }
  val thirdValue = remember { mutableStateOf("") }
  // FocusRequester für jedes Eingabefeld
  val firstFocusRequester = remember { FocusRequester() }
  val secondFocusRequester = remember { FocusRequester() }
  val thirdFocusRequester = remember { FocusRequester() }

  Column(modifier = Modifier.background(Primary)) {
    // Erstes Eingabefeld
    CustomInputField(
      label = "Erstes Feld",
      placeholder = "Gib etwas ein",
      value = firstValue.value, // Bindung des Zustands
      onValueChange = { firstValue.value = it }, // Aktualisierung des Zustands
      focusRequester = firstFocusRequester,
      nextFocusRequester = secondFocusRequester, // Fokus wechselt zum zweiten Feld
      imeAction = ImeAction.Next // "Next"-Button auf der Tastatur
    )
    
    // Zweites Eingabefeld
    CustomInputField(
      label = "Zweites Feld",
      placeholder = "Gib mehr ein",
      value = secondValue.value, // Bindung des Zustands
      onValueChange = { secondValue.value = it }, // Aktualisierung des Zustands
      focusRequester = secondFocusRequester,
      nextFocusRequester = thirdFocusRequester, // Fokus wechselt zum dritten Feld
      imeAction = ImeAction.Next
    )

    // Drittes Eingabefeld
    CustomInputField(
      label = "Drittes Feld",
      placeholder = "Letzter Wert",
      value = thirdValue.value, // Bindung des Zustands
      onValueChange = { thirdValue.value = it }, // Aktualisierung des Zustands
      focusRequester = thirdFocusRequester,
      imeAction = ImeAction.Done // "Done"-Button auf der Tastatur
    )
  }
}
