package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Text_prime

data class ResponseItem(val name: String, val statusIconResId: Int)

// Composable für die Liste der Rückmeldungen
@Composable
fun ResponseList(responses: List<ResponseItem>, headerText: String) {
  Box(
      modifier =
          Modifier.wrapContentHeight()
              .fillMaxWidth()
              .clip(MaterialTheme.shapes.medium)
              .background(Background_secondary)) {
        Column(modifier = Modifier.padding(8.dp)) {
          val nonOpenCount = responses.count { it.statusIconResId > 0 }
          Row(
              modifier = Modifier.fillMaxWidth().padding(start = 8.dp),
              verticalAlignment = Alignment.CenterVertically,
              horizontalArrangement = Arrangement.SpaceBetween) {
                Text(
                    text = headerText,
                    color = Text_prime,
                    style = MaterialTheme.typography.titleMedium)
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "$nonOpenCount / ${responses.size}")
                  Spacer(modifier = Modifier.width(8.dp))
                  Icon(
                      painter = painterResource(id = R.drawable.ic_groups),
                      // TODO  tint = Text_light,
                      contentDescription = null,
                      modifier = Modifier.size(24.dp))
                }
              }

          Spacer(modifier = Modifier.height(8.dp))

          LazyColumn(
              modifier = Modifier.fillMaxWidth().wrapContentHeight(),
              verticalArrangement = Arrangement.spacedBy(4.dp)) {
                items(responses) { item -> ResponseItemRow(item = item) }
              }
        }
      }
}

// Composable für eine einzelne Zeile in der Rückmeldungs-Liste
@Composable
fun ResponseItemRow(item: ResponseItem) {
  Row(
      modifier = Modifier.fillMaxWidth().padding(6.dp),
      verticalAlignment = Alignment.CenterVertically) {
        val initial = item.name.firstOrNull()?.toString() ?: ""
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(40.dp).clip(CircleShape).background(Color(0xFFBFEFB1))) {
              Text(
                  text = initial,
                  color = Text_prime,
                  fontSize = 18.sp,
                  style = MaterialTheme.typography.bodyLarge,
                  fontWeight = FontWeight.Bold)
            }

        Spacer(modifier = Modifier.width(5.dp))

        Text(
            text = item.name,
            color = Text_prime,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.bodyLarge,
            fontWeight = FontWeight.Medium)

        val (iconPainter: Painter, iconColor: Color) =
            when (item.statusIconResId) {
              0 -> painterResource(id = R.drawable.ic_open) to Color(0xFF1A1C15)
              1 -> painterResource(id = R.drawable.ic_check_circle) to Color(0xFF2EA100)
              else -> painterResource(id = R.drawable.ic_cancel) to Color(0xFFFF5449)
            }

        Icon(
            painter = iconPainter,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = iconColor)
      }
}

@Preview(showBackground = true)
@Composable
fun ResponseListPreview() {
  MaterialTheme {
    Surface {
      val responses =
          listOf(
              ResponseItem("Max Muster", 1),
              ResponseItem("Dieter Ausnahme", 0),
              ResponseItem("Fridolin Fröhlich", 2),
              ResponseItem("Peter Prüde", 1),
              ResponseItem("Susi Sommer", 2),
              ResponseItem("Thorsten Trauer", 1),
              ResponseItem("Wolfgang Wunder", 0))
      ResponseList(responses = responses, "Rückmeldungen")
    }
  }
}
