package net.ipv64.kivop.components

import android.graphics.Paint
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import java.util.UUID
import kotlin.math.*
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultsDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultsDTO
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.VotingColors

@Composable
fun PieChart(
    votingResults: GetVotingResultsDTO,
    explodeDistance: Float = 10f,
    showLabel: Boolean = false,
) {
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(10.dp),
      horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier =
                Modifier.size(250.dp).aspectRatio(1f).drawBehind {
                  if (votingResults.totalCount.toInt() != 0) {
                    drawPieChart(
                        votingResults.results,
                        votingResults.totalCount.toInt(),
                        explodeDistance = explodeDistance,
                        showLabel)
                  } else {
                    val noVotings =
                        GetVotingResultsDTO(
                            votingId = UUID.randomUUID(),
                            myVote = (0).toUByte(),
                            totalCount = 1u,
                            results =
                                listOf(
                                    GetVotingResultDTO((0).toUByte(), 1u, 100.0, listOf()),
                                ))
                    drawPieChart(noVotings.results, noVotings.totalCount.toInt(), 1.0f, showLabel)
                  }
                }) {}
      }
}

@Composable
fun PieChartPoll(
  pollResults: GetPollResultsDTO,
  explodeDistance: Float = 10f,
  showLabel: Boolean = false,
) {
  Column(
    modifier =
    Modifier.fillMaxWidth()
      .customShadow()
      .background(Background_secondary, shape = RoundedCornerShape(8.dp))
      .padding(10.dp),
    horizontalAlignment = Alignment.CenterHorizontally) {
    Box(
      modifier =
      Modifier.size(250.dp).aspectRatio(1f).drawBehind {
        if (pollResults.totalCount.toInt() != 0) {
          drawPieChartPoll(
            pollResults.results,
            pollResults.totalCount.toInt(),
            explodeDistance = explodeDistance,
            showLabel)
        } else {
          val noVotings =
            GetVotingResultsDTO(
              votingId = UUID.randomUUID(),
              myVote = (0).toUByte(),
              totalCount = 1u,
              results =
              listOf(
                GetVotingResultDTO((0).toUByte(), 1u, 100.0, listOf()),
              ))
          drawPieChart(noVotings.results, noVotings.totalCount.toInt(), 1.0f, showLabel)
        }
      }) {}
  }
}

val CakeColorStart = Color(0xFF2C7D91)
val CakeColorEnd = Color(0xFFF7DEC8)

fun DrawScope.drawPieChart(
    list: List<GetVotingResultDTO>,
    totalVotes: Int,
    explodeDistance: Float,
    showLabel: Boolean
) {
  val colors: List<Color> = VotingColors
  // startingAngle -90° to start at the top
  var startingAngle: Float = -90.0f

  // adjust size of chart to keep it in bound -- takes away the explode distance from each side
  val adjustedSize =
      size.copy(
          width = size.width - explodeDistance * 2, height = size.height - explodeDistance * 2)
  // offset to keep the chart in bound
  val offset = Offset(explodeDistance, explodeDistance)
  // set textPaint
  val textPaint =
      Paint().apply {
        color = android.graphics.Color.WHITE
        textSize = 60f
        textAlign = Paint.Align.CENTER
      }

  for (i in list.indices) {
    // calc sweep angle percentage of total votes
    val sweepAngle = calcSweepAngle(list[i].count.toInt(), totalVotes)
    // calc explodeOffset. How much each slice is moved from the center
    val explodeOffset = calcPointOnCircle(startingAngle, sweepAngle, explodeDistance)
    drawArc(
        colors[list[i].index.toInt()],
        startingAngle,
        sweepAngle,
        true,
        topLeft = offset.copy(x = offset.x + explodeOffset.x, y = offset.y + explodeOffset.y),
        size = adjustedSize)
    //    if (showLabel) {
    //      // radius of the circle adjustedSize = diameter
    //      val radius = size.width / 2
    //      // find Text offset 1/3
    //      val textOffset = calcPointOnCircle(startingAngle, sweepAngle, adjustedSize.width / 3)
    //      // calc text position by taking the center and add the offset from textOffset
    //      val textPos = Offset(radius, radius) + textOffset
    //      // estimate the width of the arc
    //      val sliceWidth = (sweepAngle / 360) * (2 * Math.PI * radius).toFloat() * 0.5f
    //      // set text name
    //      val textName = list[i].label
    //      // calc set percentage
    //      val textPercentage = list[i].percentage.toString() + "%"
    //      // get the text name width
    //      val textWidth = textPaint.measureText(textName)
    //      // check if the text fits in the slice
    //      if (textWidth < sliceWidth) {
    //        // draw name
    //        drawContext.canvas.nativeCanvas.drawText(textName, textPos.x, textPos.y, textPaint)
    //        // draw percentage under name
    //        val textPercentageOffsetY = textPaint.textSize * 1.1f
    //        drawContext.canvas.nativeCanvas.drawText(
    //            textPercentage, textPos.x, textPos.y + textPercentageOffsetY, textPaint)
    //      }
    //    }

    startingAngle += sweepAngle
  }
}

