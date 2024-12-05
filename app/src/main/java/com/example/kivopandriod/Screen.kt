package com.example.kivopandriod


sealed class Screen(val rout: String) {
    object Login : Screen("login")
    object Home : Screen("home")
    object Sitzungen : Screen("sitzungen")
    object Anwesenheit : Screen("anwesenheit")
    object Protokolle : Screen("protokolle")
    object Abstimmungen : Screen("abstimmungen")

}

// routing später anpassen: navController.
// skip screens mit popBackStack
