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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.kivopandriod.moduls.Location
import com.example.kivopandriod.moduls.SitzungsCardData
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_secondary_light
import net.ipv64.kivop.ui.theme.Text_light

@Composable
fun SitzungsCard(sitzungCardData: SitzungsCardData) {
  val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

  // Kartenlayout
  Box(
      modifier =
          Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(Color(0xFFBFEFB1))) {
        Column(modifier = Modifier.padding(12.dp).background(Color.Transparent)) {
          Text(
              text = sitzungCardData.meetingTitle,
              color = Text_light,
              style = MaterialTheme.typography.titleLarge,
              fontWeight = FontWeight.Bold)
          Spacer(modifier = Modifier.height(8.dp))
          Row {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                  tint = Text_light,
                  painter = painterResource(id = R.drawable.ic_calendar),
                  contentDescription = "Icon Kalender")
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                  text = "${sitzungCardData.date?.format(dateFormatter)}",
                  color = Text_light,
                  style = MaterialTheme.typography.bodyMedium,
                  fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.width(4.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                  painter = painterResource(id = R.drawable.ic_clock),
                  tint = Text_light,
                  contentDescription = "Icon Uhrzeit")
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                  text =
                      "${sitzungCardData.time?.format(timeFormatter)} Uhr (${sitzungCardData.duration} Min.)",
                  color = Text_light,
                  style = MaterialTheme.typography.bodyMedium,
                  fontWeight = FontWeight.Bold)
            }
          }
          Spacer(modifier = Modifier.height(8.dp))
          Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            // Icon für Standort
            Icon(
                painter = painterResource(id = R.drawable.ic_place),
                tint = Text_light,
                contentDescription = "Icon Standort",
                modifier = Modifier.padding(end = 8.dp) // Abstand zwischen Icon und Text
                )
            // Text-Darstellung
            Column {
              // Name der Location
              Text(
                  text =
                      "${sitzungCardData.location?.name}${if (!sitzungCardData.location?.street.isNullOrBlank()) "," else ""}",
                  color = Text_light,
                  style = MaterialTheme.typography.bodyMedium,
                  fontWeight = FontWeight.Bold)
              // Adresse der Location
              if (!sitzungCardData.location?.street.isNullOrBlank())
                  Text(
                      text =
                          buildString {
                            // Füge die Straße hinzu
                            append(sitzungCardData.location?.street ?: "")

                            // Füge "Str." und die Nummer hinzu, falls die Nummer nicht null ist
                            if (!sitzungCardData.location?.number.isNullOrBlank()) {
                              Log.d(
                                  "Test-zu",
                                  "AttendancesCoordinationPage:${sitzungCardData.location?.street!!?.length} <--")
                              append(" Str. ${sitzungCardData.location?.number}")
                            }

                            // Füge ein Komma hinzu, falls postalCode oder place nicht null sind
                            if (!sitzungCardData.location?.postalCode.isNullOrBlank() ||
                                !sitzungCardData.location?.place.isNullOrBlank()) {
                              append(", ")
                            }

                            // Füge postalCode und place hinzu
                            append(sitzungCardData.location?.postalCode ?: "")
                            append(" ${sitzungCardData.location?.place ?: ""}")
                          },
                      color = Text_light,
                      style = MaterialTheme.typography.bodyMedium,
                      fontWeight = FontWeight.Bold)
            }
          }

          Spacer(modifier = Modifier.height(8.dp))
          ProfilCardKlein()
          Spacer(modifier = Modifier.height(4.dp))
        }
      }
}

@Composable
fun ProfilCardKlein() {
  val name = "T"
  Row() {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(40.dp).clip(CircleShape).background(Background_secondary_light)) {
          // Buchstabe in Box (round)
          Text(
              text = name,
              color = Text_light,
              fontSize = 18.sp,
              style = MaterialTheme.typography.bodyLarge,
              fontWeight = FontWeight.Bold)
        }
    Spacer(modifier = Modifier.width(4.dp))
    Column(modifier = Modifier.align(Alignment.CenterVertically)) {
      Text(
          text = "Thorsten Teebeutel",
          color = Text_light,
          // fontSize = 18.sp,
          style = MaterialTheme.typography.bodyMedium,
          fontWeight = FontWeight.Bold)
      Text(
          text = "Sitzungsleiter", // ToDo - Rolle anpassen
          color = Text_light,
          fontSize = 12.sp,
      )
    }
  }
}

@Preview(showBackground = true)
@Composable
fun SitzungsCardPreview() {
  val location =
      Location(
          letter = "A",
          street = "keineanung",
          name = "Gemeindesaal",
          locationId = "sd",
          number = "",
          place = "Kam",
          postalCode = "2425")
  val test =
      SitzungsCardData(
          meetingTitle = "Jahreshauptversammlung",
          date = LocalDate.now(),
          time = LocalTime.now(),
          meetingId = "123",
          duration = 90,
          location = location)
  SitzungsCard(sitzungCardData = test)
}
