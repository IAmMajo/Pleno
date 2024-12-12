package com.example.kivopandriod.pages

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.moduls.GetVotingDTO
import net.ipv64.kivop.moduls.GetVotings
import net.ipv64.kivop.ui.theme.Background_secondary_light

@Composable
fun VotingsListPage(navController: NavController){
    var votings by remember { mutableStateOf<List<GetVotingDTO>>(emptyList()) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        scope.launch {
            val result = GetVotings(navController.context)
            votings = result
        }
    }

    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        Text(text = "Votings")
        LazyColumn(){
            items(votings) { voting ->
                Row (
                    modifier = Modifier
                        .background(color = Background_secondary_light)
                        .fillMaxWidth()
                        .clickable(true, onClick = {
                            val route = "abstimmungen/${voting.id}"
                            navController.navigate(route)
                        })
                ){
                    Column {
                        Text(text = voting.description)
                        Spacer(modifier = Modifier.size(10.dp))
                        if (voting.startedAt != null)
                            Text(text = voting.startedAt!!)
                    }
                }
                Spacer(modifier = Modifier.size(8.dp))
            }
        }
    }
}