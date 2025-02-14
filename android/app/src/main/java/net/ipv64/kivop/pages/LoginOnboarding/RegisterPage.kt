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

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
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
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.components.ImgPicker
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserRegistrationDTO
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.uriToBase64String
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun RegisterPage(navController: NavController) {
  var imgByteArray: String? = null
  var name by remember { mutableStateOf("") }
  var email by remember { mutableStateOf("") }
  var password by remember { mutableStateOf("") }
  var confirmPassword by remember { mutableStateOf("") }

  val focusRequester1 = remember { FocusRequester() }
  val focusRequester2 = remember { FocusRequester() }
  val focusRequester3 = remember { FocusRequester() }
  val focusRequester4 = remember { FocusRequester() }

  val scope = rememberCoroutineScope()

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
      ImgPicker(
          size = 120.dp,
          onImagePicked = { uri ->
            if (uri != null) {
              uriToBase64String(navController.context, uri)
            }
          })

      CustomInputField(
          label = "Name",
          placeholder = "Max Mustermann",
          value = name,
          onValueChange = { name = it },
          focusRequester = focusRequester1,
          nextFocusRequester = focusRequester2 // Fokus auf das nächste Feld setzen
          )

      CustomInputField(
          label = "Email",
          placeholder = "Max@pleno.net",
          value = email,
          onValueChange = { email = it },
          focusRequester = focusRequester2,
          nextFocusRequester = focusRequester3)

      CustomInputField(
          label = "Passwort",
          placeholder = "******",
          value = password,
          onValueChange = { password = it },
          isPasswort = true,
          focusRequester = focusRequester3,
          nextFocusRequester = focusRequester4)

      CustomInputField(
          label = "Passwort wiederholen",
          placeholder = "******",
          value = confirmPassword,
          onValueChange = { confirmPassword = it },
          isPasswort = true,
          focusRequester = focusRequester4)
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
              onClick = {
                val user = UserRegistrationDTO(name, email.lowercase(), password, imgByteArray)
                scope.launch {
                  if (user.name != null && user.email != null && user.password != null) {
                    if (handleRegister(user)) {
                      navController.navigate(OnboardingScreen.AlmostDone.rout)
                    }
                  }
                }
              }) {
                Text(text = "Weiter", style = MaterialTheme.typography.labelMedium)
              }
        }
  }
}

private suspend fun handleRegister(user: UserRegistrationDTO): Boolean {
  return auth.register(user)
}
