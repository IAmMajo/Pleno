package com.example.kivopandriod.components


import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentSize 
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier 
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.components.CustomPopupButton
import net.ipv64.kivop.models.alertButtonStyle
import net.ipv64.kivop.models.alertSecondaryButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.secondaryButtonStyle
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary
import net.ipv64.kivop.ui.theme.textContentStyle
import net.ipv64.kivop.ui.theme.textHeadingStyle

@Composable
fun CallToConfirmation(
    onDismissRequest: () -> Unit,
    onConfirmation: () -> Unit,
    dialogTitle: String,
    dialogText: String,
    buttonOneText: String,
    buttonTextDismiss: String,
    alert: Boolean,
) {
  var buttonOneStyle = if(!alert)primaryButtonStyle else alertButtonStyle
  var buttonTwoStyle = if(!alert) secondaryButtonStyle else alertSecondaryButtonStyle
  AlertDialog(
    containerColor = Background_prime,
    shape = RoundedCornerShape(8.dp),
    // properties = androidx.compose.ui.window.DialogProperties(),
    modifier = Modifier
      .wrapContentSize()
      .padding(horizontal = 25.dp, vertical = 20.dp),
    onDismissRequest = onDismissRequest,
    confirmButton = {
      // Button-One 
      CustomPopupButton(
        text = buttonOneText,
        buttonStyle = buttonOneStyle,
        onClick = onConfirmation,
        modifier = Modifier
      )
    },
    // Dismiss-Button, TODO - fix placing
    dismissButton = {
      CustomPopupButton(
        text = buttonTextDismiss,
        buttonStyle = buttonTwoStyle,
        onClick = onDismissRequest,
        modifier = Modifier
      )
    },
    title = {
      Text(
        text = dialogTitle,
        fontFamily = textHeadingStyle.fontFamily,
        fontWeight = textHeadingStyle.fontWeight,
        fontSize = textHeadingStyle.fontSize,
        color = Text_prime,
      )
    },
    text = {
      Text(
        text = dialogText,
        fontFamily = textContentStyle.fontFamily,
        fontWeight = textContentStyle.fontWeight,
        fontSize = textContentStyle.fontSize,
        color = Text_tertiary,
      )
    },

    )
}

@Preview
@Composable
fun Screen() {
  CallToConfirmation(
      onDismissRequest = {},
      onConfirmation = {},
      dialogTitle = "TestTitel",
      dialogText = "Sind Sie sicher, dass Sie Ihr Ergebnis abschicken möchten?",
      buttonOneText = "confirm",
      buttonTextDismiss = "back",
      alert = true
      )
}

