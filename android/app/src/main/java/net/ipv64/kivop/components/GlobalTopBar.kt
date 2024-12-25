package net.ipv64.kivop.components

import android.annotation.SuppressLint
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState
import net.ipv64.kivop.Screen
import net.ipv64.kivop.ui.theme.Background_secondary

@SuppressLint("RestrictedApi")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GlobalTopBar(navController: NavController, onOpenDrawer: () -> Unit) {
  val currentBackStackEntry by navController.currentBackStackEntryAsState()
  val currentRoute = currentBackStackEntry?.destination?.route

  val modifier = Modifier.padding(vertical = 12.dp, horizontal = 14.dp).height(48.dp)

  when (currentRoute) {
    Screen.Home.rout -> {
      TopAppBar(
          modifier = modifier,
          colors =
              TopAppBarDefaults.topAppBarColors(
                  containerColor = Color.Transparent), // transparente NavBar
          title = { Text(text = "test") },
          actions = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          },
          navigationIcon = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          })
    }

    Screen.Poster.rout -> {
      TopAppBar(
          modifier = modifier,
          colors =
              TopAppBarDefaults.topAppBarColors(
                  containerColor = Color.Transparent), // transparente NavBar
          title = { Text(text = "test2") },
          actions = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          },
          navigationIcon = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          })
    }

    Screen.Events.rout -> {
      TopAppBar(
          modifier = modifier,
          colors =
              TopAppBarDefaults.topAppBarColors(
                  containerColor = Color.Transparent), // transparente NavBar
          title = { Text(text = "test3") },
          actions = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          },
          navigationIcon = {
            IconBox(
                Icons.Default.Menu,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = { onOpenDrawer() })
          })
    }

    else -> {}
  }
}
