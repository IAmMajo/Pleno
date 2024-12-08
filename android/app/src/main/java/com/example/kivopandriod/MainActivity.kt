package com.example.kivopandriod

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.kivopandriod.pages.AnwesenheitScreen
import com.example.kivopandriod.pages.HomePage
import com.example.kivopandriod.pages.LoginScreen
import com.example.kivopandriod.pages.ProtocolListPage
import com.example.kivopandriod.pages.AttendancesCoordinationPage
import com.example.kivopandriod.pages.MeetingsListPage
import com.example.kivopandriod.ui.theme.KIVoPAndriodTheme
import com.example.kivopandriod.ui.theme.Primary_dark_20
import com.example.kivopandriod.ui.theme.Text_light
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            KIVoPAndriodTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier
                        .fillMaxSize(),

                    color = Color(0xfffafaee),   //TODO - Android Background Light)
                ) {
                    val navController: NavHostController = rememberNavController()
                    Nav(navController)
                }
            }
        }
    }
}
//TODO - Navigation anpassen name anpassen
@Composable
fun navigation(navController: NavHostController){
    //val navController = rememberNavController()
    NavHost(
        navController = navController,
        startDestination = Screen.Login.rout,
        modifier = Modifier
            .fillMaxWidth()
            .padding(           //TODO - Padding anpassen
                top = 60.dp,
                start = 12.dp,
                end = 12.dp,
                bottom = 12.dp
            )
            .background(Color(0xfffafaee)),   //TODO - Android Background Light
    ){
        // LoginScreen
        composable(Screen.Login.rout){
            LoginScreen(navController = navController)
        }
        // StartScreen

        composable(Screen.Home.rout){
            HomePage(navController = navController)
        }
        // Sitzungen
        composable(Screen.Sitzungen.rout){
            MeetingsListPage(navController = navController)
        }
        // Anwesenheit liste
        composable(route = Screen.Anwesenheit.rout){
            AnwesenheitScreen(navController = navController)
        }
        // Anwesenheit
        composable(
            route = Screen.Anwesenheit.rout +"/{meetingID}",
            arguments = listOf(
                navArgument("meetingID") {type = NavType.StringType},
            ))
            { backStackEntry ->
            val meetingID = backStackEntry.arguments?.getString("meetingID") ?: ""
            AttendancesCoordinationPage(navController = navController, meetingId = meetingID)
        }
        // Protokolle
        composable(route = Screen.Protokolle.rout){
            ProtocolListPage(navController = navController)
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
                modifier = Modifier
                    .fillMaxHeight()
                    .width(LocalConfiguration.current.screenWidthDp.dp * drawerWidth.value)
                    .background(Color(0xffeeefe3))   // TODO - Android Background Secondary
            ) {
                DrawerContent(navController,drawerState) // Übergabe des NavControllers an den Drawer
            }
        },
        gesturesEnabled = true // zum swipen des NavDrawers
        ){
        // Implementierung der TopBar mit Boolean, welcher aus drawerState entnommen wird.
        TopBar(
            onOpenDrawer = {
                scope.launch() {
                    // open/close NavDrawer
                    drawerState.apply {
                        if(drawerState.isClosed) drawerState.open()
                        else drawerState.close()
                    }
                }
            }
        )
        navigation(navController)
    }
}

@Composable
fun ScreenContent(modifier: Modifier = Modifier, title: String,navController: NavController){
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {

    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TopBar(
    onOpenDrawer: () -> Unit
){
    TopAppBar(
        modifier = Modifier
            .height(48.dp),
        colors = TopAppBarDefaults
            .topAppBarColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0f)), // transparente NavBar
        navigationIcon = {
            Icon(
                imageVector = Icons.Default.Menu,
                contentDescription = "Menu",
                tint = Text_light,
                modifier = Modifier
                    .padding(12.dp)
                    .size(22.dp)
                    .clickable {onOpenDrawer()}
            )
        },
        title = {
            Text("Screen Name",                 // TODO - ProfileCard klein einfügen
                style = MaterialTheme
                    .typography
                    .headlineSmall
                    .copy(fontWeight = FontWeight.SemiBold), // SemiBold Text)
                color = Text_light,
                modifier = Modifier
                    .padding(7.dp)
            )
        },
        actions = {
            // Icon wird rechts allignt durch Nutzung von `actions`, die immer rechts positioniert werden
            Icon(
                imageVector = Icons.Default.Notifications,
                contentDescription = "Notification",
                tint = Text_light,
                modifier = Modifier
                    .padding(12.dp)
                    // Größe anpassen
                    .size(22.dp)
                    .clickable{ onOpenDrawer() }
                     // Funktion aufrufen, wenn auf das Icon geklickt wird
            )

        }
    )
}

