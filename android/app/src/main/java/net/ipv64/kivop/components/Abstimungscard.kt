// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
import androidx.compose.ui.unit.sp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun AbstimmungCard(
    title: String,
    backgroundColor: Color = Primary,
    fontColor: Color = Background_prime,
    date: LocalDateTime? = null,
    eventType: String? = null
) {

  val formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy | HH:mm")

  // Kartenlayout
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .clip(RoundedCornerShape(8.dp))
              .background(backgroundColor)
              .padding(8.dp)) {
        Column {
          Text(
              text = title,
              style = MaterialTheme.typography.titleLarge,
              color = fontColor,
              fontWeight = FontWeight.Bold)
          Spacer(modifier = Modifier.height(8.dp))
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                modifier = Modifier.size(16.dp),
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = null,
                tint = fontColor)
            Spacer(modifier = Modifier.width(4.dp))
            if (date != null) {
              Text(
                  text = date.format(formatter),
                  fontSize = 14.sp,
                  style = MaterialTheme.typography.bodyLarge,
                  color = fontColor,
              )
            }
            Spacer(modifier = Modifier.width(16.dp))
            if (eventType != null) {
              Icon(
                  modifier = Modifier.size(16.dp),
                  painter = painterResource(id = R.drawable.ic_groups),
                  contentDescription = null,
                  tint = fontColor,
              )
              Spacer(modifier = Modifier.width(8.dp))
              Text(
                  text = eventType,
                  fontSize = 14.sp,
                  style = MaterialTheme.typography.bodyLarge,
                  color = fontColor,
              )
            }
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
        val eventDateTime = LocalDateTime.of(2024, 10, 24, 23, 59, 33) // 24.10.2024

        AbstimmungCard(
            title = "Vorstandswahl", eventType = "Jahreshauptversammlung", date = eventDateTime)
      }
    }
  }
}
