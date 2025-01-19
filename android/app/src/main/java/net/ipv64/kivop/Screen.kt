package net.ipv64.kivop

sealed class Screen(val rout: String) {
  object Home : Screen("home")

  object User : Screen("user")

  object Meetings : Screen("sitzungen")

  object Attendance : Screen("anwesenheit")

  object Protocol : Screen("protokolle")

  object CarpoolingList : Screen("carpoolingList")

  object Carpool : Screen("carpool")

  object Events : Screen("events")

  object Posters : Screen("posters")
  //TODO: add id
  object Poster : Screen("poster")

  object Votings : Screen("abstimmungen") // todo remove

  object Voting : Screen("abstimmung/{votingID}")

  object Vote : Screen("abstimmen/{votingID}")

  object Voted : Screen("abgestimmt/{votingID}")
}

// routing später anpassen: navController.
// skip screens mit popBackStack
