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

package net.ipv64.kivop.pages.mainApp.Carpool

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.R
import net.ipv64.kivop.components.IconBox
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.viewModel.CarpoolViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun CarpoolInfo(navController: NavController, carpoolViewModel: CarpoolViewModel) {
  val carpool = carpoolViewModel.carpool
  Column {
    if (carpoolViewModel.startAddress != null && carpoolViewModel.destinationAddress != null) {
      Box() {
        Column {
          Text(text = "Start", style = MaterialTheme.typography.headlineSmall, color = Text_prime)
          SpacerBetweenElements(8.dp)
          Row(verticalAlignment = Alignment.CenterVertically) {
            IconBox(
                icon = ImageVector.vectorResource(R.drawable.ic_place),
                backgroundColor = Tertiary.copy(0.20f),
                tint = Tertiary,
                height = 50.dp)
            SpacerBetweenElements(8.dp)
            Column {
              Text(
                  text =
                      carpoolViewModel.startAddress!!.road +
                          " " +
                          carpoolViewModel.startAddress!!.houseNumber,
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime)
              Text(
                  text =
                      carpoolViewModel.startAddress!!.postcode +
                          " " +
                          carpoolViewModel.startAddress!!.city,
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime.copy(0.6f))
            }
          }
        }
      }
      SpacerBetweenElements()
      Box() {
        Column {
          Text(text = "Ziel", style = MaterialTheme.typography.headlineSmall, color = Text_prime)
          SpacerBetweenElements(8.dp)
          Row(verticalAlignment = Alignment.CenterVertically) {
            IconBox(
                icon = ImageVector.vectorResource(R.drawable.ic_flag),
                backgroundColor = Tertiary.copy(0.20f),
                tint = Tertiary,
                height = 50.dp)
            SpacerBetweenElements(8.dp)
            Column {
              Text(
                  text =
                      carpoolViewModel.destinationAddress!!.road +
                          " " +
                          carpoolViewModel.destinationAddress!!.houseNumber,
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime)
              Text(
                  text =
                      carpoolViewModel.destinationAddress!!.postcode +
                          " " +
                          carpoolViewModel.destinationAddress!!.city,
                  style = MaterialTheme.typography.bodyMedium,
                  color = Text_prime.copy(0.6f))
            }
          }
        }
      }
      SpacerBetweenElements()
      carpool?.description?.let {
        Box(
            modifier =
                Modifier.fillMaxWidth()
                    .customShadow()
                    .background(Background_secondary, shape = RoundedCornerShape(8.dp))
                    .padding(vertical = 12.dp, horizontal = 16.dp)) {
              Column {
                Text(
                    text = "Beschreibung",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Text_prime)
                SpacerBetweenElements(6.dp)
                Text(text = it, style = MaterialTheme.typography.bodyMedium, color = Text_prime)
              }
            }
      }
    }
  }
}
