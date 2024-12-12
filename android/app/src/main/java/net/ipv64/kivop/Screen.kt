package net.ipv64.kivop

sealed class Screen(val rout: String) {
  object Home : Screen("home")

  object Sitzungen : Screen("sitzungen")

  object Anwesenheit : Screen("anwesenheit")

  object Response : Screen("response") // TODO: anwesenheit von meeting

  object Protokolle : Screen("protokolle")
}

// routing später anpassen: navController.
// skip screens mit popBackStack
