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

import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultsDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultsDTO
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.VotingColors

@SuppressLint("DefaultLocale")
@Composable
fun ResultCard(votingResults: GetVotingResultsDTO, votingData: GetVotingDTO) {
  val colors: List<Color> = VotingColors
  Log.i("ResultCard", "ResultCard: $votingResults")
  Log.i("ResultCard", "ResultCard: $votingData")
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(color = Background_secondary, shape = RoundedCornerShape(6.dp))
              .padding(6.dp)) {
        Column {
          votingResults.results.forEach { result ->
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 6.dp, vertical = 3.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
              Box(
                  modifier =
                      Modifier.background(colors[result.index.toInt()], shape = CircleShape)
                          .size(16.dp),
              ) {}
              // Icon(imageVector = Icons.Rounded.CheckCircle, contentDescription = "wahl", tint =
              // colors[votingResults.indexOf(result)])
              Spacer(modifier = Modifier.size(3.dp))
              if (result.index.toInt() == 0) {
                Text("Enthalten", color = Text_prime, style = TextStyles.contentStyle)
              } else {
                Text(
                    votingData.options[result.index.toInt() - 1].text,
                    color = Text_prime,
                    style = TextStyles.contentStyle)
              }

              Spacer(modifier = Modifier.weight(1f))
              Text(text = result.percentage.toString() + "%", color = Text_prime)
            }
          }
        }
      }
}

@SuppressLint("DefaultLocale")
@Composable
fun ResultCard(votingResults: GetPollResultsDTO, votingData: GetPollDTO) {
  val colors: List<Color> = VotingColors
  Log.i("ResultCard", "ResultCard: $votingResults")
  Log.i("ResultCard", "ResultCard: $votingData")
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(color = Background_secondary, shape = RoundedCornerShape(6.dp))
              .padding(6.dp)) {
        Column {
          votingResults.results.forEach { result ->
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 6.dp, vertical = 3.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
              Box(
                  modifier =
                      Modifier.background(colors[result.index.toInt()], shape = CircleShape)
                          .size(16.dp),
              ) {}
              // Icon(imageVector = Icons.Rounded.CheckCircle, contentDescription = "wahl", tint =
              // colors[votingResults.indexOf(result)])
              Spacer(modifier = Modifier.size(3.dp))
              if (result.index.toInt() == 0) {
                Text("Enthalten", color = Text_prime, style = TextStyles.contentStyle)
              } else {
                Text(
                    votingData.options[result.index.toInt() - 1].text,
                    color = Text_prime,
                    style = TextStyles.contentStyle)
              }

              Spacer(modifier = Modifier.weight(1f))
              Text(text = String.format("%.2f%%", result.percentage), color = Text_prime)
            }
          }
        }
      }
}
