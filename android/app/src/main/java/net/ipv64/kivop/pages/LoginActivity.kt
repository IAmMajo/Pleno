package net.ipv64.kivop.pages

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat.startActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.ui.theme.Background_light
import net.ipv64.kivop.ui.theme.KIVoPAndriodTheme
import net.ipv64.kivop.ui.theme.Primary_dark
import net.ipv64.kivop.ui.theme.Text_light

var coroutineScope = CoroutineScope(Dispatchers.IO)

class LoginActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val context: Context = this
    setContent {
      KIVoPAndriodTheme {
        // A surface container using the 'background' color from the theme
        Surface(
          modifier = Modifier.fillMaxSize(),
          color = Color(0xfffafaee), // TODO - Android Background Light)
        ) {
            LoginScreen(context)
        }
      }
    }
  }
}


@Composable
fun LoginScreen(context: Context) {
  var isLoggedIn by remember { mutableStateOf<Boolean?>(null) }
  val auth = AuthController(context)
  LaunchedEffect(Unit) {
    isLoggedIn = auth.isLoggedIn()
    if (isLoggedIn == true) {
      navigateToMainActivity(context)
    }
  }
  if (isLoggedIn == false) {
    Column(
      modifier = Modifier
        .background(color = Background_light)
        .padding(12.dp),
      horizontalAlignment = Alignment.CenterHorizontally
    ) {
      // TODO: CHANGE LOGIN PAGE!!!
      val annotatedString = buildAnnotatedString {
        append("Log dich in deinen ")
        withStyle(style = SpanStyle(color = Primary_dark)) { append("Account") }
        append(" ein!")
      }
      Text(
        text = annotatedString,
        fontSize = 24.sp,
        color = Text_light,
        fontWeight = FontWeight.Bold
      )
      Column(
        modifier = Modifier.fillMaxHeight(),
        verticalArrangement = Arrangement.Center,
      ) {
        var username by remember { mutableStateOf("") }
        CustomInputField(
          label = "Username",
          placeholder = "Enter your username",
          horizontalPadding = 0.dp,
          verticalPadding = 0.dp,
          value = username,
          onValueChange = { username = it })
        Spacer(Modifier.size(12.dp))
        var password by remember { mutableStateOf("") }
        CustomInputField(
          label = "Passwort",
          placeholder = "Enter your passwort",
          isPasswort = true,
          horizontalPadding = 0.dp,
          verticalPadding = 0.dp,
          value = password,
          onValueChange = { password = it })
        Spacer(Modifier.size(12.dp))
        CustomButton(
          text = "Login",
          onClick = {
            coroutineScope.launch {
              // Todo: use email and password val
              if (handleLogin(context, username, password)) {
                navigateToMainActivity(context)
              } else {
                try {
                  withContext(Dispatchers.Main) {
                    Toast.makeText(
                      context,
                      "Login failed. Please check your credentials.",
                      Toast.LENGTH_SHORT
                    ).show()
                  }
                } catch (e: Exception) {
                  Log.e("Login", "Error showing toast: $e")
                }

              }
            }
          },
          color = Primary_dark,
          fontColor = Text_light
        )
      }
    }
  }
}

private suspend fun handleLogin(context: Context,email: String, password: String): Boolean {
  val auth = AuthController(context)
  return auth.login(email,password)
}

private fun navigateToMainActivity(context: Context) {
  val intent = Intent(context, MainActivity::class.java)
  context.startActivity(intent)
}
