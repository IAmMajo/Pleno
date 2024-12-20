package net.ipv64.kivop

sealed class Screen(val rout: String) {
  object Home : Screen("home")

  object Sitzungen : Screen("sitzungen")

  object Anwesenheit : Screen("anwesenheit")

  object Protokolle : Screen("protokolle")

  object Abstimmungen : Screen("abstimmungen")

  object Abstimmung : Screen("abstimmung/{votingID}")

  object Abstimmen : Screen("abstimmen/{votingID}")

  object Abgestimmt : Screen("abgestimmt/{votingID}")
}

// routing später anpassen: navController.
// skip screens mit popBackStack