@Composable
fun DrawerContent(
    navController: NavController,
    drawerState: DrawerState
){
    val coroutineScope = rememberCoroutineScope()
    Column(
        modifier = Modifier
            .padding(top = 60.dp, start = 20.dp, end = 8.dp, bottom = 10.dp),
    ) {
        Text(
            text= "ProfileCard klein",      // TODO - ProfilCard klein einfügen
            fontSize = 16.sp,
            modifier = Modifier.padding(12.dp),
        )

        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            modifier = Modifier
                .background(Color.Transparent)
                .height(42.dp)
                .fillMaxWidth(),
            icon = {
                Icon(
                    imageVector = Icons.Rounded.Home,
                    contentDescription = "Home",
                    tint = Text_light) },
            label = {
                Text(
                    text = "Home",   //Titel der Seite
                    fontSize = 16.sp,
                    modifier = Modifier.padding(12.dp),
                    color = Text_light,
                )
                },
            selected = if (navController.currentDestination?.route == Screen.Home.rout) true else false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {
                navController.navigate("home")
                coroutineScope.launch {
                    drawerState.close() // close drawer
                }},      // Logik für onClick Events
            shape = RoundedCornerShape(8.dp),
            colors =  NavigationDrawerItemDefaults.colors(Primary_dark_20,Color.Transparent),
            )

        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            modifier = Modifier

                .height(42.dp)
                .fillMaxWidth(),
            icon = { Icon(
                imageVector = Icons.Rounded.List,
                contentDescription = "Sitzungen",
                tint = Text_light) },
            label = {
                Text(
                    text = "Sitzungen",   //Titel der Seite
                    fontSize = 16.sp,
                    modifier = Modifier.padding(12.dp),
                    color = Text_light,
                )
            },

            selected = if (navController.currentDestination?.route == Screen.Sitzungen.rout) true else false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {
                navController.navigate(Screen.Sitzungen.rout)
                coroutineScope.launch {
                    drawerState.close() // close drawer
                }}, // Logik für onClick Events
            shape = RoundedCornerShape(8.dp),
            colors =  NavigationDrawerItemDefaults.colors(Primary_dark_20,Color.Transparent),
        )
        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            modifier = Modifier
                .height(42.dp)
                .fillMaxWidth(),
            icon = { Icon(
                imageVector = Icons.Rounded.Edit,
                contentDescription = "Protokolle",
                tint = Text_light) },
            label = {
                Text(
                    text = "Protokolle",   //Titel der Seite
                    color = Text_light,
                    //fontSize = 16.dp,
                    modifier = Modifier.padding(12.dp)
                )
            },
            selected = if (navController.currentDestination?.route == Screen.Protokolle.rout) true else false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {
                navController.navigate("protokolle")
                coroutineScope.launch {
                    drawerState.close() // close drawer
                }},      // Logik für onClick Events
            shape = RoundedCornerShape(8.dp),
            colors =  NavigationDrawerItemDefaults.colors(Primary_dark_20,Color.Transparent),
        )
        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            modifier = Modifier
                .height(42.dp)
                .fillMaxWidth(),
            icon = { Icon(
                imageVector = Icons.Rounded.Edit,
                contentDescription = "Anwesenheit",
                tint = Text_light) },
            label = {
                Text(
                    text = "Anwesenheit",   //Titel der Seite
                    color = Text_light,
                    //fontSize = 16.dp,
                    modifier = Modifier.padding(12.dp)
                )
            },
            selected = if (navController.currentDestination?.route == Screen.Anwesenheit.rout) true else false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {
                navController.navigate("anwesenheit")
                coroutineScope.launch {
                    drawerState.close() // close drawer
                }},      // Logik für onClick Events
            shape = RoundedCornerShape(8.dp),
            colors =  NavigationDrawerItemDefaults.colors(Primary_dark_20,Color.Transparent),
        )
    }
}