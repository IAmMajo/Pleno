package net.ipv64.kivop.pages.LoginOnboarding

import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navDeepLink

@Composable
fun OnboardingNav(
    navController: NavHostController,
    needsActivation: Boolean = false,
    activationState: Int = 1
) {
  NavHost(
      navController = navController,
      startDestination =
          if (needsActivation) OnboardingScreen.AlmostDone.rout else OnboardingScreen.Start.rout) {
        composable(OnboardingScreen.Start.rout) { StartPage(navController) }
        composable(OnboardingScreen.Login.rout) { LoginPage(navController) }
        composable(OnboardingScreen.Register.rout) { RegisterPage(navController) }
        composable(
            route = OnboardingScreen.AlmostDone.rout,
            deepLinks =
                listOf(
                    navDeepLink {
                      uriPattern = "https://kivop.ipv64.net/auth/email/verify/{id}"
                      action = Intent.ACTION_VIEW
                    })) { backStackEntry ->
              val isFromDeepLink = backStackEntry.arguments?.getString("argName") != null

              AlmostDonePage(navController, activationState)
            }
      }
}
