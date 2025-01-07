package net.ipv64.kivop.pages.onboarding

import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.activity.ComponentActivity
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun LoginPage(navController: NavController) {
  var email by remember { mutableStateOf("") }
  var password by remember { mutableStateOf("") }

  var scope = rememberCoroutineScope()

  Column(modifier = Modifier.fillMaxWidth().background(Color.Green)) {
    Column(
        modifier = Modifier.fillMaxWidth().weight(2f).background(Primary).padding(18.dp),
        // verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Spacer(modifier = Modifier.height(32.dp))
      Text(
          text = "Melde dich an",
          color = Text_prime_light,
          textAlign = TextAlign.Center,
          style = MaterialTheme.typography.headlineLarge,
      )
      Spacer(modifier = Modifier.height(16.dp))
      // Todo: Fix CustomInputField.kt
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
              onClick = { navController.navigate(OnboardingScreen.Register.rout) }) {
                Text(
                    text = "Regestrieren",
                    style = MaterialTheme.typography.labelMedium,
                    textDecoration = TextDecoration.Underline)
              }
          Button(
              modifier = Modifier.fillMaxWidth(),
              colors =
                  ButtonDefaults.buttonColors(
                      containerColor = Signal_blue, contentColor = Text_prime_light),
              onClick = {
                scope.launch {
                  val response = handleLogin(email.lowercase(), password)
                  if (response === "Successful Login!") {
                    navigateToMainActivity(navController.context)
                  } else if (response === "This account is inactiv") {
                    navController.navigate(OnboardingScreen.AlmostDone.rout)
                  } else{
                    Toast.makeText(navController.context, "Login failed", Toast.LENGTH_SHORT).show()
                  }
                }
              }) {
                Text(text = "Bestätigen", style = MaterialTheme.typography.labelMedium)
              }
        }
  }
}

private suspend fun handleLogin(email: String, password: String): String? {
  return auth.login(email, password)
}

private fun navigateToMainActivity(context: Context) {
  var appContext = context.applicationContext
  val intent = Intent(appContext, MainActivity::class.java)
  context.startActivity(intent)
  (context as? ComponentActivity)?.finish()
}
