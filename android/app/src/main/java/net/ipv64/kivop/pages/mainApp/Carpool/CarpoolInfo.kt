package net.ipv64.kivop.pages.mainApp.Carpool

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.kivopandriod.components.CallToConfirmRideRequest
import kotlinx.coroutines.launch
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.DebouncedTextFieldCustomInputField
import net.ipv64.kivop.components.IconBox
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.ButtonStyle
import net.ipv64.kivop.models.neutralButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.CarpoolViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun CarpoolInfo(navController: NavController,carpoolViewModel: CarpoolViewModel) {
  val carpool = carpoolViewModel.carpool
  Column {
    if (carpoolViewModel.startAddress != null && carpoolViewModel.destinationAddress != null) {
      Box() {
        Column {
          Text(
            text = "Start",
            style = MaterialTheme.typography.headlineSmall,
            color = Text_prime
          )
          SpacerBetweenElements(8.dp)
          Row(verticalAlignment = Alignment.CenterVertically) {
            IconBox(
              icon = ImageVector.vectorResource(R.drawable.ic_place),
              backgroundColor = Tertiary.copy(0.20f),
              tint = Tertiary,
              height = 50.dp
            )
            SpacerBetweenElements(8.dp)
            Column {
              Text(
                text = carpoolViewModel.startAddress!!.road + " " + carpoolViewModel.startAddress!!.houseNumber,
                style = MaterialTheme.typography.bodyMedium,
                color = Text_prime
              )
              Text(
                text = carpoolViewModel.startAddress!!.postcode + " " + carpoolViewModel.startAddress!!.city,
                style = MaterialTheme.typography.bodyMedium,
                color = Text_prime.copy(0.6f)
              )
            }
          }
        }
      }
      SpacerBetweenElements()
      Box() {
        Column {
          Text(
            text = "Ziel",
            style = MaterialTheme.typography.headlineSmall,
            color = Text_prime
          )
          SpacerBetweenElements(8.dp)
          Row(verticalAlignment = Alignment.CenterVertically) {
            IconBox(
              icon = ImageVector.vectorResource(R.drawable.ic_flag),
              backgroundColor = Tertiary.copy(0.20f),
              tint = Tertiary,
              height = 50.dp
            )
            SpacerBetweenElements(8.dp)
            Column {
              Text(
                text = carpoolViewModel.destinationAddress!!.road + " " + carpoolViewModel.destinationAddress!!.houseNumber,
                style = MaterialTheme.typography.bodyMedium,
                color = Text_prime
              )
              Text(
                text = carpoolViewModel.destinationAddress!!.postcode + " " + carpoolViewModel.destinationAddress!!.city,
                style = MaterialTheme.typography.bodyMedium,
                color = Text_prime.copy(0.6f)
              )
            }
          }
        }
      }
      SpacerBetweenElements()
      carpool?.description?.let {
      Box(
        modifier =
        Modifier
          .fillMaxWidth()
          .customShadow()
          .background(Background_secondary, shape = RoundedCornerShape(8.dp))
          .padding(vertical = 12.dp, horizontal = 16.dp)
      ) {
        
        Column {
          Text(
            text = "Beschreibung",
            style = MaterialTheme.typography.headlineSmall,
            color = Text_prime
          )
          SpacerBetweenElements(6.dp)
          Text(
            text = it,
            style = MaterialTheme.typography.bodyMedium,
            color = Text_prime
          )
          }
        }
      }
    }
  }
}

