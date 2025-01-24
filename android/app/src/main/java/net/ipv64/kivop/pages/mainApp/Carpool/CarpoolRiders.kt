package net.ipv64.kivop.pages.mainApp.Carpool

import android.util.Log
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.RiderCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.viewModel.CarpoolViewModel
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun CarpoolRiders(navController: NavController, carpoolViewModel: CarpoolViewModel) {
  val scope = rememberCoroutineScope()
  carpoolViewModel.calcRidersSize()
  // Fetch addresses for each rider
  LaunchedEffect(carpoolViewModel.carpool?.riders) {
    carpoolViewModel.carpool?.riders?.let { riders ->
      val newAddresses = riders.associate { rider ->
        //only fetch when the riders address isnt already in the lib
        if(carpoolViewModel.riderAddresses.containsKey(rider.id)){
          rider.id to carpoolViewModel.riderAddresses[rider.id].toString()
        } else {
          rider.id to carpoolViewModel.fetchAddress(
            rider.latitude.toDouble(),
            rider.longitude.toDouble()
          ).toString()
        }
      }
      carpoolViewModel.riderAddresses = newAddresses
    }
  }
  LazyColumn {
    val acceptedRiders = carpoolViewModel.carpool?.riders?.filter { it.accepted } ?: emptyList()
    val notAcceptedRiders = carpoolViewModel.carpool?.riders?.filter { !it.accepted } ?: emptyList()
    if (acceptedRiders.isNotEmpty()) {
      item {
        Row {
          Text(
            text = "Zugelassen",
            color = Text_prime,
            style = TextStyles.subHeadingStyle,
          )
          Spacer(modifier = Modifier.weight(1f))
          Text(
            text = carpoolViewModel.ridersSize.toString()+"/"+carpoolViewModel.carpool?.emptySeats,
            color = Text_prime,
            style = TextStyles.subHeadingStyle,
          )
        }
        SpacerBetweenElements()
      }
      items(acceptedRiders) { rider ->
        RiderCard(
          rider = rider,
          address = carpoolViewModel.riderAddresses[rider.id],
          onAccept = {},
          onDecline = {
            scope.launch {
              if(carpoolViewModel.patchAcceptRequest(riderId = rider.id, accepted = false)){
                carpoolViewModel.carpool = carpoolViewModel.carpool?.copy(
                  riders = carpoolViewModel.carpool?.riders?.map {
                    if (it.id == rider.id) it.copy(accepted = false) else it
                  } ?: emptyList()
                )
              }
            }
          }
        )
        SpacerBetweenElements()
      }
    }
    if (notAcceptedRiders.isNotEmpty()) {
      item {
        Text(
          text = "Ausstehend",
          color = Text_prime,
          style = TextStyles.subHeadingStyle,
        )
        SpacerBetweenElements()
      }
      items(notAcceptedRiders) { rider ->
        RiderCard(
          rider = rider,
          address = carpoolViewModel.riderAddresses[rider.id],
          onAccept = {
            scope.launch {
              if(carpoolViewModel.patchAcceptRequest(riderId = rider.id, accepted = true)){
                carpoolViewModel.carpool = carpoolViewModel.carpool?.copy(
                  riders = carpoolViewModel.carpool?.riders?.map {
                    if (it.id == rider.id) it.copy(accepted = true) else it
                  } ?: emptyList()
                )
              }
            } 
          },
          onDecline = {
            //Dont need this
//            scope.launch {
//              if(carpoolViewModel.deleteRequest(riderId = rider.id)){
//                carpoolViewModel.carpool = carpoolViewModel.carpool?.copy(
//                  riders = carpoolViewModel.carpool?.riders?.filter { it.id != rider.id } ?: emptyList()
//                )
//              }
//            }
          },
          enableDecline = carpoolViewModel.canAcceptMoreRiders()
        )
        SpacerBetweenElements()
      }
    }
  }
}
