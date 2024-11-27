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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.List
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.Scaffold
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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.kivopandriod.ui.theme.KIVoPAndriodTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            KIVoPAndriodTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val navController = rememberNavController()


                        NavHost(
                            navController = navController,
                            startDestination = Screen.Home.rout,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding( //TODO: Padding anpassen
                                    top = 72.dp,
                                    start = 12.dp,
                                    end = 12.dp,
                                    bottom = 12.dp
                                )


                        ){
                            // StartScreen
                            composable(Screen.Home.rout){
                                HomeScreen(navController = navController)
                            }
                            // Sitzungen
                            composable(Screen.Sitzungen.rout){
                                SitzungenScreen(navController = navController)
                            }
                            // Protokolle
                            composable(route = Screen.Protokolle.rout){
                                ProtokolleScreen(navController = navController)
                            }
                        }
                        Nav(navController)

                    //
                }
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    KIVoPAndriodTheme {
        Greeting("Android")
    }
}

@Composable
fun Nav(navController: NavController, modifier: Modifier = Modifier) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    // Berechnung der Breite des Drawers (2/3 Bildschirmbreite)
    val drawerWidth = animateFloatAsState(targetValue = if (drawerState.isOpen) 0.66f else 0f)

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .width(LocalConfiguration.current.screenWidthDp.dp * drawerWidth.value)
                    .background(color = Color.Gray)
            ) {
                DrawerContent(navController) // Übergabe des NavControllers an den Drawer
            }
        },
        gesturesEnabled = true // zum swipen des NavDrawers
        ){

                // Implementierung der TopBar mit Boolean, welcher aus drawerState entnommen wird.
                //CenterAlignedTopAppBar
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
        colors = TopAppBarDefaults
            .topAppBarColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f) ),
        navigationIcon = {
            Icon(
                imageVector = Icons.Default.Menu,
                contentDescription = "Menu",
                modifier = Modifier
                    .padding(12.dp)
                    .size(22.dp)
                    .clickable {onOpenDrawer()}
            )
        },
        title = {
            Text("Screen Name",                 // TODO - ProfileCard klein einfügen
                style = MaterialTheme.typography
                    .headlineSmall
                    .copy(fontWeight = FontWeight.SemiBold) // SemiBold Text)
            )

        },
        actions = {
            // Icon wird rechts allignt durch Nutzung von `actions`, die immer rechts positioniert werden
            Icon(
                imageVector = Icons.Default.Notifications,
                contentDescription = "Menu",
                modifier = Modifier
                    .padding(12.dp)
                    // Größe anpassen
                    .size(22.dp)
                    // Padding für das Icon (z. B. um es nicht direkt am Rand zu haben)
                    .clickable{ onOpenDrawer() }
                     // Funktion aufrufen, wenn auf das Icon geklickt wird
            )

        }
    )
}

@Composable
fun DrawerContent(
    navController: NavController,
    modifier: Modifier = Modifier){
    Column {
        Text(
            text= "ProfileCard klein",
            fontSize = 16.sp,
            modifier = Modifier.padding(12.dp),
        )

        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            icon = { Icon(
                imageVector = Icons.Rounded.Home,
                contentDescription = "Home") },
            label = {
                Text(
                    text = "Home",   //Titel der Seite
                    fontSize = 16.sp,
                    modifier = Modifier.padding(12.dp)
                )
                },
            selected = false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {navController.navigate("home")}      // Logik für onClick Events
        )

        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            icon = { Icon(
                imageVector = Icons.Rounded.List,
                contentDescription = "Sitzungen") },
            label = {
                Text(
                    text = "Sitzungen",   //Titel der Seite
                    fontSize = 16.sp,
                    modifier = Modifier.padding(12.dp)
                )
            },
            selected = false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {navController.navigate(Screen.Sitzungen.rout) }      // Logik für onClick Events
        )
        Spacer(modifier = Modifier.height(4.dp))
        NavigationDrawerItem(
            icon = { Icon(
                imageVector = Icons.Rounded.Edit,
                contentDescription = "Protokolle") },
            label = {
                Text(
                    text = "Protokolle",   //Titel der Seite
                    //fontSize = 16.dp,
                    modifier = Modifier.padding(12.dp)
                )
            },
            selected = false,           // Ist das gerade die Seite, auf der wir sind?
            onClick = {navController.navigate("protokolle")}      // Logik für onClick Events
        )
    }
}