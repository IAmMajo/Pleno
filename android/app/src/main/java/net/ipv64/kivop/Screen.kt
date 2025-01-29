package net.ipv64.kivop

sealed class Screen(val rout: String) {
  object Home : Screen("home")

  object User : Screen("user")

  object Meetings : Screen("sitzungen")

  object Attendance : Screen("anwesenheit")

  object Protocol : Screen("protokolle")

  object ProtocolDetailPage : Screen("protokolleDetail")

  object ProtocolEditPage : Screen("protokolleEdit")

  object CarpoolingList : Screen("carpoolingList")

  object Carpool : Screen("carpool")

  object CarpoolRiders : Screen("carpoolRiders")

  object CreateCarpool : Screen("createCarpool")

  object Events : Screen("events")

  object Poster : Screen("poster")

  object Votings : Screen("abstimmungen") // todo remove

  object Voting : Screen("abstimmung/{votingID}")

  object Vote : Screen("abstimmen/{votingID}")

  object Voted : Screen("abgestimmt/{votingID}")

  object Poll : Screen("umfrage")
}

// routing später anpassen: navController.
// skip screens mit popBackStack
