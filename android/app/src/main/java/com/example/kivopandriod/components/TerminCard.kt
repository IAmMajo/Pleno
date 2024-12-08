package com.example.kivopandriod.components

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.R
import com.example.kivopandriod.ui.theme.*
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter

data class TermindData(
    val title: String,
    val date: LocalDate,
    val time: LocalTime,
    val status: Int,
    val id: String,
)

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun TermindCard(termindData: TermindData, onClick: () -> Unit = {}) {

  val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

  val colorH: Color =
      when (termindData.status) {
        0 -> Background_secondary_light
        1 -> Primary_dark_20
        else -> Error_dark_20
      }

  val (iconPainter: Painter, iconColor: Color) =
      when (termindData.status) {
        0 -> painterResource(id = R.drawable.ic_open) to Text_light
        1 -> painterResource(id = R.drawable.ic_check_circle) to Primary_dark
        else -> painterResource(id = R.drawable.ic_cancel) to Error_dark
      }

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .padding(12.dp)
              .clip(RoundedCornerShape(8.dp))
              .background(colorH)
              .padding(8.dp)
              .clickable(onClick = onClick)) {
        Column {
          // Titeltext
          Text(
              text = termindData.title,
              style = MaterialTheme.typography.titleMedium,
              fontWeight = FontWeight.Bold)

          // Datum- und Zeitzeile
          Row(
              modifier = Modifier.fillMaxWidth(),
              verticalAlignment = Alignment.CenterVertically,
              horizontalArrangement = Arrangement.SpaceBetween) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  // Kalender-Icon und Datum
                  Icon(
                      painter = painterResource(id = R.drawable.ic_calendar),
                      contentDescription = null,
                      modifier = Modifier.size(20.dp))
                  Spacer(modifier = Modifier.width(4.dp))
                  Text(
                      text = termindData.date.format(dateFormatter),
                      fontWeight = FontWeight.Bold,
                      style = MaterialTheme.typography.bodyMedium)
                  Spacer(modifier = Modifier.width(8.dp))

                  // Uhr-Icon und Zeit
                  Icon(
                      painter = painterResource(id = R.drawable.ic_clock),
                      contentDescription = null,
                      modifier = Modifier.size(20.dp))
                  Spacer(modifier = Modifier.width(8.dp))
                  Text(
                      text = "${termindData.time.format(timeFormatter)} Uhr",
                      fontWeight = FontWeight.Bold,
                      style = MaterialTheme.typography.bodyMedium)
                }

                // Rechts ausgerichtetes Icon
                Icon(
                    painter = iconPainter,
                    contentDescription = null,
                    tint = iconColor,
                    modifier = Modifier.size(30.dp))
              }
        }
      }
}

// @RequiresApi(Build.VERSION_CODES.O)
// @Preview(showBackground = true)
// @Composable
// fun TermindCardPreview() {
//    MaterialTheme {
//        Surface {
//            Column {
//                TermindCard(
//                    termindData = TermindData(
//                        title = "Vorstandswahl",
//                        date = LocalDate.now(),
//                        time = LocalTime.now(),
//                        status = 1
//                    )
//                )
//                TermindCard(
//                    termindData = TermindData(
//                        title = "Vorstandswahl",
//                        date = LocalDate.now(),
//                        time = LocalTime.now(),
//                        status = 2
//                    )
//                )
//                TermindCard(
//                    termindData = TermindData(
//                        title = "Vorstandswahl",
//                        date = LocalDate.now(),
//                        time = LocalTime.now(),
//                        status = 0
//                    )
//                )
//            }
//        }
//    }
// }
