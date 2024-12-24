package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter.ofPattern
import java.util.UUID
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun BulletList(title: String, list: List<GetMeetingDTO?>, gap: Dp = 16.dp) {

  Column(
      modifier =
          Modifier.customShadow()
              .background(color = Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(15.dp)
              .height(IntrinsicSize.Min)) {
        Text(text = title, style = MaterialTheme.typography.headlineMedium)
        Spacer(modifier = Modifier.size(8.dp))
        Row {
          // val height = maxHeight
          // val width = maxWidth
          Column(
              modifier =
                  Modifier.width(8.dp).fillMaxHeight().drawBehind {
                    line(list.size, gap.toPx())
                  }) {}
          Column(modifier = Modifier.fillMaxHeight()) {
            Spacer(modifier = Modifier.size(gap))
            list.forEach { meeting ->
              if (meeting != null) {
                Eintrag(meeting = meeting, gap)
              }
            }
          }
        }
      }
}

fun DrawScope.line(items: Int, gap: Float) {
  val height = size.height
  val elementHeight = (height - (gap * (items.toFloat() + 1.0f))) / items
  val offsetStart = Offset(0.0f, 0.0f)
  val offsetEnd = Offset(0.0f, height)

  val jump = elementHeight + gap
  val offsetCircleStart = Offset(0.0f, elementHeight / 2 + gap)

  drawLine(Text_prime, offsetStart, offsetEnd, 6.0f, StrokeCap.Round)
  for (i in 0..<items) {

    drawCircle(Text_prime, 12.0f, Offset(offsetCircleStart.x, offsetCircleStart.y + jump * i))
  }
}

@Composable
fun Eintrag(meeting: GetMeetingDTO, gap: Dp) {
  Row(modifier = Modifier.fillMaxWidth().padding(4.dp)) {
    Spacer(modifier = Modifier.size(4.dp))
    Text(
        text = "[ " + meeting.start.format(ofPattern("dd.MM.yyyy")) + " ]",
        color = Text_prime,
        style = MaterialTheme.typography.bodyLarge)
    Spacer(modifier = Modifier.size(4.dp))
    Text(text = meeting.name, color = Text_prime, style = MaterialTheme.typography.bodyLarge)
  }
  Spacer(modifier = Modifier.size(gap))
}

@Preview
@Composable
fun previewBulletList() {
  val list =
      listOf(
          GetMeetingDTO(
              id = UUID.randomUUID(),
              name = "test",
              description = "test",
              status = MeetingStatus.inSession,
              start = LocalDateTime.now(),
              duration = null,
              location = null,
              chair = null,
              code = null,
              myAttendanceStatus = null,
          ),
          GetMeetingDTO(
              id = UUID.randomUUID(),
              name = "test",
              description = "test",
              status = MeetingStatus.inSession,
              start = LocalDateTime.now(),
              duration = null,
              location = null,
              chair = null,
              code = null,
              myAttendanceStatus = null,
          ),
          GetMeetingDTO(
              id = UUID.randomUUID(),
              name = "test",
              description = "test",
              status = MeetingStatus.inSession,
              start = LocalDateTime.now(),
              duration = null,
              location = null,
              chair = null,
              code = null,
              myAttendanceStatus = null,
          ))
  Column(modifier = Modifier.padding(18.dp)) { BulletList("Bevorstehende Sitzungen", list) }
}
