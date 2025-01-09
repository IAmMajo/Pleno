package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.IconBox
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.CarpoolViewModel
import net.ipv64.kivop.models.viewModel.CarpoolViewModelFactory
import net.ipv64.kivop.models.viewModel.CarpoolingListViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import java.util.UUID

@Composable
fun CarpoolPage(
  navController: NavController?, 
  carpoolID: String,
  carpoolViewModel: CarpoolViewModel = viewModel(
    factory = CarpoolViewModelFactory(carpoolID)
  )
) {
  val carpool = carpoolViewModel.Carpool
  BackHandler {
    if (navController != null) {
      isBackPressed = navController.popBackStack()
    }
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  Column(modifier = Modifier.background(Primary)) {
    SpacerTopBar()

    Column(
      modifier = Modifier.weight(1f).padding(horizontal = 18.dp)
    ) {
      if (carpool != null){
        Text(text = carpool.name, style = MaterialTheme.typography.headlineMedium, color = Text_prime_light)
      }
    }
    Column(
      modifier = Modifier
        .weight(3f)
        .fillMaxWidth()
        .fillMaxHeight()
        .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
        .background(Background_prime)
        .padding(18.dp)
    ){
      if (carpool != null) {
        Box(

        ) {
          Column {
            Text(text = "Start", style = MaterialTheme.typography.headlineSmall, color = Text_prime)
            SpacerBetweenElements(8.dp)
            Row(
              verticalAlignment = Alignment.CenterVertically
            ) {
              IconBox(
                icon = ImageVector.vectorResource(R.drawable.ic_place),
                backgroundColor = Tertiary.copy(0.20f),
                tint = Tertiary,
                height = 50.dp
              )
              SpacerBetweenElements(8.dp)
              Column {
                Text(
                  text = "Straße und Hausnummer",
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime
                )
                Text(
                  text = "Postleitzahl und Ort",
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime.copy(0.6f)
                )
              }
            }
          }
        }
        SpacerBetweenElements()
        Box(

        ) {
          Column {
            Text(text = "Ziel", style = MaterialTheme.typography.headlineSmall, color = Text_prime)
            SpacerBetweenElements(8.dp)
            Row(
              verticalAlignment = Alignment.CenterVertically
            ) {
              IconBox(
                icon = ImageVector.vectorResource(R.drawable.ic_flag),
                backgroundColor = Tertiary.copy(0.20f),
                tint = Tertiary,
                height = 50.dp
              )
              SpacerBetweenElements(8.dp)
              Column {
                Text(
                  text = "Straße und Hausnummer",
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime
                )
                Text(
                  text = "Postleitzahl und Ort",
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime.copy(0.6f)
                )
              }
            }
          }
        }
        SpacerBetweenElements()
        Box(
          modifier = Modifier
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
              text = carpool.description,
              style = MaterialTheme.typography.bodyMedium,
              color = Text_prime
            )
          }
        }
      }
    }
  }
}
