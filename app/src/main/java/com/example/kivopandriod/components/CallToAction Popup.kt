package com.example.kivopandriod.components

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonColors
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.tooling.preview.PreviewParameter
import com.example.kivopandriod.R
import com.example.kivopandriod.Screen
import com.example.kivopandriod.ui.theme.Text_light


@Composable
fun CallToAction(
    onDismissRequest: () -> Unit,
    onConfirmation: () -> Unit,
    dialogTitle: String,
    dialogText: String,
    buttonOneText: String,
//    buttonTwoText: String,
    buttonOneColor: Color,
//    buttonTwoColor: Color

    iconIdTop: Int,
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
                contentPadding = ButtonDefaults.TextButtonContentPadding, //ToDo - PaddingValues - anpassen?
                //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
                // content: @Composable() (RowScope.() -> Unit)
            ){
                Text( text = buttonOneText)
            }
            // Button-Two
//            Button(
//                onClick = onConfirmation,
//                // modifier: Modifier = Modifier,
//                enabled = true,
//                shape = ButtonDefaults.textShape,
//                colors = ButtonDefaults.buttonColors(buttonTwoColor),
//                elevation = null,
//                border =  null,
//                contentPadding = ButtonDefaults.TextButtonContentPadding, //ToDo - PaddingValues - anpassen?
//                //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
//                // content: @Composable() (RowScope.() -> Unit)
//            ){
//                Text( text = buttonTwoText)
//            }
        },
        // Button-One
        dismissButton = {
            Button(
                onClick = onDismissRequest,
                // modifier: Modifier = Modifier,
                enabled = true,
                shape = ButtonDefaults.textShape,
                colors = ButtonDefaults.buttonColors(buttonOneColor),
                elevation = null,
                border =  null,
                contentPadding = ButtonDefaults.TextButtonContentPadding, //ToDo - PaddingValues - anpassen?
                //interactionSource = remember { MutableInteractionSource() }, //MutableInteractionSource
                //content: @Composable() (RowScope.() -> Unit)
            ){
                Icon(
                    tint = Text_light,
                    painter = painterResource(id = R.drawable.ic_cancel),
                    contentDescription = "Icon Cancel"
                )
            }
        },
        icon = {
            Icon(
                painterResource(id = iconIdTop),
                contentDescription = ""
            )
        },
        title = {
            Text( text = dialogTitle)
        },
        text = {
            Text( text = dialogText)
        },
        modifier = Modifier, // TODO
    )
    //public fun AlertDialog(
    //
    //    icon: @Composable() (() -> Unit)? = null,
    //
    //    shape: Shape = AlertDialogDefaults.shape,
    //    containerColor: Color = AlertDialogDefaults.containerColor,
    //    iconContentColor: Color = AlertDialogDefaults.iconContentColor,
    //    titleContentColor: Color = AlertDialogDefaults.titleContentColor,
    //    textContentColor: Color = AlertDialogDefaults.textContentColor,
    //    tonalElevation: Dp = AlertDialogDefaults.TonalElevation,
    //    properties: DialogProperties = DialogProperties()
    //): Unit
}

@Preview
@Composable
fun Screen(){
    CallToAction(
        onDismissRequest = close,
        onConfirmation = openCam,
        dialogTitle = "TestTitel",
        dialogText = "Test Text/ Beschreibung",
        buttonOneText = "One Button",
        buttonOneColor = Color.Cyan,
        iconIdTop =  R.drawable.ic_open
    )
}

val close: () -> Unit = { }
val openCam: () -> Unit = {  }