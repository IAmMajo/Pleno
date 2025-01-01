package com.example.kivopandriod.components

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun CallToConfirmation(
    onDismissRequest: () -> Unit,
    onConfirmation: () -> Unit,
    dialogTitle: String,
    dialogText: String,
    buttonOneText: String,
    buttonTwoText: String?,
    buttonTextDismiss: String,
    //  alert: Boolean,

) {
  AlertDialog(
      onDismissRequest = onDismissRequest,
      confirmButton = {
        // Button-One
        Button(
            onClick = onConfirmation,
            modifier = Modifier.height(35.dp),
            enabled = true,
            shape = ButtonDefaults.textShape,
            colors = ButtonDefaults.buttonColors(Tertiary),
            elevation = null,
            border = null,
            contentPadding =
                PaddingValues(
                    horizontal = 8.dp, vertical = 0.dp), // ToDo - PaddingValues - anpassen?
            // interactionSource = remember { MutableInteractionSource() },
            // //MutableInteractionSource
            // content: @Composable() (RowScope.() -> Unit)
        ) {
          Text(
              text = buttonOneText, color = Background_prime, modifier = Modifier.padding(horizontal = 12.dp))
        }
      },
      // Dismiss-Button, TODO - fix placing
      dismissButton = {
        Button(
            onClick = onDismissRequest,
            modifier = Modifier.height(35.dp),
            enabled = true,
            shape = ButtonDefaults.textShape,
            colors = ButtonDefaults.buttonColors(Secondary),
            elevation = null,
            border = null,
            contentPadding =
                ButtonDefaults.TextButtonContentPadding, // ToDo - PaddingValues - anpassen?
            // interactionSource = remember { MutableInteractionSource() },
            // //MutableInteractionSource
            // content: @Composable() (RowScope.() -> Unit)
        ) {
          //
          Text(
              text = buttonTextDismiss,
              color = Text_tertiary,
              modifier = Modifier.padding(horizontal = 12.dp))
        }
      },
      title = { Text(text = dialogTitle) },
      text = { Text(text = dialogText) },
      modifier = Modifier, // TODO
      //    shape: Shape = AlertDialogDefaults.shape,
      //    containerColor: Color = AlertDialogDefaults.containerColor,
      //    iconContentColor: Color = AlertDialogDefaults.iconContentColor,
      //    titleContentColor: Color = AlertDialogDefaults.titleContentColor,
      //    textContentColor: Color = AlertDialogDefaults.textContentColor,
      //    tonalElevation: Dp = AlertDialogDefaults.TonalElevation,
      //    properties: DialogProperties = DialogProperties()
  )
}

@Preview
@Composable
fun Screen() {
  CallToConfirmation(
      onDismissRequest = close,
      onConfirmation = openCam,
      dialogTitle = "TestTitel",
      dialogText = "Sind Sie sicher, dass Sie Ihr Ergebnis abschicken möchten?",
      buttonOneText = "Bestätigen",
      buttonTwoText = "Two Button",
      buttonTextDismiss = "Abbrechen"
      //  alert = false
      )
}

val close: () -> Unit = {}
val openCam: () -> Unit = {}
