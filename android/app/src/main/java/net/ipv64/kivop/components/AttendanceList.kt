package net.ipv64.kivop.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
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
import net.ipv64.kivop.models.attendancesList
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
@OptIn(ExperimentalFoundationApi::class)
fun AttendanceCoordinationList(
    responses: List<attendancesList>,
    title: String,
    isVisible: Boolean,
    maxMembernumber: Int,
    onVisibilityToggle: (Boolean) -> Unit,
    background: Color = Color(color = 0xFF686D74)
) {
  // stickyHeader
  Column {
    LabelMax(onClick = { onVisibilityToggle(!isVisible) }, backgroundColor = background) {
      AttendanceSeparatorContent(
          text = title, maxMembernumber = maxMembernumber, statusMembernumber = responses.size)
    }
    // Item with AnimatedVisibility
    AnimatedVisibility(visible = isVisible, enter = expandVertically(), exit = shrinkVertically()) {
      Column { responses.forEach { item -> AttendanceItemRow(item = item) } }
    }
  }
}

// Composable für eine einzelne Zeile in der Rückmeldungs-Liste
@Composable
fun AttendanceItemRow(item: attendancesList) {
  Row(
      modifier = Modifier.fillMaxWidth().padding(6.dp),
      verticalAlignment = Alignment.CenterVertically) {
        val initial = item.name.firstOrNull()?.toString() ?: ""
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(40.dp).clip(CircleShape).background(Color(0xFF1061DA))) {
              Text(
                  text = initial,
                  color = Background_prime,
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
      }
}

@Composable
fun AttendanceSeparatorContent(text: String, maxMembernumber: Int, statusMembernumber: Int) {
  Row(
      modifier = Modifier.fillMaxWidth().padding(start = 8.dp),
      verticalAlignment = Alignment.CenterVertically,
      horizontalArrangement = Arrangement.SpaceBetween) {
        Text(
            text = text,
            color = Background_prime,
            fontWeight = FontWeight.SemiBold,
            fontSize = 12.sp)
        Row(verticalAlignment = Alignment.CenterVertically) {
          Icon(
              painter = painterResource(id = R.drawable.ic_groups),
              contentDescription = null,
              tint = Background_prime,
              modifier = Modifier.size(24.dp))
          Spacer(modifier = Modifier.width(8.dp))
          Text(
              text = "$statusMembernumber / $maxMembernumber",
              fontWeight = FontWeight.SemiBold,
              fontSize = 10.sp,
              color = Background_prime)
        }
      }
}
