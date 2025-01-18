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

import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus

import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.secondaryButtonStyle
import net.ipv64.kivop.services.api.putAttend
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_neutral_20
import net.ipv64.kivop.ui.theme.Signal_red


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
   Text(title)
   Text(descriptionText)
   
   SpacerBetweenElements(16.dp)
   // ToDo - styling font
   if (!isCorrect) {
     Text(
       text = "Der Code ist falsch.",
       color = Signal_red
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
       )
       //lineLimits = 1,//TextFieldLineLimits.Default,
     )
   }
   SpacerBetweenElements(16.dp)
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
  // Button 1
  buttonDismissText = "dismiss",
  // Button 2
  buttonConfirmText = "confirm",
  // Button open-camera
  onOpenCamera = {},
  // Meeting Info
  meetingId = "213445",
  )
}