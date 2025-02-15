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

package net.ipv64.kivop.pages.mainApp.Carpool.onBoardingCreateRide

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.PagerState
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.CreateSpecialRideViewModel
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CreateRide02Page(
    pagerState: PagerState,
    createSpecialRideViewModel: CreateSpecialRideViewModel = viewModel()
) {
  val context = LocalContext.current
  val focusRequester1 = remember { FocusRequester() }
  val focusRequester2 = remember { FocusRequester() }
  Column(
      modifier = Modifier.fillMaxWidth().fillMaxHeight().background(Primary),
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center) {
        SpacerTopBar()
        Text(
            text = "Über dein Auto", // TODO: replace text with getString
            style = TextStyles.headingStyle,
            color = Text_prime_light)
        Column(
            modifier = Modifier.fillMaxWidth().weight(4f).background(Primary).padding(18.dp),
            horizontalAlignment = Alignment.CenterHorizontally) {
              CustomInputField(
                  modifier = Modifier,
                  label = "Beschreibe dein Auto",
                  labelColor = Text_prime_light,
                  placeholder = "Beschreibe dein Auto...",
                  backgroundColor = Background_prime,
                  focusRequester = focusRequester1,
                  nextFocusRequester = focusRequester2, // Fokus auf das nächste Feld setzen
                  value = createSpecialRideViewModel.vehicleDescription,
                  onValueChange = { createSpecialRideViewModel.vehicleDescription = it },
                  singleLine = false,
                  lines = 3)
              SpacerBetweenElements()
              CustomInputField(
                  modifier = Modifier,
                  label = "Freie Sitze",
                  labelColor = Text_prime_light,
                  placeholder = "Wieviele Sitze stehen zu verfügung?",
                  focusRequester = focusRequester2,
                  backgroundColor = Background_prime,
                  value =
                      if (createSpecialRideViewModel.emptySeats != null)
                          createSpecialRideViewModel.emptySeats.toString()
                      else "",
                  onValueChange = { text ->
                    if (text.all { it.isDigit() }) {
                      val number = text.toIntOrNull()
                      if (number != null && number in 0..255) {
                        createSpecialRideViewModel.emptySeats = number.toUByte()
                      } else if (number == null) {
                        createSpecialRideViewModel.emptySeats = null
                      } else {

                        Toast.makeText(
                                context,
                                "Bitte geben Sie eine Zahl zwischen 0 und 255 ein.",
                                Toast.LENGTH_SHORT)
                            .show()
                      }
                    }
                  },
                  isNumberOnly = true)
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
                    if (createSpecialRideViewModel.emptySeats != null) {
                      coroutineScope.launch {
                        pagerState.animateScrollToPage(pagerState.currentPage + 1)
                      }
                    } else {
                      Toast.makeText(
                              context, "Bitte geben Sie die freien Sitze an.", Toast.LENGTH_SHORT)
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
