package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material3.DrawerState
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.NavigationDrawerItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.Screen
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_secondary

data class drawerItem(
  val modifier: Modifier,
  val icon: ImageVector,
  val title: String,
  val route: String
)

@Composable
fun DrawerItem(
  drawerItem: drawerItem,
  selected: Boolean,
  onClick: () -> Unit
){
  NavigationDrawerItem(
    modifier = drawerItem.modifier.fillMaxWidth(),
    icon = {
      Icon(imageVector = drawerItem.icon, contentDescription = drawerItem.title, tint = Text_secondary)
    },
    label = {
      Text(
        text = drawerItem.title,
        style = MaterialTheme.typography.labelLarge,
        modifier = Modifier.padding(12.dp),
        color = Text_secondary,
      )
    },
    selected = selected,
    onClick = {
      onClick()
    },
    shape = RoundedCornerShape(8.dp),
    colors = NavigationDrawerItemDefaults.colors(Primary_20, Color.Transparent),
  )
}