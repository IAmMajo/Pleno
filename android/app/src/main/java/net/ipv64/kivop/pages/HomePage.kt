package net.ipv64.kivop.pages

import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import net.ipv64.kivop.handleLogout
import net.ipv64.kivop.services.AuthController

@Composable
fun HomePage(navController: NavController) {
  //Text(text = "home")
  Button(onClick = {
    handleLogout(navController.context)
  }){}
}
