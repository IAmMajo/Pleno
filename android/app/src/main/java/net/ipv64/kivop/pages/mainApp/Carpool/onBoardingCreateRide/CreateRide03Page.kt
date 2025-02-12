package net.ipv64.kivop.pages.mainApp.Carpool.onBoardingCreateRide

import DateTimePicker
import android.util.Log
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.PagerState
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.DebouncedTextFieldCustomInputField
import net.ipv64.kivop.components.MapDynamicTwoMarker
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.components.TextFieldStatus
import net.ipv64.kivop.models.viewModel.CreateSpecialRideViewModel
import net.ipv64.kivop.models.viewModel.MapViewModel
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CreateRide03Page(
    pagerState: PagerState,
    createSpecialRideViewModel: CreateSpecialRideViewModel = viewModel(),
    mapViewModel: MapViewModel = viewModel()
) {
  Column(
      modifier = Modifier.fillMaxWidth().fillMaxHeight().background(Primary),
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center) {
        SpacerTopBar()
        Text(
            text = "Plane deine Route", // TODO: replace text with getString (Übersetzung)
            style = TextStyles.headingStyle,
            color = Text_prime_light)
        Column(
            modifier = Modifier.fillMaxWidth().weight(4f).background(Primary).padding(18.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
          Row {
            DateTimePicker(
                modifier = Modifier.weight(1f),
                LocalContext.current,
                name = "Startzeit",
                onDateTimeSelected = { createSpecialRideViewModel.starts = it })
            SpacerBetweenElements(8.dp)
            DateTimePicker(
                modifier = Modifier.weight(1f),
                LocalContext.current,
                name = "Ankunftszeit",
                onDateTimeSelected = { createSpecialRideViewModel.ends = it })
          }
          SpacerBetweenElements(8.dp)
          Column(modifier = Modifier.fillMaxSize()) {
            Row {
              DebouncedTextFieldCustomInputField(
                  modifier = Modifier.weight(1f),
                  label = "Start Adresse",
                  labelColor = Background_prime,
                  placeholder = "Start-Straße 123",
                  singleLine = true,
                  value = mapViewModel.startAddress,
                  backgroundColor = Background_prime,
                  status = {
                    if (mapViewModel.startCoordinates != null) {
                      TextFieldStatus.done
                    } else {
                      TextFieldStatus.pending
                    }
                  },
                  onValueChange = {
                    mapViewModel.startAddress = it
                    createSpecialRideViewModel.startAddress = it
                  },
                  onDebouncedChange = {
                    if (mapViewModel.startAddress.isNotEmpty()) {
                      mapViewModel.fetchStartCoordinates()
                    } else {
                      mapViewModel.startCoordinates = null
                    }
                  })
              SpacerBetweenElements(8.dp)
              DebouncedTextFieldCustomInputField(
                  modifier = Modifier.weight(1f),
                  label = "Ziel Adresse",
                  labelColor = Background_prime,
                  placeholder = "Ziel-Straße 123",
                  singleLine = true,
                  value = mapViewModel.destinationAddress,
                  backgroundColor = Background_prime,
                  status = {
                    if (mapViewModel.startCoordinates != null) {
                      TextFieldStatus.done
                    } else {
                      TextFieldStatus.pending
                    }
                  },
                  onValueChange = {
                    mapViewModel.destinationAddress = it
                    createSpecialRideViewModel.destinationAddress = it
                  },
                  onDebouncedChange = {
                    if (mapViewModel.destinationAddress.isNotEmpty()) {
                      mapViewModel.fetchDestinationCoordinates()
                    } else {
                      mapViewModel.destinationCoordinates = null
                    }
                  })
              LaunchedEffect(mapViewModel.startCoordinates, mapViewModel.destinationCoordinates) {
                createSpecialRideViewModel.startLatitude = mapViewModel.startCoordinates?.latitude?.toFloat()
                createSpecialRideViewModel.startLongitude = mapViewModel.startCoordinates?.longitude?.toFloat()
              }
              LaunchedEffect(mapViewModel.destinationCoordinates) {
                createSpecialRideViewModel.destinationLatitude = mapViewModel.destinationCoordinates?.latitude?.toFloat()
                createSpecialRideViewModel.destinationLongitude = mapViewModel.destinationCoordinates?.longitude?.toFloat()
              }
            }
            SpacerBetweenElements(16.dp)
            if (mapViewModel.currentLocation != null){
              MapDynamicTwoMarker(
                modifier = Modifier.padding(bottom = 38.dp),
                markerPositionStart = mapViewModel.startCoordinates,
                markerPositionEnd = mapViewModel.destinationCoordinates,
                currentLocation = mapViewModel.currentLocation!!
              )
            }
          }
        }
        Column(
            modifier =
                Modifier.fillMaxWidth()
                    .weight(1f)
                    .background(Background_prime)
                    .customRoundedTop(Background_prime, heightPercent = 40, widthPercent = 30)
                    .padding(18.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Bottom) {
              val coroutineScope = rememberCoroutineScope()
              val context = LocalContext.current
              Button(
                  modifier = Modifier.fillMaxWidth(),
                  onClick = {
                    coroutineScope.launch {
                      pagerState.animateScrollToPage(pagerState.currentPage - 1)
                    }
                  },
                  colors =
                      ButtonDefaults.buttonColors(
                          containerColor = Color.Transparent, contentColor = Primary)) {
                    if (createSpecialRideViewModel.done) {
                      Text(text = "Zurück", style = TextStyles.contentStyle, color = Primary)
                    }
                  }
              Button(
                  modifier = Modifier.fillMaxWidth(),
                  onClick = {
                    Log.i("CreateRide03Page", "onClick: ${createSpecialRideViewModel.startLatitude}, ${createSpecialRideViewModel.startLongitude}, ${createSpecialRideViewModel.destinationLatitude}, ${createSpecialRideViewModel.destinationLongitude}")
                    if (createSpecialRideViewModel.starts != null &&
                        createSpecialRideViewModel.ends != null &&
                        createSpecialRideViewModel.startLatitude != null &&
                        createSpecialRideViewModel.startLongitude != null &&
                        createSpecialRideViewModel.destinationLatitude != null &&
                        createSpecialRideViewModel.destinationLongitude != null) {
                      coroutineScope.launch {
                        pagerState.animateScrollToPage(pagerState.currentPage + 1)
                      }
                    } else {
                      Toast.makeText(
                              context, "Bitte füllen Sie alle Felder aus.", Toast.LENGTH_SHORT)
                          .show()
                    }
                  },
                  colors =
                      ButtonDefaults.buttonColors(
                          containerColor = Primary, contentColor = Background_prime)) {
                    Text(text = "Weiter", style = TextStyles.contentStyle, color = Text_prime_light)
                  }
            }
      }
}
