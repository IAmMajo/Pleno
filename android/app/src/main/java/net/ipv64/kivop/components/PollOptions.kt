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

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollVotingOptionDTO
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary

@Composable
fun PollOptions(options: List<GetPollVotingOptionDTO>, onCheckedChange: (Int) -> Unit) {
  var selectedIndex by remember { mutableIntStateOf(-1) } // -1 means no selection

  Column(
      modifier =
          Modifier.customShadow()
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(10.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
          Icon(
              painter = painterResource(id = R.drawable.ic_voting_24),
              "Vote",
              tint = Primary,
              modifier =
                  Modifier.background(Secondary, shape = RoundedCornerShape(8.dp)).padding(8.dp))
          Spacer(modifier = Modifier.size(8.dp))
          Text(text = "Abstimmung")
        }
        Spacer(modifier = Modifier.size(16.dp))
        options.forEach { option ->
          Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(text = option.text)
            Spacer(modifier = Modifier.weight(1f))
            CustomCheckbox(
                size = 30.dp,
                checked = if (selectedIndex == option.index.toInt()) true else false,
                onCheckedChange = { isChecked ->
                  if (isChecked) {
                    onCheckedChange(option.index.toInt())
                    selectedIndex = option.index.toInt()
                    Log.i("PollOptions", "onCheckedChange: $selectedIndex")
                  } else {
                    onCheckedChange(-1)
                    selectedIndex = -1
                  }
                })
          }
          Spacer(modifier = Modifier.size(16.dp))
        }
      }
}
