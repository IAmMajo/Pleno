package net.ipv64.kivop.pages.onboarding

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.NavHostController
import androidx.navigation.compose.composable

@Composable
fun OnboardingNav(navController: NavHostController) {
  NavHost(
    navController = navController,
    startDestination = OnboardingScreen.Welcome.rout,
  ) {
    composable(OnboardingScreen.Welcome.rout) {
      WelcomePage(navController)
    }
    composable(OnboardingScreen.Login.rout) {
      LoginPage(navController)
    }
    composable(OnboardingScreen.Register.rout) {
      RegisterPage(navController)
    }
    composable(OnboardingScreen.Description1.rout) {
      DescriptionOnePage(navController)
    }
    composable(OnboardingScreen.Description2.rout) {
      DescriptionTwoPage(navController)
    }
    composable(OnboardingScreen.AlmostDone.rout) {
      AlmostDonePage(navController)
    }
  }
}
