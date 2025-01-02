package net.ipv64.kivop.pages

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.pages.onboarding.LoginActivity
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary

class SplashActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContent {
      Surface(
          modifier = Modifier.background(Background_prime).fillMaxSize(),
      ) {
        val context = this
        var isLoggedIn by remember { mutableStateOf<Boolean?>(null) }
        LaunchedEffect(Unit) {
          isLoggedIn = auth.isLoggedIn()
          if (isLoggedIn as Boolean) {
            navigateToMainActivity(context)
          } else {
            navigateToLoginActivity(context)
          }
        }
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
          CircularProgressIndicator(
              modifier = Modifier.size(150.dp),
              trackColor = Background_secondary,
              color = Primary,
              strokeWidth = 10.dp,
              strokeCap = androidx.compose.ui.graphics.StrokeCap.Round)
        }
      }
    }
  }
}

private fun navigateToMainActivity(context: Context) {
  val intent = Intent(context, MainActivity::class.java)
  context.startActivity(intent)
}

private fun navigateToLoginActivity(context: Context) {
  val intent = Intent(context, LoginActivity::class.java)
  context.startActivity(intent)
}
