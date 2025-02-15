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
        var hasCredentials by remember { mutableStateOf<Boolean?>(null) }
        LaunchedEffect(Unit) {
          hasCredentials = auth.hasCredentials()
          if (hasCredentials as Boolean) {
            val response = auth.isActivated()
            if (response == "Successful Login!") {
              navigateToMainActivity(context)
            } else if (response == "Email not verified") {
              navigateToLoginActivity(context, true, 1)
            } else if (response == "This account is inactiv") {
              navigateToLoginActivity(context, true, 2)
            } else {
              auth.logout()
              navigateToLoginActivity(context)
            }
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
  (context as? ComponentActivity)?.finish()
}

private fun navigateToLoginActivity(
    context: Context,
    needsActivation: Boolean = false,
    activationState: Int = 1
) {
  val intent = Intent(context, LoginActivity::class.java)
  intent.putExtra("NEEDS_ACTIVATION", needsActivation)
  intent.putExtra("ACTIVATION_STATE", activationState)
  context.startActivity(intent)
  (context as? ComponentActivity)?.finish()
}
