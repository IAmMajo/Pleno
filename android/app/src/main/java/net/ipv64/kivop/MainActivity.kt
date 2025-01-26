package net.ipv64.kivop

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material3.DrawerState
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.Surface
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.DrawerItem
import net.ipv64.kivop.components.GlobalTopBar
import net.ipv64.kivop.components.ProfileCardSmall
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.drawerItem
import net.ipv64.kivop.models.viewModel.MeetingsViewModel
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.pages.SplashActivity
import net.ipv64.kivop.pages.mainApp.AlreadyVoted
import net.ipv64.kivop.pages.mainApp.AttendancesCoordinationPage
import net.ipv64.kivop.pages.mainApp.AttendancesListPage
import net.ipv64.kivop.pages.mainApp.Carpool.CarpoolPage
import net.ipv64.kivop.pages.mainApp.Carpool.CarpoolingList
import net.ipv64.kivop.pages.mainApp.Carpool.onBoardingCreateRide.CreateRidePage
import net.ipv64.kivop.pages.mainApp.EventsPage
import net.ipv64.kivop.pages.mainApp.HomePage
import net.ipv64.kivop.pages.mainApp.MeetingsListPage
import net.ipv64.kivop.pages.mainApp.PosterPage
import net.ipv64.kivop.pages.mainApp.PostersListPage
import net.ipv64.kivop.pages.mainApp.ProtocolListPage
import net.ipv64.kivop.pages.mainApp.UserPage
import net.ipv64.kivop.pages.mainApp.VotePage
import net.ipv64.kivop.pages.mainApp.VotingResultPage
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.KIVoPAndriodTheme

object BackPressed {
  var isBackPressed: Boolean = false
}

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    setContent {
      KIVoPAndriodTheme {
        val navController: NavHostController = rememberNavController()
        val userViewModel = viewModel<UserViewModel>()
        LaunchedEffect(Unit) {
          userViewModel.fetchUser()
          Log.i("nav", navController.graph.toString())
        }

        // A surface container using the 'background' color from the theme
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = Background_prime,
        ) {
          NavBar(navController, userViewModel)
        }
      }
    }
  }
}

fun handleLogout(context: Context) {
  val auth = AuthController(context)
  auth.logout()

  val intent = Intent(context, SplashActivity::class.java)
  context.startActivity(intent)
  (context as? ComponentActivity)?.finish()
}

// TODO - Navigation anpassen name anpassen
@Composable
fun navigation(navController: NavHostController, userViewModel: UserViewModel) {

  val meetingsViewModel = viewModel<MeetingsViewModel>()

  LaunchedEffect(Unit) { meetingsViewModel.fetchMeetings() }

  NavHost(
      navController = navController,
      startDestination = Screen.Home.rout,
      modifier = Modifier.fillMaxWidth().zIndex(-1f),
      enterTransition = { slideInHorizontally(initialOffsetX = { it }) },
      exitTransition = { slideOutHorizontally(targetOffsetX = { -it }) },
      popEnterTransition = { slideInHorizontally(initialOffsetX = { -it }) },
      popExitTransition = { slideOutHorizontally(targetOffsetX = { it }) }) {

        // StartScreen

        composable(Screen.Home.rout) {
          HomePage(navController = navController, userViewModel, meetingsViewModel)
        }
        // UserPage
        composable(Screen.User.rout) { UserPage(navController = navController, userViewModel) }
        // Sitzungen
        composable(Screen.Meetings.rout) {
          MeetingsListPage(navController = navController, meetingsViewModel)
        }
        // Anwesenheit
        composable(route = Screen.Attendance.rout) {
          AttendancesListPage(navController = navController)
        }
        // Anwesenheit liste
        composable("${Screen.Attendance.rout}/{meetingID}") { backStackEntry ->
          AttendancesCoordinationPage(
              navController, backStackEntry.arguments?.getString("meetingID").orEmpty())
        }
        // Protokolle
        composable(Screen.Protocol.rout) {
          ProtocolListPage(navController = navController, meetingsViewModel)
        }
        //    composable("${Screen.Protocol.rout}/{meetingID}/{protocollang}") { backStackEntry ->
        //      ProtocolListPage(
        //        navController,
        // backStackEntry.arguments?.getString("meetingID").orEmpty(),backStackEntry.arguments?.getString("protocollang").orEmpty())
        //    }
        //     composable(route = Screen.Protocol.rout) { ProtocolListPage(navController =
        // navController) }
        // CarpoolingList
        composable(route = Screen.CarpoolingList.rout) {
          CarpoolingList(navController = navController)
        }
        // Carpool
        composable(route = "${Screen.Carpool.rout}/{carpoolID}") { backStackEntry ->
          CarpoolPage(navController, backStackEntry.arguments?.getString("carpoolID").orEmpty())
        }

        // Create Carpool
        composable(route = Screen.CreateCarpool.rout) {
          CreateRidePage(navController = navController)
        }
        // Events
        composable(route = Screen.Events.rout) { EventsPage(navController = navController) }
        // PostersList
        composable(route = Screen.Posters.rout) { PostersListPage(navController = navController) }
        // Poster
        composable(route = Screen.Poster.rout) { PosterPage(navController = navController) }

        composable("${Screen.Attendance.rout}/{meetingID}") { backStackEntry ->
          AttendancesCoordinationPage(
              navController, backStackEntry.arguments?.getString("meetingID").orEmpty())
        }
        composable(
            route = Screen.Voting.rout,
            arguments =
                listOf(
                    navArgument("votingID") { type = NavType.StringType },
                )) { backStackEntry ->
              val votingID = backStackEntry.arguments?.getString("votingID") ?: ""
              VotingResultPage(navController = navController, votingID = votingID)
            }
        composable(
            route = Screen.Vote.rout,
            arguments =
                listOf(
                    navArgument("votingID") { type = NavType.StringType },
                )) { backStackEntry ->
              val votingID = backStackEntry.arguments?.getString("votingID") ?: ""
              VotePage(navController = navController, votingID = votingID)
            }
        composable(
            route = Screen.Voted.rout,
            arguments =
                listOf(
                    navArgument("votingID") { type = NavType.StringType },
                )) { backStackEntry ->
              val votingID = backStackEntry.arguments?.getString("votingID") ?: ""
              AlreadyVoted(navController = navController, votingID = votingID)
            }
      }
}

