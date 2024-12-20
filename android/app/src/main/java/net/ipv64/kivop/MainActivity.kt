package net.ipv64.kivop

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.List
import androidx.compose.material3.DrawerState
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.NavigationDrawerItemDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.kivopandriod.pages.VotingResultPage
import com.example.kivopandriod.pages.VotingsListPage
import kotlinx.coroutines.launch
import net.ipv64.kivop.pages.AlreadyVoted
import net.ipv64.kivop.pages.AttendancesCoordinationPage
import net.ipv64.kivop.pages.AttendancesListPage
import net.ipv64.kivop.pages.HomePage
import net.ipv64.kivop.pages.LoginActivity
import net.ipv64.kivop.pages.MeetingsListPage
import net.ipv64.kivop.pages.ProtocolListPage
import net.ipv64.kivop.pages.VotePage
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.KIVoPAndriodTheme
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.Text_prime

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContent {
      KIVoPAndriodTheme {
        val navController: NavHostController = rememberNavController()
        val currentDestination = navController.currentBackStackEntryAsState().value?.destination?.route
        Log.i("MainActivity", "Current Destination: $currentDestination")
        
        //change Surface color 
        val surfaceColor = when (currentDestination) {
          Screen.Abstimmen.rout -> Primary
          Screen.Abstimmung.rout -> Primary
          else -> Background_prime
        }
        // A surface container using the 'background' color from the theme
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = surfaceColor,
        ) {
          Nav(navController)
        }
      }
    }
  }
}

fun handleLogout(context: Context) {
  val auth = AuthController(context)
  auth.logout()

  val intent = Intent(context, LoginActivity::class.java)
  context.startActivity(intent)
}

