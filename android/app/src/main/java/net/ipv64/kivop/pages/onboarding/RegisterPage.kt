package net.ipv64.kivop.pages.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.components.ImgPicker
import net.ipv64.kivop.services.uriToByteArray
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun RegisterPage(navController: NavController) {
  var imgByteArray: ByteArray? = null
  var name by remember { mutableStateOf("") }
  var email by remember { mutableStateOf("") }
  var password by remember { mutableStateOf("") }
  var confirmPassword by remember { mutableStateOf("") }

  Column(modifier = Modifier.fillMaxWidth().background(Color.Green)) {
    Column(
        modifier = Modifier.fillMaxWidth().weight(2f).background(Primary).padding(18.dp),
        // verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Spacer(modifier = Modifier.height(32.dp))
      Text(
          text = "Konfiguriere dein Profil",
          color = Text_prime_light,
          textAlign = TextAlign.Center,
          style = MaterialTheme.typography.headlineLarge,
      )
      Spacer(modifier = Modifier.height(16.dp))
      imgByteArray = ImgPicker(size = 120.dp)?.let { uriToByteArray(navController.context, it) }
      // Todo: Fix CustomInputField.kt
      CustomInputField(
          label = "Name",
          placeholder = "Max Mustermann",
          value = name,
          onValueChange = { name = it },
      )
      CustomInputField(
          label = "Email",
          placeholder = "Max Mustermann",
          value = email,
          onValueChange = { email = it },
      )
      CustomInputField(
          label = "Passwort",
          placeholder = "Max Mustermann",
          value = password,
          onValueChange = { password = it },
          isPasswort = true,
      )
      CustomInputField(
          label = "Passwort wiederholen",
          placeholder = "Max Mustermann",
          value = confirmPassword,
          onValueChange = { confirmPassword = it },
          isPasswort = true,
      )
    }
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .weight(0.4f)
                .customRoundedTop(Background_prime, heightPercent = 40, widthPercent = 30)
                .background(Background_prime)
                .padding(18.dp)) {
          Spacer(modifier = Modifier.weight(1f))
          Button(
              modifier = Modifier.fillMaxWidth(),
              colors =
                  ButtonDefaults.buttonColors(
                      containerColor = Color.Transparent, contentColor = Signal_blue),
              onClick = { navController.navigate(OnboardingScreen.Login.rout) }) {
                Text(
                    text = "Anmelden",
                    style = MaterialTheme.typography.labelMedium,
                    textDecoration = TextDecoration.Underline)
              }
          Button(
              modifier = Modifier.fillMaxWidth(),
              colors =
                  ButtonDefaults.buttonColors(
                      containerColor = Signal_blue, contentColor = Text_prime_light),
              onClick = { navController.navigate(OnboardingScreen.Description1.rout) }) {
                Text(text = "Weiter", style = MaterialTheme.typography.labelMedium)
              }
        }
  }
}
