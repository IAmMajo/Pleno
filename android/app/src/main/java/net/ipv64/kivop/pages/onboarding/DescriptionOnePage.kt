package net.ipv64.kivop.pages.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.navigation.NavController
import net.ipv64.kivop.ui.customRoundedBottom
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun DescriptionOnePage(navController: NavController) {
  Column(modifier = Modifier.fillMaxWidth().background(Color.Green)) {
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
      Box(modifier = Modifier.height(250.dp).aspectRatio(1f).background(Color.Red)) {
        // Box for image
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
          text = "Mit Pleno \n zu einer verbesserten \nVereinsplannung",
          color = Text_prime_light,
          textAlign = TextAlign.Center,
          style = MaterialTheme.typography.headlineLarge,
      )
      // Todo: Temp Button! Wie geht es weiter?
      Button(onClick = { navController.navigate(OnboardingScreen.Description2.rout) }) {
        Text(text = "Weiter")
      }
    }
  }
}