// TODO - Navigation anpassen name anpassen
@Composable
fun navigation(navController: NavHostController) {

  NavHost(
    navController = navController,
    startDestination = Screen.Home.rout,
    modifier =
        Modifier.fillMaxWidth().padding(top = 60.dp),
    enterTransition = { slideInHorizontally(initialOffsetX = { it }) },
    exitTransition = { slideOutHorizontally(targetOffsetX = { -it }) },
    popEnterTransition = { slideInHorizontally(initialOffsetX = { -it }) },
    popExitTransition = { slideOutHorizontally(targetOffsetX = { it }) }
  ) {

    // StartScreen

    composable(Screen.Home.rout) { HomePage(navController = navController) }
    // Sitzungen
    composable(Screen.Sitzungen.rout) { MeetingsListPage(navController = navController) }
    // Anwesenheit liste
    composable(route = Screen.Anwesenheit.rout) {
      AttendancesListPage(navController = navController)
    }
    // Anwesenheit
    composable(
        route = Screen.Anwesenheit.rout + "/{meetingID}",
        arguments =
            listOf(
                navArgument("meetingID") { type = NavType.StringType },
            )) { backStackEntry ->
          val meetingID = backStackEntry.arguments?.getString("meetingID") ?: ""
          AttendancesCoordinationPage(navController = navController, meetingId = meetingID)
        }
    // Protokolle
    composable(route = Screen.Protokolle.rout) { ProtocolListPage(navController = navController) }
    // Abstimmungen Listen Page
    composable(route = Screen.Abstimmungen.rout) { VotingsListPage(navController = navController) }
    // Abstimmung Resultat Page
    composable(
        route = Screen.Abstimmung.rout,
        arguments =
            listOf(
                navArgument("votingID") { type = NavType.StringType },
            )) { backStackEntry ->
          val votingID = backStackEntry.arguments?.getString("votingID") ?: ""
          VotingResultPage(navController = navController, votingID = votingID)
        }
    composable(
      route = Screen.Abstimmen.rout,
      arguments =
      listOf(
        navArgument("votingID") { type = NavType.StringType },
      )) { backStackEntry ->
      val votingID = backStackEntry.arguments?.getString("votingID") ?: ""
      VotePage(navController = navController, votingID = votingID)
    }
    composable(
      route = Screen.Abgestimmt.rout,
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
fun Nav(navController: NavHostController, modifier: Modifier = Modifier) {
  var drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
  val scope = rememberCoroutineScope()
  // Berechnung der Breite des Drawers (2/3 Bildschirmbreite)
  val drawerWidth = animateFloatAsState(targetValue = if (drawerState.isOpen) 0.75f else 0f)

  ModalNavigationDrawer(
      drawerState = drawerState,
      drawerContent = {
        Box(
            modifier =
                Modifier.fillMaxHeight()
                    .width(LocalConfiguration.current.screenWidthDp.dp * drawerWidth.value)
                    .background(Color(0xffeeefe3)) // TODO - Android Background Secondary
            ) {
              DrawerContent(navController, drawerState) // Übergabe des NavControllers an den Drawer
            }
      },
      gesturesEnabled = true // zum swipen des NavDrawers
      ) {
        // Implementierung der TopBar mit Boolean, welcher aus drawerState entnommen wird.
        TopBar(
            onOpenDrawer = {
              scope.launch() {
                // open/close NavDrawer
                drawerState.apply {
                  if (drawerState.isClosed) drawerState.open() else drawerState.close()
                }
              }
            })
        navigation(navController)
      }
}

@Composable
fun ScreenContent(modifier: Modifier = Modifier, title: String, navController: NavController) {
  Box(modifier = Modifier.fillMaxSize().padding(16.dp), contentAlignment = Alignment.Center) {}
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TopBar(onOpenDrawer: () -> Unit) {
  TopAppBar(
      modifier = Modifier.height(48.dp),
      colors =
          TopAppBarDefaults.topAppBarColors(
              containerColor =
                  MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0f)), // transparente NavBar
      navigationIcon = {
        Icon(
            imageVector = Icons.Default.Menu,
            contentDescription = "Menu",
            tint = Text_prime,
            modifier = Modifier.padding(12.dp).size(22.dp).clickable { onOpenDrawer() })
      },
      title = {
        Text(
            "Screen Name", // TODO - ProfileCard klein einfügen
            style =
                MaterialTheme.typography.headlineSmall.copy(
                    fontWeight = FontWeight.SemiBold), // SemiBold Text)
            color = Text_prime,
            modifier = Modifier.padding(7.dp))
      },
      actions = {
        // Icon wird rechts allignt durch Nutzung von `actions`, die immer rechts positioniert
        // werden
        Icon(
            imageVector = Icons.Default.Notifications,
            contentDescription = "Notification",
            tint = Text_prime,
            modifier =
                Modifier.padding(12.dp)
                    // Größe anpassen
                    .size(22.dp)
                    .clickable { onOpenDrawer() }
            // Funktion aufrufen, wenn auf das Icon geklickt wird
            )
      })
}

@Composable
fun DrawerContent(navController: NavController, drawerState: DrawerState) {
  val coroutineScope = rememberCoroutineScope()
  Column(
      modifier = Modifier.padding(top = 60.dp, start = 20.dp, end = 8.dp, bottom = 10.dp),
  ) {
    Text(
        text = "ProfileCard klein", // TODO - ProfilCard klein einfügen
        fontSize = 16.sp,
        modifier = Modifier.padding(12.dp),
    )

    Spacer(modifier = Modifier.height(4.dp))
    NavigationDrawerItem(
        modifier = Modifier.background(Color.Transparent).height(42.dp).fillMaxWidth(),
        icon = {
          Icon(imageVector = Icons.Rounded.Home, contentDescription = "Home", tint = Text_prime)
        },
        label = {
          Text(
              text = "Home", // Titel der Seite
              fontSize = 16.sp,
              modifier = Modifier.padding(12.dp),
              color = Text_prime,
          )
        },
        selected =
            if (navController.currentDestination?.route == Screen.Home.rout) true
            else false, // Ist das gerade die Seite, auf der wir sind?
        onClick = {
          navController.navigate("home")
          coroutineScope.launch {
            drawerState.close() // close drawer
          }
        }, // Logik für onClick Events
        shape = RoundedCornerShape(8.dp),
        colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
    )

    Spacer(modifier = Modifier.height(4.dp))
    NavigationDrawerItem(
        modifier = Modifier.height(42.dp).fillMaxWidth(),
        icon = {
          Icon(
              imageVector = Icons.Rounded.List, contentDescription = "Sitzungen", tint = Text_prime)
        },
        label = {
          Text(
              text = "Sitzungen", // Titel der Seite
              fontSize = 16.sp,
              modifier = Modifier.padding(12.dp),
              color = Text_prime,
          )
        },
        selected =
            if (navController.currentDestination?.route == Screen.Sitzungen.rout) true
            else false, // Ist das gerade die Seite, auf der wir sind?
        onClick = {
          navController.navigate(Screen.Sitzungen.rout)
          coroutineScope.launch {
            drawerState.close() // close drawer
          }
        }, // Logik für onClick Events
        shape = RoundedCornerShape(8.dp),
        colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
    )
    Spacer(modifier = Modifier.height(4.dp))
    NavigationDrawerItem(
        modifier = Modifier.height(42.dp).fillMaxWidth(),
        icon = {
          Icon(
              imageVector = Icons.Rounded.Edit,
              contentDescription = "Protokolle",
              tint = Text_prime)
        },
        label = {
          Text(
              text = "Protokolle", // Titel der Seite
              color = Text_prime,
              // fontSize = 16.dp,
              modifier = Modifier.padding(12.dp))
        },
        selected =
            if (navController.currentDestination?.route == Screen.Protokolle.rout) true
            else false, // Ist das gerade die Seite, auf der wir sind?
        onClick = {
          navController.navigate("protokolle")
          coroutineScope.launch {
            drawerState.close() // close drawer
          }
        }, // Logik für onClick Events
        shape = RoundedCornerShape(8.dp),
        colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
    )
    Spacer(modifier = Modifier.height(4.dp))
    NavigationDrawerItem(
        modifier = Modifier.height(42.dp).fillMaxWidth(),
        icon = {
          Icon(
              imageVector = Icons.Rounded.Edit,
              contentDescription = "Anwesenheit",
              tint = Text_prime)
        },
        label = {
          Text(
              text = "Anwesenheit", // Titel der Seite
              color = Text_prime,
              // fontSize = 16.dp,
              modifier = Modifier.padding(12.dp))
        },
        selected =
            if (navController.currentDestination?.route == Screen.Anwesenheit.rout) true
            else false, // Ist das gerade die Seite, auf der wir sind?
        onClick = {
          navController.navigate("anwesenheit")
          coroutineScope.launch {
            drawerState.close() // close drawer
          }
        }, // Logik für onClick Events
        shape = RoundedCornerShape(8.dp),
        colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
    )
    NavigationDrawerItem(
        modifier = Modifier.height(42.dp).fillMaxWidth(),
        icon = {
          Icon(
              painter = painterResource(id = R.drawable.ic_votings_page_24),
              contentDescription = "Abstimmungen",
              tint = Text_prime)
        },
        label = {
          Text(
              text = "Abstimmungen", // Titel der Seite
              color = Text_prime,
              // fontSize = 16.dp,
              modifier = Modifier.padding(12.dp))
        },
        selected =
            if (navController.currentDestination?.route == Screen.Anwesenheit.rout) true
            else false, // Ist das gerade die Seite, auf der wir sind?
        onClick = {
          navController.navigate("abstimmungen")
          coroutineScope.launch {
            drawerState.close() // close drawer
          }
        }, // Logik für onClick Events
        shape = RoundedCornerShape(8.dp),
        colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
    )
  }
}
