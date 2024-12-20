package net.ipv64.kivop.components

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingOptionDTO
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary

@Composable
fun VoteOptions(
  options: List<GetVotingOptionDTO>,
  onCheckedChange: (Int) -> Unit
){
  var selectedIndex by remember { mutableIntStateOf(-1) } // -1 means no selection
  
  Column(
    modifier = Modifier
      .shadow(
        elevation = 4.dp,
        shape = RoundedCornerShape(8.dp),
      )
      .background(Background_secondary,shape = RoundedCornerShape(8.dp))
      .padding(10.dp)
      
  ) {
    Row(
      verticalAlignment = Alignment.CenterVertically
    ) { 
      Icon(
        painter = painterResource(id = R.drawable.ic_voting_24),
        "Vote",
        tint = Primary,
        modifier = Modifier
          .background(Secondary,shape = RoundedCornerShape(8.dp))
          .padding(8.dp))
      Spacer(modifier = Modifier.size(8.dp))
      Text(text = "Abstimmung")
    }
    Spacer(modifier = Modifier.size(16.dp))
    options.forEach { option ->
      Row(
        modifier = Modifier
          .fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(text = option.text)
        Spacer(modifier = Modifier.weight(1f))
        CustomCheckbox(
          size = 30.dp,
          checked = if (selectedIndex == option.index.toInt()) true else false,
          onCheckedChange = { isChecked ->
            if (isChecked) {
              onCheckedChange(option.index.toInt())
              selectedIndex = option.index.toInt()
            } else {
              onCheckedChange(-1)
              selectedIndex = -1
            }
          }
        )
      }
      Spacer(modifier = Modifier.size(16.dp))
    }
  }
}


@Preview
@Composable
fun previewVote(){
  var options = listOf<GetVotingOptionDTO>(
    GetVotingOptionDTO(1u, "Option 1"),
    GetVotingOptionDTO(2u, "Option 2"),
    GetVotingOptionDTO(3u, "Option 3")
  )
  var selectedIndex by remember { mutableIntStateOf(-1) }
  Log.i("Vote", "Checked: $selectedIndex")
  Column(modifier = Modifier.background(Background_prime).padding(8.dp).fillMaxHeight()) {
    VoteOptions(options, onCheckedChange = { index ->
      selectedIndex = index
    })
  }
}