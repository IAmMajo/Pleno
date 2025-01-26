package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.secondaryButtonStyle
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary
import net.ipv64.kivop.ui.theme.textContentStyle
import net.ipv64.kivop.ui.theme.textHeadingStyle
import net.ipv64.kivop.ui.theme.textSubHeadingStyle

@Composable
fun PopupStandort(
    onDismissRequest: () -> Unit,
    title: String,
    descriptionText: String,
) {
  var userInput by remember { mutableStateOf("") }
  Dialog(
      onDismissRequest = onDismissRequest,
  ) {
    Column(
        modifier =
            Modifier.wrapContentSize()
                .clip(RoundedCornerShape(8.dp))
                .background(Background_secondary)
                .padding(horizontal = 25.dp, vertical = 20.dp),
    ) {
      // Titel
      Text(
          text = title,
          fontStyle = textSubHeadingStyle.fontStyle,
          fontWeight = textSubHeadingStyle.fontWeight,
          fontSize = textSubHeadingStyle.fontSize,
          fontFamily = textHeadingStyle.fontFamily,
          color = Text_prime,
      )
      SpacerBetweenElements(12.dp)
      // Beschreibung
      Text(
          text = descriptionText,
          fontStyle = textContentStyle.fontStyle,
          fontWeight = textContentStyle.fontWeight,
          fontSize = textContentStyle.fontSize,
          fontFamily = textContentStyle.fontFamily,
          color = Text_tertiary,
      )
      SpacerBetweenElements(12.dp)
      // InputFeld für die Adresse
      TextField(
          value = userInput,
          onValueChange = { newInput -> userInput = newInput },
          placeholder = { Text("Ort, Plz.") },
          colors =
              TextFieldDefaults.colors(
                  unfocusedTextColor = Text_tertiary,
                  // focusedTextColor = Text_tertiary,
                  unfocusedContainerColor = Background_prime,
                  // focusedContainerColor = Background_prime,
              ),
      )
      SpacerBetweenElements(12.dp)
      TextField(
          value = userInput,
          onValueChange = { newInput -> userInput = newInput },
          placeholder = { Text("Straßenname, Hausnummer") },
          colors =
              TextFieldDefaults.colors(
                  unfocusedTextColor = Text_tertiary,
                  // focusedTextColor = Text_tertiary,
                  unfocusedContainerColor = Background_prime,
                  // focusedContainerColor = Background_prime,
              ),
      )
      SpacerBetweenElements(12.dp)
      Row(
          modifier = Modifier.fillMaxWidth(),
          verticalAlignment = Alignment.CenterVertically,
          horizontalArrangement = Arrangement.End) {
            // Dismiss-Button
            CustomPopupButton(
                onClick = onDismissRequest,
                text = "Abbrechen",
                buttonStyle = secondaryButtonStyle,
                modifier = Modifier,
            )
            SpacerBetweenElements(8.dp)
            // Confirm-Button
            CustomPopupButton(
                onClick = {
                  // ToDo - hier muss die Addresse einmal geprüft werden
                },
                text = "Bestätigen",
                buttonStyle = primaryButtonStyle,
                modifier = Modifier,
            )
          }
    }
  }
}

@Preview
@Composable
fun ScreenPrev() {
  PopupStandort(
      onDismissRequest = {},
      title = "Popup Titel",
      descriptionText = "Das ist Text, das ist auch Text. usw usw usw usw ... Text",
  )
}
