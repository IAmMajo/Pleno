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

package net.ipv64.kivop.pages.LoginOnboarding

import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.R
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun AlmostDonePage(navController: NavController, initState: Int) {
  var state by remember { mutableIntStateOf(initState) }
  var scope = rememberCoroutineScope()
  Column(
      modifier = Modifier.fillMaxSize(),
      verticalArrangement = Arrangement.Center,
      horizontalAlignment = Alignment.CenterHorizontally) {
        Box() {
          Icon(
              modifier = Modifier.size(200.dp),
              painter = painterResource(id = R.drawable.ic_clock),
              contentDescription = "Clock Icon",
              tint = Text_prime)
        }
        if (state == 1) {
          Text("Bitte bestätige deine E-Mail Adresse.")
          Text(
              "Und warten Sie auf die Freischaltung durch den Administrator.",
              textAlign = TextAlign.Center)
          Button(onClick = { scope.launch { getNewVerificationEmail() } }) {
            Text("Neue Email senden")
          }
          Button(
              onClick = {
                scope.launch {
                  val response = checkActiv()
                  if (response == "Successful Login!") {
                    navigateToMainActivity(navController.context)
                  } else if (response == "Email not verified") {
                    Toast.makeText(
                            navController.context,
                            getString(R.string.missing_email_verification),
                            Toast.LENGTH_SHORT)
                        .show()
                  } else {
                    Toast.makeText(
                            navController.context,
                            getString(R.string.missing_admin_verification),
                            Toast.LENGTH_SHORT)
                        .show()
                    state = 2
                  }
                }
              }) {
                Text("Bestätigt")
              }
        } else {
          Text(
              "Warten Sie auf die Freischaltung durch den Administrator.",
              textAlign = TextAlign.Center)
          Button(
              onClick = {
                scope.launch {
                  val response = checkActiv()
                  if (response == "Successful Login!") {
                    navigateToMainActivity(navController.context)
                  } else if (response == "Email not verified") {
                    Toast.makeText(
                            navController.context,
                            getString(R.string.missing_email_verification),
                            Toast.LENGTH_SHORT)
                        .show()
                  } else {
                    Toast.makeText(
                            navController.context,
                            getString(R.string.missing_admin_verification),
                            Toast.LENGTH_SHORT)
                        .show()
                  }
                }
              }) {
                Text("Aktualisieren")
              }
        }
      }
}

suspend fun checkActiv(): String? {
  return auth.isActivated()
}

suspend fun getNewVerificationEmail() {
  auth.resendEmail()
}

private fun navigateToMainActivity(context: Context) {
  var appContext = context.applicationContext
  val intent = Intent(appContext, MainActivity::class.java)
  context.startActivity(intent)
  (context as? ComponentActivity)?.finish()
}
