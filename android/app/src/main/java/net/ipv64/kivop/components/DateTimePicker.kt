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

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.Context
import android.widget.DatePicker
import android.widget.TimePicker
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun DateTimePicker(
    modifier: Modifier,
    context: Context,
    name: String? = null,
    backgroundColor: Color = Background_prime,
    onDateTimeSelected: (LocalDateTime) -> Unit
) {
  var selectedDateTime by remember { mutableStateOf<LocalDateTime?>(null) }

  val calendar = Calendar.getInstance()

  val datePicker =
      DatePickerDialog(
          context,
          { _: DatePicker, year: Int, month: Int, day: Int ->
            // After selecting date, show Time Picker
            val timePicker =
                TimePickerDialog(
                    context,
                    { _: TimePicker, hour: Int, minute: Int ->
                      val localDateTime = LocalDateTime.of(year, month + 1, day, hour, minute)
                      selectedDateTime = localDateTime
                      onDateTimeSelected(localDateTime)
                    },
                    calendar.get(Calendar.HOUR_OF_DAY),
                    calendar.get(Calendar.MINUTE),
                    true // Use 24-hour format
                    )
            timePicker.show()
          },
          calendar.get(Calendar.YEAR),
          calendar.get(Calendar.MONTH),
          calendar.get(Calendar.DAY_OF_MONTH))

  Column(modifier = Modifier.fillMaxWidth().background(Color.Transparent).then(modifier)) {
    if (name != null) {
      Text(text = name, style = TextStyles.contentStyle, color = Text_prime_light)
      SpacerBetweenElements(4.dp)
    }
    Box(
        modifier =
            Modifier.fillMaxWidth()
                .height(56.dp)
                .clickable { datePicker.show() }
                .clip(RoundedCornerShape(4.dp))
                .background(backgroundColor)
                .padding(horizontal = 6.dp, vertical = 8.dp)) {
          Text(
              modifier = Modifier.align(Alignment.CenterStart),
              text =
                  selectedDateTime?.format(DateTimeFormatter.ofPattern("dd.MM.yyyy | HH:mm"))
                      ?: "Select Date & Time",
              style = TextStyles.contentStyle,
              color = if (selectedDateTime == null) Text_tertiary.copy(0.4f) else Text_prime,
              textAlign = TextAlign.Center)
        }
  }
}
