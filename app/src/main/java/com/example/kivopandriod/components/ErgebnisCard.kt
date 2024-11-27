package com.example.kivopandriod.components

import android.annotation.SuppressLint
import android.graphics.Color.CYAN
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.layout
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.moduls.VotingResults
import com.example.kivopandriod.services.interpolateColor
import com.example.kivopandriod.ui.theme.Background_secondary_light
import com.example.kivopandriod.ui.theme.Text_light

val CakeColorStart = Color(0xFF2C7D91)
val CakeColorEnd = Color(0xFFF7DEC8)

@SuppressLint("DefaultLocale")
@Composable
fun ErgebnisCard(
    votingResults: List<VotingResults>
){
    val totalVotes = votingResults.sumOf { it.votes }
    val colors: List<Color> = interpolateColor(CakeColorStart, CakeColorEnd, votingResults.size)
    Box(modifier = Modifier
        .fillMaxWidth()
        .background(color = Background_secondary_light,shape = RoundedCornerShape(6.dp))
        .padding(6.dp)
        ){
        Column (){
            Text("Ergenbnisse", color = Text_light)
            Column {
                votingResults.forEach{result ->
                    Row(modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 6.dp, vertical = 3.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Box(modifier = Modifier
                            .background(colors[votingResults.indexOf(result)], shape = CircleShape)
                            .size(16.dp),
                        ){
                        }
                        //Icon(imageVector = Icons.Rounded.CheckCircle, contentDescription = "wahl", tint = colors[votingResults.indexOf(result)])
                        Spacer(modifier = Modifier.size(3.dp))
                        Text(result.label,color = Text_light)
                        Spacer(modifier = Modifier.weight(1f))
                        Text((String.format("%.2f%%",(result.votes.toFloat() / totalVotes) * 100)),color = Text_light)
                    }
                }
            }
        }
    }
}
@Preview
@Composable
private fun PreviewErgebnisCard(){
    ErgebnisCard(
        votingResults = listOf(
            VotingResults("Option 1", 10),
            VotingResults("Option 2", 20),
            VotingResults("Option 3", 30),
        ))
}