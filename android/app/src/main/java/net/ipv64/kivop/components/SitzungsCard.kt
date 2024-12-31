package net.ipv64.kivop.components

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import java.time.LocalDateTime
import java.util.UUID
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetLocationDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun SitzungsCard(GetMeetingDTO: GetMeetingDTO, backgroundColor: Color = Color.Transparent) {
  val dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm")

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .clip(RoundedCornerShape(16.dp))
              .background(backgroundColor)
              .padding(16.dp)) {
        Column {
          Text(
              text = GetMeetingDTO.name,
              color = Color.White,
              style = MaterialTheme.typography.headlineMedium,
              fontWeight = FontWeight.Bold)
          Spacer(modifier = Modifier.height(12.dp))
          Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = "Datum",
                tint = Text_prime_light)
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text =
                    "${GetMeetingDTO.start.format(dateFormatter)} | ${GetMeetingDTO.start.format(timeFormatter)} Uhr",
                color = Text_prime_light,
                style = MaterialTheme.typography.bodyLarge)
            Spacer(modifier = Modifier.width(16.dp))
            Icon(
                painter = painterResource(id = R.drawable.ic_clock),
                contentDescription = "Dauer",
                tint = Text_prime_light)
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "${GetMeetingDTO.duration} Min",
                color = Text_prime_light,
                style = MaterialTheme.typography.bodyLarge)
          }
          Spacer(modifier = Modifier.height(8.dp))
          Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            // Icon für Standort
            Icon(
                painter = painterResource(id = R.drawable.ic_place),
                tint = Background_secondary,
                contentDescription = "Icon Standort",
                modifier = Modifier.padding(end = 8.dp) // Abstand zwischen Icon und Text
                )
            // Text-Darstellung

            // Name der Location
            Text(
                text =
                    "${GetMeetingDTO.location?.name}${if (!GetMeetingDTO.location?.street.isNullOrBlank()) ", " else ""}",
                color = Text_prime_light,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold)
            // Adresse der Location
            if (!GetMeetingDTO.location?.street.isNullOrBlank())
                Text(
                    text =
                        buildString {
                          // Füge die Straße hinzu
                          append(GetMeetingDTO.location?.street ?: "")

                          // Füge "Str." und die Nummer hinzu, falls die Nummer nicht null ist
                          if (!GetMeetingDTO.location?.number.isNullOrBlank()) {
                            Log.d(
                                "Test-zu",
                                "AttendancesCoordinationPage:${GetMeetingDTO.location?.street!!?.length} <--")
                            append(" Str. ${GetMeetingDTO.location?.number}")
                          }

                          // Füge ein Komma hinzu, falls postalCode oder place nicht null sind
                          if (!GetMeetingDTO.location?.postalCode.isNullOrBlank() ||
                              !GetMeetingDTO.location?.place.isNullOrBlank()) {
                            append(", ")
                          }

                          // Füge postalCode und place hinzu
                          append(GetMeetingDTO.location?.postalCode ?: "")
                          append(" ${GetMeetingDTO.location?.place ?: ""}")
                        },
                    color = Text_prime_light,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold)
          }

          Spacer(modifier = Modifier.height(16.dp))
          if (GetMeetingDTO.chair != null) {
            ProfileCardSmall(
                name = GetMeetingDTO.chair?.name ?: "C",
                role = "Sitzungsleiter",
                profilePicture = null,
                backgroundColor = Background_secondary.copy(0.15f),
                texColor = Text_prime_light,
                onClick = {})
          }
        }
      }
}

@Composable
fun InToSitzungCard(
    GetMeetingDTO: GetMeetingDTO,
    backgroundColor: Color = Secondary,
    onClick: () -> Unit
) {
  val dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm")
  val meetingId = GetMeetingDTO.id.toString()
  val responses = remember { mutableStateOf<List<AttendanceStatus?>>(emptyList()) }

  LaunchedEffect(meetingId) {
    val responseData = getAttendances(meetingId) // Dynamische Daten abrufen
    responses.value = responseData.map { response -> response.status }
  }

  val count = responses.value.count { it == AttendanceStatus.present }

  Log.e("Test-id", "${GetMeetingDTO.id}")
  // Beobachtbarer Zustand wird aktualisiert

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .clip(RoundedCornerShape(16.dp))
              .background(backgroundColor)
              .padding(16.dp)) {
        Column {
          Text(
              text = GetMeetingDTO.name,
              color = Text_prime,
              style = MaterialTheme.typography.headlineMedium,
          )
          Spacer(modifier = Modifier.height(12.dp))
          Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = "Datum",
                tint = Text_prime)
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "${GetMeetingDTO.start.format(dateFormatter)}",
                color = Text_prime,
                style = MaterialTheme.typography.bodyLarge,
            )
            Spacer(modifier = Modifier.width(16.dp))
          }
          Spacer(modifier = Modifier.height(4.dp))
          Row(
              modifier = Modifier.fillMaxWidth(),
              verticalAlignment = Alignment.CenterVertically,
          ) {
            Icon(
                painter = painterResource(id = R.drawable.ic_clock),
                contentDescription = "Dauer",
                tint = Text_secondary)
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "${GetMeetingDTO.start.format(timeFormatter)} Uhr",
                color = Text_secondary,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold)

            Spacer(modifier = Modifier.weight(1f))
            Icon(
                painter = painterResource(id = R.drawable.ic_groups),
                contentDescription = "Dauer",
                tint = Text_secondary,
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "${count}",
                color = Text_secondary,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold)
          }

          Spacer(modifier = Modifier.height(12.dp))

          CustomButton(
              text = "Zur aktuellen Sitzung",
              color = Primary,
              fontColor = Text_prime_light,
              modifier = Modifier.clip(shape = RoundedCornerShape(50.dp)),
              onClick = onClick)
        }
      }
}

@Preview(showBackground = true)
@Composable
fun SitzungsCardPreview() {
  val location =
      GetLocationDTO(
          letter = "A",
          street = "keineanung",
          name = "Gemeindesaal",
          id = UUID.fromString("123e4567-e89b-12d3-a456-426614174000"),
          number = "4",
          place = "Kam",
          postalCode = "2425")
  val test =
      GetMeetingDTO(
          name = "Jahreshauptversammlung",
          start = LocalDateTime.of(2023, 12, 31, 10, 0),
          id = UUID.fromString("123e4567-e89b-12d3-a456-426614174000"),
          duration = 90.toUShort(),
          location = location,
          description = "",
          status = MeetingStatus.completed,
          chair =
              GetIdentityDTO(
                  UUID.fromString("123e4567-e89b-12d3-a456-426614174000"), "Thorsten Teebeutel"),
          code = "23",
          myAttendanceStatus = AttendanceStatus.present)
  InToSitzungCard(GetMeetingDTO = test, onClick = {})
}
