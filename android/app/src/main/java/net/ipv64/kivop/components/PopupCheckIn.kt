package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.materialIcon
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import net.ipv64.kivop.R

import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus

import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.secondaryButtonStyle
import net.ipv64.kivop.services.api.putAttend
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.CustomFontStyle
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_neutral_20
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary
import net.ipv64.kivop.ui.theme.textContentStyle
import net.ipv64.kivop.ui.theme.textHeadingStyle
import net.ipv64.kivop.ui.theme.textSubHeadingStyle


@Composable
fun PopupCheckIn (
    onDismissRequest: () -> Unit,
    onConfirmation: () -> Unit,
    title: String,
    descriptionText: String,
    // Button 1
    buttonDismissText: String,
    // Button 2
    buttonConfirmText: String,
    // Button open-camera
    onOpenCamera: () -> Unit,
    // Meeting Info
    meetingId: String,
){
  var code = "123456" //meetingViewModel.meeting.code?
  var userInput by remember { mutableStateOf("") }
  var isCorrect by remember { mutableStateOf(true) }
  
Dialog(
  onDismissRequest = onDismissRequest,
) {
 Column(
   modifier = Modifier
     .wrapContentSize()
     .clip(RoundedCornerShape(8.dp))
     .background(Background_prime)
     .padding(horizontal = 25.dp, vertical = 20.dp),
 ) {
   //ToDo - Styling von Titel & Beschreibung
   Text(
     text = title, 
     fontStyle = textSubHeadingStyle.fontStyle,
     fontWeight = textSubHeadingStyle.fontWeight,
     fontSize = textSubHeadingStyle.fontSize,
     fontFamily = textHeadingStyle.fontFamily,
     color = Text_prime,
     )
   SpacerBetweenElements(12.dp)
   Text(text = descriptionText,
     fontStyle = textContentStyle.fontStyle,
     fontWeight = textContentStyle.fontWeight,
     fontSize = textContentStyle.fontSize,
     fontFamily = textContentStyle.fontFamily,
     color = Text_tertiary,)
   SpacerBetweenElements(12.dp)
   // ToDo - styling font
   if (!isCorrect) {
     Text(
       text = "Der Code ist falsch.",
       color = Signal_red,
       fontSize = textContentStyle.fontSize,
     )
   }
   Row {
     TextField(
       value = userInput,
       onValueChange = { newInput -> userInput = newInput },
       placeholder = { Text("000000") } ,
       colors = TextFieldDefaults.colors(
         unfocusedTextColor = Signal_neutral,
         //focusedTextColor = Text_tertiary,
         unfocusedContainerColor = Signal_neutral_20,
         //focusedContainerColor = Signal_neutral_20,
       ),
       //lineLimits = //TextFieldLineLimits.Default,
     )
   }
   SpacerBetweenElements(12.dp)
   IconButton(
     onClick = onOpenCamera,
     colors = IconButtonDefaults.iconButtonColors(
       contentColor = Signal_neutral,
       containerColor = Signal_neutral_20,
     ),
     modifier = Modifier
       .align(Alignment.CenterHorizontally)
       .fillMaxWidth(),
   ) {
     Row {
       Icon(
         painter = painterResource(id = R.drawable.ic_qr_code_scanner_22dp),
         contentDescription = "QR-Code scannen",
         modifier = Modifier.size(22.dp)
       )
       SpacerBetweenElements(4.dp)
       Text(
         text = "QR-Code scannen",
         fontWeight = textContentStyle.fontWeight,
         fontSize = textContentStyle.fontSize,
         fontFamily = textContentStyle.fontFamily,
         )
       }
   }
   SpacerBetweenElements(12.dp)
   Row (
     modifier = Modifier
       .fillMaxWidth(),
     verticalAlignment = Alignment.CenterVertically,
     horizontalArrangement = Arrangement.End
   ) {

     //Dismiss-Button
     CustomPopupButton(
       onClick = onDismissRequest,
       text = buttonDismissText,
       buttonStyle = secondaryButtonStyle,
       modifier = Modifier,
     )

     SpacerBetweenElements(8.dp)
     
     // ToDo - onConfirmation: Code abgleichen & ggf putAttend aufrufen (später auslagern)
     //Confirm-Button
     CustomPopupButton(
       onClick = {
         // hier wird der User-Attendence status geupdatet
         if (code == userInput){
           //putAttend(meetingId = meetingId, code = userInput)
           onConfirmation()
           isCorrect = true
         }
         else { isCorrect = false }
       }, 
       text = buttonConfirmText,
       buttonStyle = primaryButtonStyle,
       modifier = Modifier,
     )
   }
  }
  }
}

@Preview
@Composable
fun Screen() {
  PopupCheckIn(
    onDismissRequest = {},
  onConfirmation = {},
  title =  "Popup Titel",
  descriptionText = "Das ist Text, das ist auch Text. usw usw usw usw ... Text",
  buttonDismissText = "dismiss",
  buttonConfirmText = "confirm",
  onOpenCamera = {},
  meetingId = "213445",
  )
}