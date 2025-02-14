// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.pages

sealed class Screen(val rout: String) {
  // Routen für den NavContoller
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

  object Event : Screen("events/mockEvent")

  object Posters : Screen("posters")

  object Poster : Screen("poster/{posterID}")

  object PosterDetail : Screen("posterDetail/{posterID}")

  object Voting : Screen("abstimmung/{votingID}")

  object Vote : Screen("abstimmen/{votingID}")

  object Voted : Screen("abgestimmt/{votingID}")

  object Poll : Screen("umfrage")

  object PollList : Screen("umfragen")

  object PollResult : Screen("umfrageErgebnis")

  object PollCreate : Screen("umfrageErstellen")

  object PollOnHold : Screen("umfrageAbgestimmt")
}
