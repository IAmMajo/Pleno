package com.example.kivopandriod

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
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
import androidx.compose.material.icons.rounded.AccountCircle
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
                    Screen()
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

@Preview
@Composable
fun Screen(modifier: Modifier = Modifier) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope() // State für das AndroidOS
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
                DrawerContent()
            }
        }
        ){
        // Scaffold oben am Bildschrim
        Scaffold (
            topBar = {
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
            }
        ){
            padding -> ScreenContent(modifier = Modifier.padding(padding), title = "ScreenContent")
        }
    }
}

@Composable
fun ScreenContent(modifier: Modifier = Modifier,
                  title: String){
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineLarge.copy(fontWeight = FontWeight.Bold)
        )
    }
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TopBar(onOpenDrawer: () -> Unit){
    TopAppBar(
        title = {
            // Title wird mittig allignt
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ){
                Text(
                    text = "Screen Name",   // noch anpassen
                    style = MaterialTheme.typography
                        .headlineSmall
                        .copy(fontWeight = FontWeight.SemiBold) // SemiBold Text)
                )
            }
        },
        actions = {
            // Icon wird rechts allignt durch Nutzung von `actions`, die immer rechts positioniert werden
            Icon(
                imageVector = Icons.Default.Menu,
                contentDescription = "Menu",
                modifier = Modifier
                    .padding(26.dp)
                    // Größe anpassen
                    .size(28.dp)
                    // Padding für das Icon (z. B. um es nicht direkt am Rand zu haben)
                    .clickable{ onOpenDrawer() }
                // Funktion aufrufen, wenn auf das Icon geklickt wird
            )

        },
    )
}

@Composable
fun DrawerContent(modifier: Modifier = Modifier){
    NavigationDrawerItem(
        icon = { Icon(
            imageVector = Icons.Rounded.AccountCircle,
            contentDescription = "Account") },
        label = { Text(text = "Seite 1") }, //Titel des Items
        selected = false,           // Ist das gerade die Seite, auf der wir sind?
        onClick = { /*TODO*/ }      // Logik für onClick Events
    )
    Spacer(modifier = Modifier.height(4.dp))

}