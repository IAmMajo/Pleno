package net.ipv64.kivop.pages.onboarding

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.navigation.compose.rememberNavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.KIVoPAndriodTheme

class LoginActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    //Defines where the navigation should start
    val needsActivation = intent.getBooleanExtra("NEEDS_ACTIVATION", true)
    val activationState = intent.getIntExtra("ACTIVATION_STATE", 1)
    setContent {
      val navController = rememberNavController()
      

      KIVoPAndriodTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = Background_prime,
        ) {
          OnboardingNav(navController = navController, needsActivation, activationState)
        }
      }
    }
  }
}


