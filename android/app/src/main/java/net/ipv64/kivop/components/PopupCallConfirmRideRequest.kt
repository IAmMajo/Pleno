package com.example.kivopandriod.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import net.ipv64.kivop.components.CustomPopupButton
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.neutralButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.secondaryButtonStyle
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun CallToConfirmRideRequest(
    onDismissRequest: () -> Unit,
    onConfirmation: () -> Unit,
    composable: @Composable () -> Unit,
    dialogTitle: String,
    dialogText: String,
    buttonOneText: String,
    buttonTextDismiss: String,
    enabled: Boolean = false
) {
  var buttonOneStyle = if (enabled) primaryButtonStyle else neutralButtonStyle
  var buttonTwoStyle = secondaryButtonStyle
  Dialog(
      onDismissRequest = { onDismissRequest() },
  ) {
    Box(
        modifier =
            Modifier.wrapContentSize()
                .padding(horizontal = 0.dp, vertical = 20.dp)
                .background(Background_prime, shape = RoundedCornerShape(8.dp))
                .padding(22.dp),
    ) {
      Column() {
        Text(
            text = dialogTitle,
            style = TextStyles.headingStyle,
            color = Text_prime,
        )
        SpacerBetweenElements(12.dp)
        Text(
            text = dialogText,
            style = TextStyles.contentStyle,
            color = Text_tertiary,
        )
        SpacerBetweenElements(12.dp)
        composable()
        SpacerBetweenElements(12.dp)
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
          CustomPopupButton(
              text = buttonTextDismiss,
              buttonStyle = buttonTwoStyle,
              onClick = onDismissRequest,
              modifier = Modifier,
          )
          SpacerBetweenElements(12.dp)
          CustomPopupButton(
              text = buttonOneText,
              buttonStyle = buttonOneStyle,
              onClick = onConfirmation,
              modifier = Modifier,
              enabled = enabled)
        }
      }
    }
  }
}

@Preview
@Composable
fun PreviewPopup() {
  Surface(modifier = Modifier.fillMaxWidth().fillMaxHeight()) {
    CallToConfirmRideRequest(
        onDismissRequest = {},
        onConfirmation = {},
        dialogTitle = "TestTitel",
        dialogText = "Sind Sie sicher, dass Sie Ihr Ergebnis abschicken möchten?",
        buttonOneText = "confirm",
        buttonTextDismiss = "back",
        composable = { Text("test") })
  }
}