@Composable
fun NavBar(navController: NavHostController, userViewModel: UserViewModel) {
  var drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
  val scope = rememberCoroutineScope()

  ModalNavigationDrawer(
      drawerState = drawerState,
      drawerContent = {
        Box(
            modifier =
                Modifier.fillMaxHeight()
                    .width(LocalConfiguration.current.screenWidthDp.dp * 0.75f)
                    .background(Background_prime) // 75% des Bildschirms
            ) {
              DrawerContent(
                  navController,
                  drawerState,
                  userViewModel) // Übergabe des NavControllers an den Drawer
            }
      },
      gesturesEnabled = true // zum swipen des NavDrawers
      ) {
        // Implementierung der TopBar mit Boolean, welcher aus drawerState entnommen wird.
        GlobalTopBar(
            navController,
            onOpenDrawer = {
              scope.launch() {
                // open/close NavDrawer
                drawerState.apply {
                  if (drawerState.isClosed) drawerState.open() else drawerState.close()
                }
              }
            })

        navigation(navController, userViewModel)
      }
}

@Composable
fun DrawerContent(
    navController: NavController,
    drawerState: DrawerState,
    userViewModel: UserViewModel
) {
  val coroutineScope = rememberCoroutineScope()
  val user = userViewModel.getProfile()
  var currentRoute by remember { mutableStateOf(navController.currentDestination?.route) }

  LaunchedEffect(navController) {
    navController.currentBackStackEntryFlow.collect { backStackEntry ->
      currentRoute = backStackEntry.destination.route
    }
  }

  Column(
      modifier = Modifier.padding(top = 60.dp, start = 20.dp, end = 8.dp, bottom = 10.dp),
  ) {
    if (user != null) {
      ProfileCardSmall(
          user.name!!,
          user.profileImage,
          role = "@Verein",
          onClick = {
            coroutineScope.launch { drawerState.close() }
            if (currentRoute != Screen.User.rout) {
              navController.navigate(Screen.User.rout)
            }
          })
    }

    Spacer(modifier = Modifier.height(4.dp))
    val drawerItems =
        listOf(
            drawerItem(
                modifier = Modifier,
                icon = Icons.Rounded.Home,
                title = getString(R.string.meetings),
                route = Screen.Meetings.rout),
            drawerItem(
                modifier = Modifier,
                icon = Icons.Rounded.Home,
                title = getString(R.string.protocol),
                route = Screen.Protocol.rout),
            drawerItem(
                modifier = Modifier,
                icon = Icons.Rounded.Home,
                title = getString(R.string.carpooling),
                route = Screen.CarpoolingList.rout),
            drawerItem(
                modifier = Modifier,
                icon = Icons.Rounded.Home,
                title = getString(R.string.events),
                route = Screen.Events.rout),
            drawerItem(
                modifier = Modifier,
                icon = Icons.Rounded.Home,
                title = getString(R.string.poster),
                route = Screen.Posters.rout),
        )
    drawerItems.forEach { item ->
      DrawerItem(
          item,
          selected = currentRoute == item.route,
          onClick = {
            navController.navigate(item.route) {
              popUpTo(navController.graph.startDestinationId) {
                saveState = true // Save state when navigating back
              }
              launchSingleTop = true
              restoreState = true
            }
            coroutineScope.launch { drawerState.close() }
          })
      SpacerBetweenElements(4.dp)
    }
  }
}
