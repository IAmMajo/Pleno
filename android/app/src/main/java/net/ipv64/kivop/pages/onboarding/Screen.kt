package net.ipv64.kivop.pages.onboarding

sealed class OnboardingScreen(val rout: String) {

  object Start : OnboardingScreen("start")
  
  object Welcome : OnboardingScreen("welcome")

  object Description1 : OnboardingScreen("description1")

  object Description2 : OnboardingScreen("description2")

  object AlmostDone : OnboardingScreen("almostdone")

  object Register : OnboardingScreen("register")

  object Login : OnboardingScreen("login")
}
