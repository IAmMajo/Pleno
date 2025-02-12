package net.ipv64.kivop.pages.mainApp.Carpool

import android.util.Log
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.example.kivopandriod.components.CallToConfirmRideRequest
import com.google.android.gms.maps.model.LatLng
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.DebouncedTextFieldCustomInputField
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.MapDoubleMarker
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.ButtonStyle
import net.ipv64.kivop.models.neutralButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.CarpoolViewModel
import net.ipv64.kivop.models.viewModel.CarpoolViewModelFactory
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CarpoolPage(
    navController: NavController,
    carpoolID: String,
    carpoolViewModel: CarpoolViewModel = viewModel(factory = CarpoolViewModelFactory(carpoolID))
) {
  val carpool = carpoolViewModel.carpool
  var callToConfirmation by remember { mutableStateOf(false) }
  var page by remember { mutableIntStateOf(0) }
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  Column(modifier = Modifier.background(Primary)) {
    SpacerTopBar()
    // header Column
    Column(modifier = Modifier.weight(1f).padding(horizontal = 18.dp)) {
      if (carpool != null) {
        Text(
            text = carpool.name,
            style = MaterialTheme.typography.headlineMedium,
            color = Text_prime_light)
        val latLngStart = LatLng(carpool.startLatitude.toDouble(), carpool.startLongitude.toDouble())
        val latLngEnd = LatLng(carpool.destinationLatitude.toDouble(), carpool.destinationLongitude.toDouble())
        MapDoubleMarker(Modifier.padding(vertical = 12.dp),latLngStart, latLngEnd)
      }
    }
    // content Column
    Column(
        modifier =
            Modifier.weight(3f)
                .fillMaxWidth()
                .fillMaxHeight()
                .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                .background(Background_prime)
                .padding(18.dp)) {
          when (page) {
            0 -> CarpoolInfo(navController, carpoolViewModel)
            1 -> CarpoolRiders(navController, carpoolViewModel)
          }
          Spacer(modifier = Modifier.weight(1f))
          if (carpool != null) {
            if (carpool.isSelfDriver) {
              when (page) {
                0 -> {
                  CustomButton(
                      modifier = Modifier,
                      text = "Mitfahrerliste",
                      buttonStyle = primaryButtonStyle,
                      onClick = { page = 1 })
                }
                1 -> {
                  CustomButton(
                      modifier = Modifier,
                      text = "Zurück",
                      buttonStyle = primaryButtonStyle,
                      onClick = { page = 0 })
                }
              }
            } else {
              val buttonStyle: ButtonStyle =
                  if (carpoolViewModel.me != null) {
                    neutralButtonStyle
                  } else {
                    primaryButtonStyle
                  }
              val buttonText: String =
                  if (carpoolViewModel.me != null) {
                    if (carpoolViewModel.me?.accepted != true) {
                      "Ausstehend"
                    } else {
                      "Bestätigt"
                    }
                  } else {
                    "Anfragen"
                  }
              CustomButton(
                  modifier = Modifier,
                  text = buttonText,
                  buttonStyle = buttonStyle,
                  onClick = { callToConfirmation = true },
                  enabled = carpoolViewModel.me == null)
            }
          }
        }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    when {
      callToConfirmation -> {
        CallToConfirmRideRequest(
            onDismissRequest = { callToConfirmation = false },
            onConfirmation = {
              scope.launch {
                if (carpoolViewModel.postRequest() == true) {
                  Toast.makeText(context, "Anfrage gesendet", Toast.LENGTH_SHORT).show()
                  callToConfirmation = false
                } else {
                  Toast.makeText(context, "Fehler beim Senden der Anfrage", Toast.LENGTH_SHORT)
                      .show()
                }
              }
            },
            dialogTitle = "Anfrage bestätigen",
            dialogText = "Zum bestätigen, geben Sie bitte ihre abhol adresse ein.",
            buttonOneText = "Anfragen",
            buttonTextDismiss = "Abbrechen",
            enabled = carpoolViewModel.myLocation != null,
            composable = {
              Row(
                  modifier = Modifier.fillMaxWidth(),
                  verticalAlignment = Alignment.CenterVertically) {
                    DebouncedTextFieldCustomInputField(
                        label = "",
                        labelColor = Text_prime,
                        placeholder = "Addresse eingeben..",
                        modifier = Modifier.weight(1f),
                        singleLine = true,
                        value = carpoolViewModel.addressInputField,
                        backgroundColor = Background_secondary,
                        onValueChange = { carpoolViewModel.addressInputField = it },
                        onDebouncedChange = {
                          if (carpoolViewModel.addressInputField.isNotEmpty()) {
                            carpoolViewModel.fetchCoordinates()
                          } else {
                            carpoolViewModel.myLocation = null
                          }
                        })
                    SpacerBetweenElements(8.dp)
                    IconBoxClickable(
                        icon = ImageVector.vectorResource(R.drawable.ic_my_location),
                        backgroundColor = Background_secondary,
                        tint = Text_prime,
                        height = 56.dp,
                        onClick = { carpoolViewModel.fetchCurrentLocation(context) })
                  }
            })
      }
    }
  }
}
