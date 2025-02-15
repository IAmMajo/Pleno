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

package net.ipv64.kivop.pages.LoginOnboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import net.ipv64.kivop.R
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.ui.customRoundedBottom
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun DescriptionOnePage() {
  Column(modifier = Modifier.background(Color.Green)) {
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .weight(1.5f)
                .background(Background_prime)
                .zIndex(2f)
                .customRoundedBottom(Background_prime, heightPercent = 40, widthPercent = 30),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Spacer(modifier = Modifier.weight(1f))
      Box(modifier = Modifier.height(250.dp).aspectRatio(1f)) {
        Image(
            painter = painterResource(id = R.drawable.onboardingscreen1),
            contentDescription = "Onboarding Screen 1",
            modifier = Modifier.fillMaxWidth().aspectRatio(1f))
      }
      Spacer(modifier = Modifier.height(16.dp))
      Box(modifier = Modifier.weight(1f)) {
        // Box for Text
      }
      Spacer(modifier = Modifier.weight(1f))
    }
    Column(
        modifier = Modifier.fillMaxWidth().weight(1f).background(Primary).padding(18.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Text(
          text = getString(R.string.description_one),
          color = Text_prime_light,
          textAlign = TextAlign.Center,
          style = MaterialTheme.typography.headlineLarge,
      )
    }
  }
}
