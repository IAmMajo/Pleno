package net.ipv64.kivop.components

import android.os.Build
import androidx.annotation.RequiresApi
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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Place
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_secondary_light
import net.ipv64.kivop.ui.theme.Text_light
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun SitzungsCard(title: String, date: LocalDate) {
  val formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

  // Kartenlayout
  Box(
      modifier =
          Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(Color(0xFFBFEFB1))) {
        Column(modifier = Modifier.padding(12.dp).background(Color.Transparent)) {
          Text(
              text = title,
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
                  text = date.format(formatter),
                  color = Text_light,
                  style = MaterialTheme.typography.bodyLarge,
                  fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.width(4.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                  painter = painterResource(id = R.drawable.ic_schedule_24px),
                  tint = Text_light,
                  contentDescription = "Icon Uhrzeit")
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                  text = "16:30 Uhr (90Min.)",
                  color = Text_light,
                  style = MaterialTheme.typography.bodyLarge,
                  fontWeight = FontWeight.Bold)
            }
          }
          Spacer(modifier = Modifier.height(8.dp))
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = Icons.Outlined.Place,
                tint = Text_light,
                contentDescription = "Icon Standort")
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = "Sitzungssaal 1",
                color = Text_light,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold)
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
              color = Color(0xff1a1c15),
              fontSize = 18.sp,
              style = MaterialTheme.typography.bodyLarge,
              fontWeight = FontWeight.Bold)
        }
    Spacer(modifier = Modifier.width(4.dp))
    Column(modifier = Modifier.align(Alignment.CenterVertically)) {
      Text(
          text = "Thorsten Teebeutel",
          color = Color(0xff1a1c15),
          fontSize = 18.sp,
          style = MaterialTheme.typography.bodyLarge,
          fontWeight = FontWeight.Bold)
      Text(
          text = "Sitzungsleiter", // ToDo - Rolle anpassen
          color = Color(0xff1a1c15),
          fontSize = 12.sp,
      )
    }
  }
}
