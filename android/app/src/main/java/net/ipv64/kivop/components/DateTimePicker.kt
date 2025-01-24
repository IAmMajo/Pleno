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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_tertiary
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*

@Composable
fun DateTimePicker(
  modifier: Modifier,
  context: Context,
  name: String = "",
  onDateTimeSelected: (LocalDateTime) -> Unit) {
  var selectedDateTime by remember { mutableStateOf<LocalDateTime?>(null) }

  val calendar = Calendar.getInstance()

  val datePicker = DatePickerDialog(
    context,
    { _: DatePicker, year: Int, month: Int, day: Int ->
      // After selecting date, show Time Picker
      val timePicker = TimePickerDialog(
        context,
        { _: TimePicker, hour: Int, minute: Int ->
          // ✅ Create LocalDateTime
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
    calendar.get(Calendar.DAY_OF_MONTH)
  )

  Column(
    modifier = Modifier
      .fillMaxWidth()
      .background(Primary)
      .then(modifier)
  ) {
    Text(text = name, style = TextStyles.contentStyle, color = Text_prime_light)
    SpacerBetweenElements(4.dp)
    Box(
      modifier = Modifier
        .fillMaxWidth()
        .height(56.dp)
        .clickable { datePicker.show() }
        .clip(RoundedCornerShape(4.dp))
        .background(Background_prime)
        .padding(horizontal = 6.dp, vertical = 8.dp)
    ){
      Text(
        modifier = Modifier.align(Alignment.CenterStart),
        text = selectedDateTime?.format(DateTimeFormatter.ofPattern("dd.MM.yyyy | HH:mm"))
          ?: "Select Date & Time",
        style = TextStyles.contentStyle,
        color = if(selectedDateTime == null) Text_tertiary.copy(0.4f) else Text_prime, 
        textAlign = TextAlign.Center
      )
    }
      
  }
}
