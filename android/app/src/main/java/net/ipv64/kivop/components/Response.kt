package net.ipv64.kivop.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Text_prime

data class ResponseItem(val name: String, val status: AttendanceStatus?)

// Composable für die Liste der Rückmeldungen
@Composable
fun PendingList(responses: List<ResponseItem>,maxMembernumber: Int) {
  var isVisible by remember { mutableStateOf(true) }
  LabelMax(onClick = { isVisible = !isVisible }) {
    AttendanceSeparatorContent(text = "Ausstehend",maxMembernumber = maxMembernumber,statusMembernumber = responses.size)
  }


  // Animierte LazyColumn
  AnimatedVisibility(
    visible = isVisible,
    enter = expandVertically(),
    exit = shrinkVertically()
  ) {
    LazyColumn(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
      items(responses) { item -> ResponseItemRow(item = item) }
    }
  }

  Spacer(Modifier.height(23.dp))
}

@Composable
fun PresentList(responses: List<ResponseItem>, maxMembernumber: Int) {
  var isVisible by remember { mutableStateOf(true) }
  
  LabelMax(onClick = { isVisible = !isVisible }) {
    AttendanceSeparatorContent(text = "Present",maxMembernumber = maxMembernumber,statusMembernumber = responses.size)
  }


  // Animierte LazyColumn
  AnimatedVisibility(
    visible = isVisible,
    enter = expandVertically(),
    exit = shrinkVertically()
  ) {
    LazyColumn(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
      items(responses) { item -> ResponseItemRow(item = item) }
    }
  }
  Spacer(Modifier.height(23.dp))
}



@Composable
fun AbsentList(responses: List<ResponseItem>, maxMembernumber: Int) {
  var isVisible by remember { mutableStateOf(true) }
  LabelMax(onClick = { isVisible = !isVisible }, backgroundColor = Color(0xffDA1043)) {
    AttendanceSeparatorContent(text = "Abgesagt",maxMembernumber = maxMembernumber,statusMembernumber = responses.size)
  }


  // Animierte LazyColumn
  AnimatedVisibility(
    visible = isVisible,
    enter = expandVertically(),
    exit = shrinkVertically()
  ) {
    LazyColumn(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
      items(responses) { item -> ResponseItemRow(item = item) }
    }
  }

  Spacer(Modifier.height(23.dp))
}

@Composable
fun AcceptedList(responses: List<ResponseItem>, maxMembernumber: Int) {
  var isVisible by remember { mutableStateOf(true) }
  LabelMax(onClick = { isVisible = !isVisible }, backgroundColor = Color(color = 0xFF1061DA)) {
    AttendanceSeparatorContent(text = "Zugesagt",maxMembernumber = maxMembernumber,statusMembernumber = responses.size)
  }


  // Animierte LazyColumn
  AnimatedVisibility(
    visible = isVisible,
    enter = expandVertically(),
    exit = shrinkVertically()
  ) {
    LazyColumn(
      modifier = Modifier.fillMaxWidth(),
      verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
      items(responses) { item -> ResponseItemRow(item = item) }
    }
  }

  Spacer(Modifier.height(23.dp))
}



// Composable für eine einzelne Zeile in der Rückmeldungs-Liste
@Composable
fun ResponseItemRow(item: ResponseItem) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .padding(6.dp),
    verticalAlignment = Alignment.CenterVertically
  ) {
    val initial = item.name.firstOrNull()?.toString() ?: ""
    Box(
      contentAlignment = Alignment.Center,
      modifier = Modifier
        .size(40.dp)
        .clip(CircleShape)
        .background(Color(0xFF1061DA))
    ) {
      Text(
        text = initial,
        color = Text_prime,
        fontSize = 18.sp,
        style = MaterialTheme.typography.bodyLarge,
        fontWeight = FontWeight.Bold
      )
    }

    Spacer(modifier = Modifier.width(5.dp))

    Text(
      text = item.name,
      color = Background_prime,
      modifier = Modifier.weight(1f),
      style = MaterialTheme.typography.bodyLarge,
      fontWeight = FontWeight.Medium
    )
    
  }
}


@Composable
fun AttendanceSeparatorContent(text: String, maxMembernumber: Int, statusMembernumber: Int) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .padding(start = 8.dp),
    verticalAlignment = Alignment.CenterVertically,
    horizontalArrangement = Arrangement.SpaceBetween
  ) {
    Text(
      text = text,
      color = Background_prime,
      fontWeight = FontWeight.SemiBold,
      fontSize = 12.sp
    )
    Row(verticalAlignment = Alignment.CenterVertically) {
      Icon(
        painter = painterResource(id = R.drawable.ic_groups),
        contentDescription = null,
        tint = Background_prime,
        modifier = Modifier.size(24.dp)
      )
      Spacer(modifier = Modifier.width(8.dp))
      Text(text = "$statusMembernumber / $maxMembernumber",
        fontWeight = FontWeight.SemiBold,
        fontSize = 10.sp,
        color = Background_prime)
      
      
    }
  }

}


//@Preview(showBackground = true)
//@Composable
//fun ResponseListPreview() {
//  MaterialTheme {
//    Surface {
//      val responses =
//          listOf(
//              ResponseItem("Max Muster", 1),
//              ResponseItem("Dieter Ausnahme", 0),
//              ResponseItem("Fridolin Fröhlich", 2),
//              ResponseItem("Peter Prüde", 1),
//              ResponseItem("Susi Sommer", 2),
//              ResponseItem("Thorsten Trauer", 1),
//              ResponseItem("Wolfgang Wunder", 0))
//      ResponseList(responses = responses, "Rückmeldungen")
//    }
//  }
//}
