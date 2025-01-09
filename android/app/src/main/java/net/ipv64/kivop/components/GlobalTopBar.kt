package net.ipv64.kivop.components

import android.annotation.SuppressLint
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowLeft
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.Screen
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Text_prime

@SuppressLint("RestrictedApi")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GlobalTopBar(navController: NavController, onOpenDrawer: () -> Unit) {
  val currentBackStackEntry by navController.currentBackStackEntryAsState()
  val currentRoute = currentBackStackEntry?.destination?.route

  LaunchedEffect(currentRoute) { isBackPressed = false }

  val modifier = Modifier.padding(vertical = 12.dp, horizontal = 14.dp).height(48.dp)
  AnimatedContent(
      modifier = Modifier,
      targetState = currentRoute,
      transitionSpec = {
        if (isBackPressed) {
          slideInHorizontally(initialOffsetX = { -it }) togetherWith
              slideOutHorizontally(targetOffsetX = { it })
        } else {
          slideInHorizontally(initialOffsetX = { it }) togetherWith
              slideOutHorizontally(targetOffsetX = { -it })
        }
      },
  ) { route ->
    when (route) {
      Screen.Home.rout -> {
        TopAppBar(
            modifier = modifier,
            colors =
                TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent), // transparente NavBar
            title = {},
            actions = {
              IconBoxClickable(
                  Icons.Default.Menu,
                  height = 50.dp,
                  Background_secondary.copy(alpha = 0.15f),
                  Background_secondary,
                  onClick = { onOpenDrawer() })
            },
            navigationIcon = {
              IconBoxClickable(
                  Icons.Default.Notifications,
                  height = 50.dp,
                  Background_secondary.copy(alpha = 0.15f),
                  Background_secondary,
                  onClick = { onOpenDrawer() })
            })
      }
      Screen.User.rout -> {}
      Screen.CarpoolingList.rout -> {
        TopAppBar(
            modifier = modifier,
            colors =
                TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent), // transparente NavBar
            title = {
              Box(modifier = Modifier.fillMaxSize()) {
                Text(
                    text = "Carpooling",
                    style = MaterialTheme.typography.headlineMedium,
                    modifier = Modifier.align(alignment = Alignment.Center))
              }
            },
            actions = {
              IconBoxClickable(
                  Icons.Default.Menu,
                  height = 50.dp,
                  Color.Transparent,
                  Text_prime,
                  onClick = { onOpenDrawer() })
            },
            navigationIcon = {
              IconBoxClickable(
                  Icons.Default.KeyboardArrowLeft,
                  height = 50.dp,
                  Color.Transparent,
                  Text_prime,
                  onClick = {
                    isBackPressed = true
                    navController.popBackStack()
                  })
            })
      }
      Screen.Carpool.rout -> {
        TopAppBar(
            modifier = modifier,
            colors =
                TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent), // transparente NavBar
            title = {},
            actions = {
              IconBoxClickable(
                  Icons.Default.Menu,
                  height = 50.dp,
                  Background_secondary.copy(alpha = 0.15f),
                  Background_secondary,
                  onClick = { onOpenDrawer() })
            },
            navigationIcon = {
              IconBoxClickable(
                  Icons.Default.Notifications,
                  height = 50.dp,
                  Background_secondary.copy(alpha = 0.15f),
                  Background_secondary,
                  onClick = { onOpenDrawer() })
            })
      }
      else -> {
        TopAppBar(
            modifier = modifier,
            colors =
                TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Transparent), // transparente NavBar
            title = {},
            actions = {
              IconBoxClickable(
                  Icons.Default.Menu,
                  height = 50.dp,
                  Color.Transparent,
                  Text_prime,
                  onClick = { onOpenDrawer() })
            },
            navigationIcon = {
              IconBoxClickable(
                  Icons.Default.KeyboardArrowLeft,
                  height = 50.dp,
                  Color.Transparent,
                  Text_prime,
                  onClick = {
                    isBackPressed = true
                    navController.popBackStack()
                  })
            })
      }
    }
  }
}
