package net.ipv64.kivop.pages

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun AlreadyVoted(navController: NavController, votingID: String) {
  BackHandler {
    val previousBackStackEntry = navController.previousBackStackEntry
    if (previousBackStackEntry != null){
      if (previousBackStackEntry.destination.route.toString() == "abstimmen/{votingID}") {
        navController.popBackStack()
        navController.popBackStack()
      }else{
        navController.popBackStack()
      }
    }
  }
  Column(
    modifier = Modifier
      .background(Background_prime)
      .fillMaxHeight(),
    horizontalAlignment = Alignment.CenterHorizontally,
  ){
    Icon(
      modifier = Modifier.size(300.dp),
      tint = Text_prime,
      painter = painterResource(id = R.drawable.ic_clock),
      contentDescription = "Icon Clock"
    )
    Text(
      text = "Die Abstimmung ist noch im Gange...",
      color = Text_prime, fontSize = 25.sp,
      textAlign = TextAlign.Center)
  }
}