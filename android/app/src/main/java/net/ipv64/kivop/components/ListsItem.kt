package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
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
import androidx.compose.ui.unit.sp
import java.time.format.DateTimeFormatter
import net.ipv64.kivop.R
import net.ipv64.kivop.moduls.ItemListData
import net.ipv64.kivop.ui.theme.*

@Composable
fun ListenItem(
    itemListData: ItemListData,
    onClick: () -> Unit = {},
    backgroundColor: Color = Background_secondary_light
) {
  val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
  var iconPainter: Painter = painterResource(id = R.drawable.ic_groups)
  var iconColor: Color = Text_light
  var backgroundColorT: Color = backgroundColor

  if (itemListData.membersCount == null && itemListData.iconRend == true) {
    val iconData =
        when (itemListData.attendanceStatus) {
          0 ->
              Triple(
                  painterResource(id = R.drawable.ic_event_open),
                  Text_light,
                  Background_secondary_light)
          1 ->
              Triple(painterResource(id = R.drawable.ic_event_check), Primary_dark, Primary_dark_20)
          else ->
              Triple(painterResource(id = R.drawable.ic_event_cancel), Error_dark, Error_dark_20)
        }

    iconPainter = iconData.first
    iconColor = iconData.second
    backgroundColorT = iconData.third
  }

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .clip(RoundedCornerShape(8.dp))
              .background(backgroundColorT)
              .padding(8.dp)
              .clickable(onClick = onClick)) {
        Column {
          // Titeltext
          Text(text = itemListData.title, fontWeight = FontWeight.Bold, fontSize = 14.sp)

          // Datum- und Zeitzeile
          Row(
              modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
              verticalAlignment = Alignment.CenterVertically,
              horizontalArrangement = Arrangement.SpaceBetween) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  // Kalender-Icon und Datum
                  Icon(
                      painter = painterResource(id = R.drawable.ic_calendar),
                      contentDescription = null,
                      modifier = Modifier.size(16.dp))
                  Spacer(modifier = Modifier.width(4.dp))
                  Text(
                      text = "${itemListData.date?.format(dateFormatter)}",
                      fontWeight = FontWeight.SemiBold,
                      fontSize = 12.sp)
                  Spacer(modifier = Modifier.width(8.dp))

                  // Uhr-Icon und Zeit
                  if (itemListData.timeRend == true) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_clock),
                        contentDescription = null,
                        modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${itemListData.time?.format(timeFormatter)} Uhr",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 12.sp)
                  }
                }

                if (itemListData.membersCount == null && itemListData.iconRend == true) {
                  Icon(
                      painter = iconPainter,
                      contentDescription = null,
                      tint = iconColor,
                      //    modifier = Modifier.size(30.dp)
                  )
                } else if (itemListData.iconRend == true) {
                  Row() {
                    Icon(
                        painter = iconPainter,
                        contentDescription = null,
                        tint = iconColor,
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        modifier = Modifier.padding(top = 4.dp),
                        text = "${itemListData.membersCount}",
                        fontWeight = FontWeight.Medium,
                        fontSize = 12.sp)
                  }
                }
              }
        }
      }
}
