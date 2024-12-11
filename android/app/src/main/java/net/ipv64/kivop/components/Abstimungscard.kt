package net.ipv64.kivop.components

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
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
import net.ipv64.kivop.R
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun AbstimmungCard(title: String, eventType: String, date: LocalDate) {

  val formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

  // Kartenlayout
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .padding(16.dp)
              .clip(RoundedCornerShape(8.dp))
              .background(Color(0xFFBFEFB1))
              .padding(16.dp)) {
        Column {
          Text(
              text = title,
              style = MaterialTheme.typography.titleLarge,
              fontWeight = FontWeight.Bold)
          Spacer(modifier = Modifier.height(8.dp))
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(painter = painterResource(id = R.drawable.ic_calendar), contentDescription = null)
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = date.format(formatter),
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold)
          }
          Spacer(modifier = Modifier.height(8.dp))
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(painter = painterResource(id = R.drawable.ic_groups), contentDescription = null)
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = eventType,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Bold)
          }
        }
      }
}

@RequiresApi(Build.VERSION_CODES.O)
@Preview(showBackground = true)
@Composable
fun AbstimmungCardPreview() {
  MaterialTheme {
    Surface {
      Column {
        // Beispiel für ein Datum
        val eventDate = LocalDate.of(2024, 10, 24) // 24.10.2024

        AbstimmungCard(
            title = "Vorstandswahl", eventType = "Jahreshauptversammlung", date = eventDate)
      }
    }
  }
}
