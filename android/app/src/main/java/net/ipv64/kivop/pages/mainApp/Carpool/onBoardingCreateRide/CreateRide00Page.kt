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

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.pager.PagerState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.zIndex
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.customRoundedBottom
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CreateRide00Page(pagerState: PagerState) {
  val coroutineScope = rememberCoroutineScope()
  // Auto-navigation after 5 seconds
  LaunchedEffect(Unit) {
    delay(5000)
    coroutineScope.launch { pagerState.animateScrollToPage(1) }
  }
  Column(
      modifier =
          Modifier.fillMaxWidth().fillMaxHeight().clickable {
            coroutineScope.launch { pagerState.animateScrollToPage(1) }
          }) {
        Column(
            modifier =
                Modifier.fillMaxWidth()
                    .weight(1f)
                    .zIndex(1f)
                    .background(Background_prime)
                    .customRoundedBottom(Background_prime, heightPercent = 40, widthPercent = 30),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center) {
              Image(
                  painter = painterResource(id = R.drawable.createridescreen1),
                  contentDescription = "Onboarding Screen 1",
                  modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            }
        Column(
            modifier = Modifier.fillMaxWidth().weight(1f).background(Primary),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center) {
              Text(
                  text = "Erstelle eine neue Fahrgemeinschaft", // todo: replace text with:
                  // getString(R.string.info_ride_text)
                  style = TextStyles.headingStyle,
                  color = Text_prime_light,
                  textAlign = TextAlign.Center,
              )
            }
      }
}