fun calcSweepAngle(votes: Int, totalVotes: Int): Float {
  // votes in percentage for the sweep angle
  return 360 * (votes.toFloat() / totalVotes)
}

// calc the explode offset(offset of starting point)
fun calcPointOnCircle(startingAngle: Float, sweepAngle: Float, explodeDistance: Float): Offset {
  // mid point of the slice on the outside
  val explodeAngle = startingAngle + sweepAngle / 2
  // calc the x and y offset by calculation the point on a circle with the radius of the explode
  // distance
  val offsetX = cos(Math.toRadians(explodeAngle.toDouble())).toFloat() * explodeDistance
  val offsetY = sin(Math.toRadians(explodeAngle.toDouble())).toFloat() * explodeDistance
  return Offset(offsetX, offsetY)
}




fun DrawScope.drawPieChartPoll(
  list: List<GetPollResultDTO>,
  totalVotes: Int,
  explodeDistance: Float,
  showLabel: Boolean
) {
  val colors: List<Color> = VotingColors
  // startingAngle -90° to start at the top
  var startingAngle: Float = -90.0f

  // adjust size of chart to keep it in bound -- takes away the explode distance from each side
  val adjustedSize =
    size.copy(
      width = size.width - explodeDistance * 2, height = size.height - explodeDistance * 2)
  // offset to keep the chart in bound
  val offset = Offset(explodeDistance, explodeDistance)
  // set textPaint
  val textPaint =
    Paint().apply {
      color = android.graphics.Color.WHITE
      textSize = 60f
      textAlign = Paint.Align.CENTER
    }

  for (i in list.indices) {
    // calc sweep angle percentage of total votes
    val sweepAngle = calcSweepAngle(list[i].count.toInt(), totalVotes)
    // calc explodeOffset. How much each slice is moved from the center
    val explodeOffset = calcPointOnCircle(startingAngle, sweepAngle, explodeDistance)
    drawArc(
      colors[list[i].index.toInt()],
      startingAngle,
      sweepAngle,
      true,
      topLeft = offset.copy(x = offset.x + explodeOffset.x, y = offset.y + explodeOffset.y),
      size = adjustedSize)
    //    if (showLabel) {
    //      // radius of the circle adjustedSize = diameter
    //      val radius = size.width / 2
    //      // find Text offset 1/3
    //      val textOffset = calcPointOnCircle(startingAngle, sweepAngle, adjustedSize.width / 3)
    //      // calc text position by taking the center and add the offset from textOffset
    //      val textPos = Offset(radius, radius) + textOffset
    //      // estimate the width of the arc
    //      val sliceWidth = (sweepAngle / 360) * (2 * Math.PI * radius).toFloat() * 0.5f
    //      // set text name
    //      val textName = list[i].label
    //      // calc set percentage
    //      val textPercentage = list[i].percentage.toString() + "%"
    //      // get the text name width
    //      val textWidth = textPaint.measureText(textName)
    //      // check if the text fits in the slice
    //      if (textWidth < sliceWidth) {
    //        // draw name
    //        drawContext.canvas.nativeCanvas.drawText(textName, textPos.x, textPos.y, textPaint)
    //        // draw percentage under name
    //        val textPercentageOffsetY = textPaint.textSize * 1.1f
    //        drawContext.canvas.nativeCanvas.drawText(
    //            textPercentage, textPos.x, textPos.y + textPercentageOffsetY, textPaint)
    //      }
    //    }

    startingAngle += sweepAngle
  }
}




@Preview
@Composable
fun PieChartPreview() {
  val votingResults =
      GetVotingResultsDTO(
          votingId = UUID.randomUUID(),
          myVote = (1).toUByte(),
          totalCount = 10u,
          results =
              listOf(
                  GetVotingResultDTO((0).toUByte(), 5u, 50.0, listOf()),
                  GetVotingResultDTO((1).toUByte(), 2u, 20.0, listOf()),
                  GetVotingResultDTO((2).toUByte(), 3u, 30.0, listOf()),
              ))
  PieChart(votingResults)
}


