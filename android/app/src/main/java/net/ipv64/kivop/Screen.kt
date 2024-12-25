package net.ipv64.kivop

sealed class Screen(val rout: String) {
  object Home : Screen("home")
  
  object Meetings : Screen("sitzungen")

  object Attendance : Screen("anwesenheit")

  object Protocol : Screen("protokolle")

  object Travel : Screen("travel")
  
  object Events : Screen("events")

  object Poster : Screen("poster")

  object Votings : Screen("abstimmungen") //todo remove

  object Voting : Screen("abstimmung/{votingID}")

  object Vote : Screen("abstimmen/{votingID}")

  object Voted : Screen("abgestimmt/{votingID}")
  
}

// routing später anpassen: navController.
// skip screens mit popBackStack
