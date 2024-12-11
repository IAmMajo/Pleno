package com.example.kivopandriod.components

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.R
import com.example.kivopandriod.ui.theme.Background_light
import com.example.kivopandriod.ui.theme.Primary_dark
import com.example.kivopandriod.ui.theme.Primary_dark_20
import com.example.kivopandriod.ui.theme.Text_light


@Composable
fun CallToConfirmation(
  onDismissRequest: () -> Unit,
  onConfirmation: () -> Unit,
  dialogTitle: String,
  dialogText: String,
  buttonOneText: String,
  buttonTextColorConfirm: Color, // (+rename)
  buttonTwoText: String?,
  buttonOneColor: Color,
  buttonTwoColor: Color?,
  buttonColorDismiss: Color,
  buttonTextDismiss: String,
  buttonTextColorDismiss: Color,


  // iconIdTop: Int,
){
  //val buttonOneColor = Color.Cyan


  AlertDialog(
    onDismissRequest = onDismissRequest ,
    confirmButton = {
      // Button-One
      Button(
        onClick = onConfirmation,
        // modifier: Modifier = Modifier,
        enabled = true,
        shape = ButtonDefaults.textShape,
        colors = ButtonDefaults.buttonColors(buttonOneColor),
        elevation = null,
        border =  null,
        contentPadding = PaddingValues(horizontal = 15.dp, vertical = 8.dp), //ToDo - PaddingValues - anpassen?
        //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
        // content: @Composable() (RowScope.() -> Unit)
      ){
        Text( text = buttonOneText,
          color = buttonTextColorConfirm )
      }
      // Button-Two
//            if (buttonTwoText != null) {
//                Button(
//                    onClick = onConfirmation,
//                    // modifier: Modifier = Modifier,
//                    enabled = true,
//                    shape = RoundedCornerShape(8.dp),
//                    colors = ButtonDefaults.buttonColors(if (buttonTwoColor != null) buttonTwoColor else {Color.Transparent}),
//                    elevation = null,
//                    border = null,
//                    contentPadding = PaddingValues(horizontal = 15.dp, vertical = 8.dp), //ToDo - PaddingValues - anpassen
//                    //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
//                    // content: @Composable() (RowScope.() -> Unit)
//                ) {
//                    Text(text = buttonTwoText)
//                }
//            }
    },
    // Dismiss-Button, TODO - fix placing
    dismissButton = {
      Button(
        onClick = onDismissRequest,
        // modifier: Modifier = Modifier,
        enabled = true,
        shape = ButtonDefaults.textShape,
        colors = ButtonDefaults.buttonColors(buttonColorDismiss),
        elevation = null,
        border =  null,
        contentPadding = ButtonDefaults.TextButtonContentPadding, //ToDo - PaddingValues - anpassen?
        //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
        //content: @Composable() (RowScope.() -> Unit)
      ){
//                if () {
//                    Icon(
//                        tint = Text_light,
//                        painter = painterResource(id = R.drawable.ic_cancel),
//                        contentDescription = "Icon Cancel"
//                    )
//                }
        Text(
          text = buttonTextDismiss,
          color = buttonTextColorDismiss)
      }
    },
//        icon = {
//            // if-statement ergänzen? / doch rausnehmen?
//            Icon(
//                painterResource(id = iconIdTop),
//                contentDescription = ""
//            )
//        },
    title = {
      Text( text = dialogTitle)
    },
    text = {
      Text( text = dialogText)
    },
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
fun Screen(){
  CallToConfirmation(
    onDismissRequest = close,
    onConfirmation = openCam,
    dialogTitle = "TestTitel",
    dialogText = "Test Text/ Beschreibung",
    buttonOneText = "Bestätigen",
    buttonTextColorConfirm = Background_light,
    buttonTwoText = "Two Button",
    buttonOneColor = Primary_dark,
    buttonTwoColor = Primary_dark,
    buttonColorDismiss = Primary_dark_20,
    buttonTextDismiss = "Abbrechen",
    buttonTextColorDismiss = Text_light,
    // iconIdTop =  R.drawable.ic_open
  )
}

val close: () -> Unit = { }
val openCam: () -> Unit = {  }