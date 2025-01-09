package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetAttendanceDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun LoggedUserAttendacneCard(
  user: GetAttendanceDTO,
  meetingStatus: MeetingStatus? = null,
  imgBase64: String? = null,
  checkInClick: () -> Unit = {},
  acceptClick: () -> Unit = {},
  declineClick: () -> Unit = {}
) {
  Column(
    modifier = Modifier.fillMaxWidth().customShadow().background(Background_secondary,shape = RoundedCornerShape(8.dp)).padding(12.dp)
  ) {
    Row(
      verticalAlignment = Alignment.CenterVertically
    ) {
      Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
          .size(40.dp)
          .clip(CircleShape)
          .background(Color(0xFF1061DA))
      ) {
        Text(
          text = user.identity.name.first().toString(),
          color = Background_prime,
          fontSize = 18.sp,
          style = MaterialTheme.typography.bodyLarge,
          fontWeight = FontWeight.Bold
        )
      }
      Spacer(modifier = Modifier.width(5.dp))
    
      Text(
        text = user.identity.name,
        color = Text_prime,
        modifier = Modifier.weight(1f),
        style = MaterialTheme.typography.bodyLarge,
        fontWeight = FontWeight.Medium
      )
      Spacer(modifier = Modifier.weight(1f))
      if (user.status != null){
        Label(

        ) {Text(text = user.status.toString(),color = Text_prime_light)}
      }else{
        Label(

        ) {Text(text = "Ausstehend",color = Text_prime_light)} 
      }
    }
    SpacerBetweenElements()
    if (meetingStatus == MeetingStatus.scheduled) {
      if (user.status == AttendanceStatus.present) {
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors = ButtonDefaults.buttonColors(
            containerColor = Tertiary,
            contentColor = Text_prime_light
          ),
          onClick = {declineClick()})
        {
          Text(text = "Sitzung absagen")
        }
      } else if (user.status == AttendanceStatus.absent) {
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors = ButtonDefaults.buttonColors(
            containerColor = Tertiary,
            contentColor = Text_prime_light
          ),
          onClick = {acceptClick()})
        {
          Text(text = "Sitzung zusagen")
        }
      } else if (user.status == AttendanceStatus.accepted) {
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors = ButtonDefaults.buttonColors(
            containerColor = Tertiary,
            contentColor = Text_prime_light
          ),
          onClick = {declineClick()})
        {
          Text(text = "Sitzung absagen")
        }
      } else {
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors = ButtonDefaults.buttonColors(
            containerColor = Tertiary,
            contentColor = Text_prime_light
          ),
          onClick = {acceptClick()})
        {
          Text(text = "Sitzung zusagen")
        }
        SpacerBetweenElements(4.dp)
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors = ButtonDefaults.buttonColors(
            containerColor = Secondary,
            contentColor = Text_prime
          ),
          onClick = {declineClick()})
        {
          Text(text = "Sitzung zusagen")
        }
      }
    }else if (meetingStatus == MeetingStatus.inSession){
      Button(
        modifier = Modifier.fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(
          containerColor = Secondary,
          contentColor = Text_prime
        ),
        onClick = {checkInClick()})
      {
        Text(text = "Check In")
      }
    }
  }
}

