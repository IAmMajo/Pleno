package com.example.kivopandriod


sealed class Screen(val rout: String) {
    object Login : Screen("login")
    object Home : Screen("home")
    object Sitzungen : Screen("sitzungen")
    object Protokolle : Screen("protokolle")
}

// routing später anpassen: navController.
// skip screens mit popBackStack
